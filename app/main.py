from fastapi import FastAPI

app = FastAPI(title="Orbidi API", version="0.1.0")


@app.get("/")
def root() -> dict:
    return {"service": "orbidi-api", "status": "ok"}


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}
