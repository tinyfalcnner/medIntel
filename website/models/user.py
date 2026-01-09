from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

# Add this model
class UserCreate(BaseModel):
    full_name: str
    email: str

class User(BaseModel):
    user_id: str
    full_name: str
    email: str

# Rest of your code remains the same...
users_db = {
    "user1": {"user_id": "user1", "full_name": "Devak R", "email": "devak@example.com"}
}

@router.get("/{user_id}", response_model=User)
def get_user(user_id: str):
    user = users_db.get(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user