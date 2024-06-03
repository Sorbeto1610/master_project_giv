from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import io
import base64
import os
import tensorflow as tf
from tensorflow.keras.preprocessing.image import load_img
import warnings

warnings.filterwarnings('ignore')

app = Flask(__name__)
CORS(app)

def detect_and_draw_faces(image):
    print("Starting face detection...")
    face_cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
    print(f"Using Haar cascade file: {face_cascade_path}")
    face_cascade = cv2.CascadeClassifier(face_cascade_path)

    if face_cascade.empty():
        print("Error: Haar cascade file not found or incorrect path.")
        return image, []

    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    faces_list = []
    if len(faces) > 0:
        print("Detected faces coordinates: ")
        for (x, y, w, h) in faces:
            print(f"Face at [X: {x}, Y: {y}, Width: {w}, Height: {h}]")
            cv2.rectangle(image, (x, y), (x+w, y+h), (255, 0, 0), 2)
            faces_list.append([int(x), int(y), int(w), int(h)])
    else:
        print("No faces detected.")

    print("Face detection completed.")
    return image, faces_list

@app.route('/process-image', methods=['POST'])
def process_image():
    print("Received image for processing...")
    if 'image' not in request.files:
        print("No image uploaded.")
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files['image']
    try:
        img = Image.open(file.stream).convert('RGB')
        img = np.array(img)
        print("Image successfully loaded and converted.")
    except Exception as e:
        print(f"Error loading image: {e}")
        return jsonify({"error": "Invalid image file"}), 400

    img, faces = detect_and_draw_faces(img)
    if len(faces) == 0:
        return jsonify({"error": "No face detected"}), 400

    # Convert the image from BGR to RGB
    print("Converting image from BGR to RGB")
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # Convert the image with rectangles back to PIL format
    print("Converting image to PIL format")
    img_pil = Image.fromarray(img_rgb)
    img_io = io.BytesIO()
    img_pil.save(img_io, 'JPEG')
    img_io.seek(0)

    # Save the processed image to a file
    img_path = 'processed_image.jpg'
    img_pil.save(img_path)

    # Call the age prediction function for each detected face
    age_predictions = []
    for (x, y, w, h) in faces:
        face_img = img[y:y+h, x:x+w]
        face_pil = Image.fromarray(cv2.cvtColor(face_img, cv2.COLOR_BGR2RGB))
        face_path = 'face_image.jpg'
        face_pil.save(face_path)
        age_prediction = predict_age(face_path)
        age_predictions.append(age_prediction)

    print("Image processing completed and returned.")

    return jsonify({
        "image": "data:image/jpeg;base64," + base64.b64encode(img_io.getvalue()).decode('utf-8'),
        "faces": faces,
        "image_path": img_path,
        "age_predictions": age_predictions
    })

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

    input_image = extract_featureAge(image_path)
    predictions = predict(input_image)
    print(str(round(predictions[0][0])))
    return str(round(predictions[0][0]))

def extract_featureAge(image):
    feature = []
    img = load_img(image)
    img = img.resize((200, 200), Image.LANCZOS)  # Use Image.LANCZOS instead of Image.ANTIALIAS
    img = np.array(img)
    feature.append(img)
    feature = np.array(feature)
    feature = feature.reshape(len(feature), 200, 200, 3)
    return feature

if __name__ == '__main__':
    print("Starting Flask server...")
    app.run(debug=True, host='0.0.0.0', port=5001)
    print("Flask server is running.")
