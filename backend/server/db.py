from sqlalchemy import create_engine, Column, Integer, String, ForeignKey, ARRAY
from sqlalchemy.orm import sessionmaker, relationship, declarative_base
from pgvector.sqlalchemy import Vector
import random

# Define the base for our models
Base = declarative_base()


# Define Friend table (stores friend details)
class Friend(Base):
    __tablename__ = "friend"

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    details = Column(ARRAY(String))

    embeddings = relationship(
        "ImageEmbedding", back_populates="friend", cascade="all, delete-orphan"
    )


# Define ImageEmbedding table (stores embeddings)
class ImageEmbedding(Base):
    __tablename__ = "image_embedding"

    embedding_id = Column(Integer, primary_key=True)
    friend_id = Column(Integer, ForeignKey("friend.id", ondelete="CASCADE"))
    embedding = Column(Vector(128))  # Assuming embeddings are 3-dimensional

    friend = relationship("Friend", back_populates="embeddings")


# We could move this to env but for simplicity we'll keep it here
db_name = "hackathon_db"
db_user = "hackathon_user"
db_password = "hackathon_password"


# Create database engine and session
engine = create_engine(f"postgresql://{db_user}:{db_password}@localhost/{db_name}")
Session = sessionmaker(bind=engine)
session = Session()


def create_tables_if_not_exist():
    # Check if tables exist and create if not
    Base.metadata.create_all(engine)

    # Check if tables are empty and populate with random data if necessary
    if session.query(Friend).count() == 0:
        populate_random_data()


def populate_random_data():
    friends_data = [
        {"name": "Alice", "details": ["vegan", "likes hiking"]},
        {"name": "Bob", "details": ["vegetarian", "enjoys reading"]},
    ]
    embeddings_data = [
        [
            [random.random() for _ in range(128)] for _ in range(2)
        ],  # 2 random embeddings for Alice
        [
            [random.random() for _ in range(128)] for _ in range(2)
        ],  # 2 random embeddings for Bob
    ]

    for i, friend_data in enumerate(friends_data):
        add_new_friend(friend_data["name"], friend_data["details"], embeddings_data[i])


def add_new_friend(name: str, details: list[str], embeddings: list[list[float]]):
    friend = Friend(name=name, details=details)
    session.add(friend)
    session.commit()  # Commit to get friend.id

    for embedding in embeddings:
        friend_embedding = ImageEmbedding(friend_id=friend.id, embedding=embedding)
        session.add(friend_embedding)

    session.commit()
    print(f"Added new friend {name} with embeddings")
    return friend.id


def edit_friend(friend_id, new_name: str = None, new_details: list[str] = None):
    friend = session.query(Friend).filter(Friend.id == friend_id).first()
    if not friend:
        print(f"Friend with ID {friend_id} not found.")
        return

    if new_name:
        friend.name = new_name
    if new_details:
        friend.details = new_details

    session.commit()
    print(f"Friend {friend_id} has been updated.")


def delete_friend(friend_id):
    friend = session.query(Friend).filter(Friend.id == friend_id).first()
    if not friend:
        print(f"Friend with ID {friend_id} not found.")
        return

    session.delete(friend)
    session.commit()
    print(f"Friend {friend_id} and their embeddings have been deleted.")
