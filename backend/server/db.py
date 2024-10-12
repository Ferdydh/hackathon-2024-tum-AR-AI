from sqlalchemy import create_engine, Column, Integer, String, ForeignKey
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.orm import sessionmaker, relationship, declarative_base
from pgvector.sqlalchemy import Vector
import random
import os
from pydantic import BaseModel
from contextlib import contextmanager

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_USER = os.getenv("DB_USER", "hackathon_user")
DB_PASSWORD = os.getenv("DB_PASSWORD", "hackathon_password")
DB_NAME = os.getenv("DB_NAME", "hackathon_db")

DATABASE_URL = f"postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}/{DB_NAME}"

# Define the base for our models
Base = declarative_base()


@contextmanager
def get_session():
    session = Session()
    try:
        yield session
        session.commit()
    except:
        session.rollback()
        raise
    finally:
        session.close()


# Define Friend table (stores friend details)
class FriendTable(Base):
    __tablename__ = "friend"

    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    details = Column(ARRAY(String))

    embeddings = relationship(
        "EmbeddingTable", back_populates="friend", cascade="all, delete-orphan"
    )


# Pydantic
class FriendModel(BaseModel):
    id: int
    name: str
    details: list[str]

    class Config:
        orm_mode = True


# Define EmbeddingTable table (stores embeddings)
class EmbeddingTable(Base):
    __tablename__ = "embedding_table"

    embedding_id = Column(Integer, primary_key=True)
    friend_id = Column(Integer, ForeignKey("friend.id", ondelete="CASCADE"))
    embedding = Column(Vector(128))  # Assuming embeddings are 128-dimensional

    friend = relationship("FriendTable", back_populates="embeddings")


# Create database engine and session
engine = create_engine(DATABASE_URL)
Session = sessionmaker(bind=engine)


class FriendNotFoundError(Exception):
    pass


class FriendService:
    def create_tables_if_not_exist(self):
        """Creates tables if they do not exist and populates with random data if necessary."""
        Base.metadata.create_all(engine)

        with get_session() as session:
            if session.query(FriendTable).count() == 0:
                self.populate_random_data()

    def populate_random_data(self):
        """Populate the database with random data."""
        friends_data = [
            {"name": "Alice", "details": ["vegan", "likes hiking"]},
            {"name": "Bob", "details": ["vegetarian", "enjoys reading"]},
        ]
        embeddings_data = [
            [
                [random.random() for _ in range(128)] for _ in range(2)
            ],  # Alice embeddings
            [[random.random() for _ in range(128)] for _ in range(2)],  # Bob embeddings
        ]

        for i, friend_data in enumerate(friends_data):
            self.add_new_friend(
                friend_data["name"], friend_data["details"], embeddings_data[i]
            )

    def add_new_friend(
        self, name: str, details: list[str], embeddings: list[list[float]]
    ):
        """Add a new friend along with their embeddings."""
        with get_session() as session:
            friend = FriendTable(name=name, details=details)
            session.add(friend)
            session.commit()  # Commit to get friend.id

            for embedding in embeddings:
                friend_embedding = EmbeddingTable(
                    friend_id=friend.id, embedding=embedding
                )
                session.add(friend_embedding)

            session.commit()
            return friend.id

    def edit_friend(
        self,
        friend_id: int,
        new_name: str | None,
        new_details: list[str] | None,
    ):
        """Edit friend details."""
        with get_session() as session:
            friend = (
                session.query(FriendTable).filter(FriendTable.id == friend_id).first()
            )
            if not friend:
                raise FriendNotFoundError()

            if new_name:
                friend.name = new_name
            if new_details:
                friend.details = new_details

            session.commit()
            return friend_id

    def delete_friend(self, friend_id: int) -> bool:
        """Delete a friend by ID."""
        with get_session() as session:
            friend = (
                session.query(FriendTable).filter(FriendTable.id == friend_id).first()
            )
            if not friend:
                raise FriendNotFoundError()

            session.delete(friend)
            session.commit()
            return True

    def get_all_friends(self):
        """Get a list of all friends and their embeddings."""
        with get_session() as session:
            friends = session.query(FriendTable).all()

            return [
                FriendModel(id=friend.id, name=friend.name, details=friend.details)
                for friend in friends
            ]

    def get_friend_by_id(self, friend_id: int) -> FriendModel | None:
        """Get a friend by ID."""
        with get_session() as session:
            friend = (
                session.query(FriendTable).filter(FriendTable.id == friend_id).first()
            )
            if not friend:
                return None

            return FriendModel(id=friend.id, name=friend.name, details=friend.details)

    def get_friend_by_embeddings(self, embeddings: list[float]):
        """Get a friend by embeddings using PostgreSQL's pgvector extension for similarity search."""
        with get_session() as session:
            # Perform similarity search using the built-in PostgreSQL 'vector <->' operator for Euclidean distance
            closest_friend_embedding = (
                session.query(EmbeddingTable)
                .order_by(EmbeddingTable.embedding.l2_distance(embeddings))
                .first()
            )

            if closest_friend_embedding:
                closest_friend = closest_friend_embedding.friend
                return FriendModel(
                    id=closest_friend.id,
                    name=closest_friend.name,
                    details=closest_friend.details,
                )
            else:
                return None
