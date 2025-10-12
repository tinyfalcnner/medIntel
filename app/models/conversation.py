from pydantic import BaseModel

class Conversation(BaseModel):
    user_message: str
    bot_response: str
    context: dict | None = {}
    user_id: int
