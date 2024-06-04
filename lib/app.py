from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import io
import base64
import tensorflow as tf
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.image import load_img
import warnings

warnings.filterwarnings('ignore')

app = Flask(__name__)
CORS(app)

def detect_and_draw_faces(image):
    face_cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
    face_cascade = cv2.CascadeClassifier(face_cascade_path)

    if face_cascade.empty():
        print("Failed to load Haar cascade")
        return image, []

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    faces_list = []
    margin = 0.2  # 20% margin around the detected face
    for (x, y, w, h) in faces:
        x_margin = int(w * margin)
        y_margin = int(h * margin)
        x1 = max(x - x_margin, 0)
        y1 = max(y - y_margin, 0)
        x2 = min(x + w + x_margin, image.shape[1])
        y2 = min(y + h + y_margin, image.shape[0])
        cv2.rectangle(image, (x1, y1), (x2, y2), (255, 0, 0), 2)
        faces_list.append([int(x1), int(y1), int(x2 - x1), int(y2 - y1)])  # Ensure all values are native Python ints

    return image, faces_list

@app.route('/process-image', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files['image']
    try:
        img = Image.open(file.stream).convert('RGB')
        img = np.array(img)
        print("Image loaded successfully")
    except Exception as e:
        print(f"Error loading image: {e}")
        return jsonify({"error": "Invalid image file"}), 400

    img, faces = detect_and_draw_faces(img)
    if len(faces) == 0:
        return jsonify({"error": "No face detected"}), 400

    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img_pil = Image.fromarray(img_rgb)
    img_io = io.BytesIO()
    img_pil.save(img_io, 'JPEG')
    img_io.seek(0)

    img_path = 'processed_image.jpg'
    img_pil.save(img_path)

    predictions = []
    for (x1, y1, w, h) in faces:
        x2, y2 = x1 + w, y1 + h
        face_img = img[y1:y2, x1:x2]
        face_pil = Image.fromarray(cv2.cvtColor(face_img, cv2.COLOR_BGR2RGB))
        face_path = 'face_image.jpg'
        face_pil.save(face_path)
        age_prediction = predict_age(face_path)
        gender_prediction = predict_gender(face_path)
        emotion_prediction = predict_emotion(face_path)
        predictions.append({
            "box": [int(x1), int(y1), int(w), int(h)],  # Ensure width and height are native Python integers
            "age": age_prediction,
            "gender": gender_prediction,
            "emotion": emotion_prediction
        })

    print("Image processing completed")
    return jsonify({
        "image": "data:image/jpeg;base64," + base64.b64encode(img_io.getvalue()).decode('utf-8'),
        "faces": faces,
        "image_path": img_path,
        "predictions": predictions
    })

def predict_gender(image_path):
    model_gender = load_model('./models/ModelGender.keras')
    X_new = extract_feature_gender(image_path)
    gender_pred = model_gender.predict(X_new)
    print("gender predicted")
    return match_gender(gender_pred[0])

def extract_feature_gender(image):
    feature = []
    img = load_img(image)
    img = img.resize((128, 128), Image.LANCZOS)
    img = np.array(img)
    feature.append(img)
    feature = np.array(feature)
    feature = feature.reshape(len(feature), 128, 128, 3)
    return feature

def match_gender(value):
    gender_dict = {0: 'Male', 1: 'Female'}
    return gender_dict[int(round(value[0]))]

def predict_emotion(image_path):
    tflite_model_path = "./models/ResNet50EmotionLite.tflite"
    interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    def predict(image):
        image = image.astype(np.float32)
        interpreter.set_tensor(input_details[0]['index'], image)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]['index'])
        return output_data

    input_image = extract_feature_emotion(image_path)
    predictions = predict(input_image)
    print("emotion predicted")
    return match_emo(predictions)

def extract_feature_emotion(image):
    feature = []
    img = load_img(image, color_mode='grayscale', target_size=(48, 48))
    img = img.resize((224, 224), Image.LANCZOS)
    img = np.array(img)
    img = np.repeat(img, 3, axis=-1)
    feature.append(img)
    feature = np.array(feature)
    feature = feature.reshape(len(feature), 224, 224, 3)
    return feature

def match_emo(one_hot_vector):
    # Dictionary of emotions
    emo_dict = {0: 'Angry', 1: 'Disgusted', 2: 'Fearful', 3: 'Happy', 4: 'Neutral', 5: 'Sad', 6: 'Surprised'}
    # Get the index of the maximum value in the one-hot vector
    predicted_class = np.argmax(one_hot_vector)
    return emo_dict[predicted_class]

def predict_age(image_path):
    tflite_model_path = "./models/ResNet50Age_ValAgeMse_CallbackLite.tflite"
    interpreter = tf.lite.Interpreter(model_path=tflite_model_path)
    interpreter.allocate_tensors()

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    def predict(image):
        image = image.astype(np.float32)
        interpreter.set_tensor(input_details[0]['index'], image)
        interpreter.invoke()
        output_data = interpreter.get_tensor(output_details[0]['index'])
        return output_data

    input_image = extract_feature_age(image_path)
    predictions = predict(input_image)
    print("age predicted")
    return str(round(predictions[0][0]))

def extract_feature_age(image):
    feature = []
    img = load_img(image)
    img = img.resize((200, 200), Image.LANCZOS)
    img = np.array(img)
    feature.append(img)
    feature = np.array(feature)
    feature = feature.reshape(len(feature), 200, 200, 3)
    return feature

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
