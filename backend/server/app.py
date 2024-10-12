from fastapi import FastAPI, File, HTTPException, UploadFile
from pydantic import BaseModel

from .cv import extract_face_and_embedding
from .db import FriendNotFoundError, FriendService

friend_service = FriendService()
friend_service.create_tables_if_not_exist()
app = FastAPI()


@app.get("/friends")
def get_all_friends():
    return friend_service.get_all_friends()


@app.post("/friends/")
async def create_new_friend(image: UploadFile = File(...)):
    # Ensure the file is a valid image
    if not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Invalid image file")

    # Read the image file
    image_data = await image.read()

    # Extract the face and embeddings
    embedding = extract_face_and_embedding(image_data)

    # If no face is detected, raise an exception
    if embedding is None:
        raise HTTPException(status_code=400, detail="No face detected in the image")

    # Save to friend_list
    id = friend_service.add_new_friend("New Friend", [], embedding)

    # Return the newly added friend
    return friend_service.get_friend_by_id(id)


@app.get("/friends/{friend_id}")
async def get_friend(friend_id: int):
    friend = friend_service.get_friend_by_id(friend_id)
    if friend is None:
        raise HTTPException(status_code=404, detail="Friend not found")

    return friend


# Define the Pydantic model for the data format
class PutModel_Friend(BaseModel):
    name: str | None = None
    details: list[str] | None = None


@app.put("/friends/{friend_id}")
async def update_friend(friend_id: int, friend: PutModel_Friend):
    try:
        id = friend_service.edit_friend(friend_id, friend.name, friend.details)
        return id
    except FriendNotFoundError:
        raise HTTPException(status_code=404, detail="Friend not found")


@app.delete("/friends/{friend_id}")
async def delete_friend(friend_id: int):
    try:
        success = friend_service.delete_friend(friend_id)
        return success
    except FriendNotFoundError:
        raise HTTPException(status_code=404, detail="Friend not found")


@app.post("/friends/search_by_image")
async def search_friend_by_image(image: UploadFile = File(...)):
    # Ensure the file is a valid image

    if not image.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Invalid image file")

    embedding = extract_face_and_embedding(await image.read())
    if embedding is None:
        raise HTTPException(status_code=400, detail="No face detected in the image")

    # Search for the closest friend by embedding
    friend = friend_service.get_friend_by_embedding(embedding)
    if friend is None:
        raise HTTPException(status_code=404, detail="No matching friend found")

    return friend


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
