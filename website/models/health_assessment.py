from pydantic import BaseModel
from typing import Dict, List

class HealthAssessment(BaseModel):
    assessment_type: str  # e.g., diabetes, heart_health
    questions_answers: Dict[str, str]
    score: float | None
    recommendations: List[str] = []
    risk_level: str | None  # low, moderate, high
    user_id: int
