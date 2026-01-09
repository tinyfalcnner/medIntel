from fastapi import APIRouter
from pydantic import BaseModel
from website.models.conversation import Conversation

router = APIRouter()

# simple in‑memory store for conversations
conversations_db = []


@router.post("/")
def add_conversation(conv: Conversation):
    conversations_db.append(conv)
    return {"message": "Conversation saved", "conversation": conv}


@router.get("/")
def get_conversations():
    return conversations_db


# ---------- Chatbot endpoint ----------

class ChatRequest(BaseModel):
    user_id: str
    message: str


class ChatResponse(BaseModel):
    response: str


@router.post("/chat", response_model=ChatResponse)
async def chat(req: ChatRequest):
    user_id = req.user_id
    text = req.message.lower().strip()

    # Basic per‑user profile text
    if user_id == "u1":
        profile = (
            "You are Alice, 28-year-old woman with mild asthma. "
            "Your main goals are better cardio fitness and stress management."
        )
    elif user_id == "u2":
        profile = (
            "You are Brian, 45-year-old man with hypertension and prediabetes. "
            "Your main goals are weight loss and blood pressure control."
        )
    elif user_id == "u3":
        profile = (
            "You are Dr. Chen, 60-year-old woman with knee osteoarthritis and high cholesterol. "
            "Your main goals are joint health and maintaining energy."
        )
    else:
        profile = "Adult user with general health goals."

    advice_parts = []

    # Safety disclaimer
    advice_parts.append(
        "This is general educational information only, not a diagnosis or treatment plan. "
        "For persistent or severe symptoms, please see a doctor in person."
    )

    # Weight / diet
    if "weight" in text or "lose" in text or "diet" in text:
        if user_id == "u2":
            advice_parts.append(
                "For you, slow, steady weight loss helps both blood pressure and sugar. "
                "Try smaller portions of rice/bread, avoid sugary drinks, and fill half your plate "
                "with vegetables at lunch and dinner."
            )
        else:
            advice_parts.append(
                "Focus on regular meals, plenty of vegetables, and limiting sweets and deep‑fried foods. "
                "Avoid late‑night snacking where possible."
            )

    # Blood pressure
    if "bp" in text or "blood pressure" in text or "pressure" in text:
        advice_parts.append(
            "To support blood pressure, keep salt low: avoid instant noodles, chips, and very salty pickles. "
            "Aim for 20–30 minutes of relaxed walking on most days."
        )

    # Joints / knees
    if "knee" in text or "joint" in text or "arthritis" in text or "pain" in text:
        advice_parts.append(
            "For knee and joint comfort, prefer low‑impact activity like cycling, swimming, or flat walking. "
            "Avoid long standing, running on hard ground, or deep squats if they trigger pain."
        )

    # Breathing / asthma
    if "breath" in text or "asthma" in text or "wheeze" in text:
        advice_parts.append(
            "With asthma, warm up before exercise, keep your inhaler available, and avoid heavy exercise in very cold "
            "or polluted air whenever possible."
        )

    # Stress / sleep / fatigue
    if "stress" in text or "anxious" in text or "sleep" in text or "tired" in text or "fatigue" in text:
        advice_parts.append(
            "For stress and sleep, try a fixed sleep and wake time, avoid screens for 30 minutes before bed, "
            "and add one short walk or stretching break in the day purely for relaxation."
        )

    # Generic lifestyle advice if nothing matched
    if len(advice_parts) == 1:  # only disclaimer so far
        advice_parts.append(
            "As a simple daily target, aim for at least 20–30 minutes of movement, "
            "2–3 servings of vegetables, and 1–2 big glasses of plain water outside of meals."
        )

    advice_parts.append(profile)

    return ChatResponse(response="\n\n".join(advice_parts))
