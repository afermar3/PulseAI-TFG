from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database.database import Base, engine
from app.routers import auth_router, profile_router

Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="PulseAI API",
    version="1.0.0",
    description="Backend de PulseAI desarrollado con FastAPI",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth_router.router)
app.include_router(profile_router.router)


@app.get("/")
def root():
    return {
        "message": "PulseAI backend funcionando correctamente"
    }