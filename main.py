from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import users, assessments, conversations

app = FastAPI(title="MedIntel API", version="1.0.0")

# CORS for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # replace with your frontend domain in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(assessments.router, prefix="/assessments", tags=["Assessments"])
app.include_router(conversations.router, prefix="/conversations", tags=["Conversations"])

@app.get("/")
def root():
    return {"message": "Welcome to MedIntel API"}
    