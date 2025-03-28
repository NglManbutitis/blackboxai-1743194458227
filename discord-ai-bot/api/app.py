from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from transformers import pipeline, DistilBertTokenizer, DistilBertForSequenceClassification
import torch
import logging
from typing import Optional
import os

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class PredictionRequest(BaseModel):
    text: str
    user_id: Optional[str] = None

class PredictionResponse(BaseModel):
    response: str
    confidence: float

# Load model (replace with your trained model path)
MODEL_PATH = "./model/checkpoints"
if not os.path.exists(MODEL_PATH):
    raise FileNotFoundError(f"Model not found at {MODEL_PATH}")

tokenizer = DistilBertTokenizer.from_pretrained(MODEL_PATH)
model = DistilBertForSequenceClassification.from_pretrained(MODEL_PATH)
classifier = pipeline("text-classification", model=model, tokenizer=tokenizer)

@app.post("/predict", response_model=PredictionResponse)
async def predict(request: PredictionRequest):
    try:
        result = classifier(request.text)[0]
        return {
            "response": "Positive" if result['label'] == "LABEL_1" else "Negative",
            "confidence": result['score']
        }
    except Exception as e:
        logger.error(f"Prediction failed: {str(e)}")
        raise HTTPException(status_code=500, detail="Prediction failed")

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)