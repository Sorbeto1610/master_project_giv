from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import io
import base64  # Ajoutez cette ligne

app = Flask(__name__)
CORS(app)

def detect_and_draw_faces(image):
    print("Starting face detection...")
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))

    faces_list = []
    if len(faces) > 0:
        print("Detected faces coordinates: ")
        for (x, y, w, h) in faces:
            print(f"Face at [X: {x}, Y: {y}, Width: {w}, Height: {h}]")
            cv2.rectangle(image, (x, y), (x+w, y+h), (255, 0, 0), 2)
            faces_list.append([int(x), int(y), int(w), int(h)])  # Conversion des valeurs en int
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

    print("Image processing completed and returned.")

    return jsonify({"image": "data:image/jpeg;base64," + base64.b64encode(img_io.getvalue()).decode('utf-8'), "faces": faces})

if __name__ == '__main__':
    print("Starting Flask server...")
    app.run(debug=True, host='0.0.0.0', port=5001)
    print("Flask server is running.")
