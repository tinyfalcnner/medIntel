from fastapi import APIRouter
from app.models.health_assessment import HealthAssessment

router = APIRouter()

assessments_db = []

@router.post("/")
def create_assessment(assessment: HealthAssessment):
    assessments_db.append(assessment)
    return {"message": "Assessment saved successfully", "assessment": assessment}

@router.get("/")
def get_assessments():
    return assessments_db
