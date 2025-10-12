from fastapi import APIRouter
from app.models.conversation import Conversation

router = APIRouter()

conversations_db = []

@router.post("/")
def add_conversation(conv: Conversation):
    conversations_db.append(conv)
    return {"message": "Conversation saved", "conversation": conv}

@router.get("/")
def get_conversations():
    return conversations_db
