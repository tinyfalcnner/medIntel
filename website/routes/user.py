from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter()

# Define models here since they don't match your existing ones
class UserCreate(BaseModel):
    full_name: str
    email: str

class User(UserCreate):
    user_id: str

# In-memory users storage for demo
users_db = {}

@router.post("/register")
def register_user(user: UserCreate):
    new_user_id = f"user{len(users_db) + 1}"
    new_user = User(user_id=new_user_id, full_name=user.full_name, email=user.email)
    users_db[new_user_id] = new_user
    return new_user

@router.get("/{user_id}")
def get_user(user_id: str):
    user = users_db.get(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user