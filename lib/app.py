from flask import Flask, request, jsonify
from flask_cors import CORS
import cv2
import numpy as np
from PIL import Image
import io

app = Flask(__name__)
CORS(app)

def detect_and_crop_face(image):
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30))
    return faces

@app.route('/process-image', methods=['POST'])
def process_image():
    if 'image' not in request.files:
        return jsonify({"error": "No image uploaded"}), 400

    file = request.files['image']
    img = Image.open(file.stream)
    img = cv2.cvtColor(np.array(img), cv2.COLOR_BGR2RGB)

    faces = detect_and_crop_face(img)
    if len(faces) == 0:
        return jsonify({"error": "No face detected"}), 400

    # Simuler une réponse pour le moment
    response = {
        "faces": faces.tolist(),  # Convertir les coordonnées en liste
        "age": 25,
        "gender": "male",
        "emotion": "happy"
    }

    return jsonify(response)

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5001)
