from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def root():
    return {"message": "URL shortener placeholder — real app arrives in Sprint 6"}

@app.get("/health")
def health():
    return {"status": "ok"}