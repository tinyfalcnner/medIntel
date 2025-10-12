from fastapi import APIRouter

router = APIRouter()

# Dummy news
news_data = [
    "Eat more vegetables for better heart health.",
    "Regular exercise reduces risk of diabetes.",
    "Mental health is as important as physical health."
]

@router.get("/")
def get_news():
    return {"news": news_data}
