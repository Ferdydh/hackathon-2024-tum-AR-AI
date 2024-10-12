import asyncio
from fastapi import APIRouter, File, HTTPException, UploadFile
from deepface import DeepFace
import cv2
import numpy as np
from pydantic import BaseModel

# Create a router instance
router = APIRouter()


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


friend_list = {
    1: {"name": "Alice", "embeddings": [], "details": ["vegan", "likes hiking"]},
    2: {"name": "Bob", "embeddings": [], "details": ["vegetarian", "enjoys reading"]},
}


# FastAPI route to accept images
@router.post("/friends/")
async def create_new_friend(images: list[UploadFile] = File(...)):
    images_task = [image.read() for image in images]
    embeddings = [
        extract_face_and_embedding(i) for i in (await asyncio.gather(*images_task))
    ]
    embeddings = [e for e in embeddings if e is not None]

    print(len(embeddings[0]))

    if not embeddings:
        raise HTTPException(
            status_code=400, detail="No face detected in any of the images"
        )

    # save to friend_list
    friend_id = len(friend_list) + 1
    friend_list[friend_id] = {
        "id": friend_id,
        "name": f"Friend {friend_id}",
        "embeddings": [embeddings],
        "details": [],
    }

    return friend_list[friend_id]


@router.get("/friends/")
async def get_friends():
    return friend_list


@router.get("/friends/{friend_id}")
async def get_friend(friend_id: int):
    if friend_id not in friend_list:
        raise HTTPException(status_code=404, detail="Friend not found")

    return friend_list[friend_id]


# Define the Pydantic model for the data format
class PutModel_Friend(BaseModel):
    name: str
    details: list[str]


@router.put("/friends/{friend_id}")
async def update_friend(friend_id: int, friend: PutModel_Friend):
    if friend_id not in friend_list:
        raise HTTPException(status_code=404, detail="Friend not found")

    friend_list[friend_id] = friend.model_dump()
    return {"message": "Friend updated successfully", "friend": friend_list[friend_id]}


@router.delete("/friends/{friend_id}")
async def delete_friend(friend_id: int):
    if friend_id not in friend_list:
        raise HTTPException(status_code=404, detail="Friend not found")

    del friend_list[friend_id]
    return {"message": "Friend deleted successfully"}
