from deepface import DeepFace
import cv2
import numpy as np


face_cascade = cv2.CascadeClassifier(
    cv2.data.haarcascades + "haarcascade_frontalface_default.xml"
)


# Function to detect the face from the image and return the face embedding
def extract_face_and_embedding(image_bytes):
    # Convert image bytes to NumPy array
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)  # Decode image from buffer

    # Convert to grayscale (Haar Cascade works better with grayscale images)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Detect faces in the image
    faces = face_cascade.detectMultiScale(
        gray, scaleFactor=1.1, minNeighbors=5, minSize=(30, 30)
    )

    # If a face is detected, extract the first one (assuming there's only one)
    for x, y, w, h in faces:
        # Extract the region of interest (the face)
        face = img[y : y + h, x : x + w]

        # Since DeepFace can now accept NumPy arrays directly, we pass the face image array
        embedding = DeepFace.represent(face, model_name="Facenet")[0]["embedding"]

        return embedding  # Return the face embedding

    # If no face is detected, return None
    return None
