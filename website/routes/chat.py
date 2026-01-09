from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class Conversation(BaseModel):
    user_message: str
    bot_response: str = ""
    user_id: str

# Dummy chatbot (echo)
@router.post("/")
def chat(conversation: Conversation):
    conversation.bot_response = f"Echo: {conversation.user_message}"
    return conversation
