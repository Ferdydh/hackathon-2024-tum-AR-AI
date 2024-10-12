from fastapi import FastAPI

# from fastapi import FastAPI, WebSocket
# from fastapi.responses import HTMLResponse
from .ferdy import router

app = FastAPI()
app.include_router(router, prefix="/api")


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
