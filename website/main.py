from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routes.user import router as users_router
from .routes.assessments import router as assessments_router  
from .routes.conversations import router as conversations_router
from .routes.chat import router as chat_router
from .routes.news import router as news_router

app = FastAPI(title="MedIntel API", version="1.0.0")

# CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(users_router, prefix="/users", tags=["Users"])
app.include_router(assessments_router, prefix="/assessments", tags=["Assessments"])
app.include_router(conversations_router, prefix="/conversations", tags=["Conversations"])
app.include_router(chat_router, prefix="/chat", tags=["Chat"])
app.include_router(news_router, prefix="/news", tags=["News"])

@app.get("/")
def root():
    return {"message": "Welcome to MedIntel API"}