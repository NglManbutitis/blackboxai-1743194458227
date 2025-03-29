import json
import os
import numpy as np
from nltk.tokenize import word_tokenize
from nltk.stem import WordNetLemmatizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from config import MODEL_PATH, KNOWLEDGE_FILE, LEARNING_RATE, MIN_CONFIDENCE
import torch
import torch.nn as nn
from transformers import AutoTokenizer, AutoModel
from typing import Dict, List, Tuple
import logging

logger = logging.getLogger(__name__)
lemmatizer = WordNetLemmatizer()

class AIModelHandler:
    def __init__(self):
        self.knowledge = self._load_knowledge()
        self.tokenizer = AutoTokenizer.from_pretrained('bert-base-uncased')
        self.bert_model = AutoModel.from_pretrained('bert-base-uncased')
        self.vectorizer = TfidfVectorizer()
        self._init_vectorizer()
        
    def _load_knowledge(self) -> Dict:
        """Load knowledge base from JSON file"""
        try:
            with open(KNOWLEDGE_FILE, 'r') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            return {"greetings": {}, "questions": {}, "responses": {}}

    def _save_knowledge(self):
        """Save current knowledge to file"""
        with open(KNOWLEDGE_FILE, 'w') as f:
            json.dump(self.knowledge, f, indent=2)

    def _init_vectorizer(self):
        """Initialize TF-IDF vectorizer with existing knowledge"""
        all_texts = []
        for category in self.knowledge.values():
            all_texts.extend(category.keys())
        if all_texts:
            self.vectorizer.fit(all_texts)

    def _preprocess_text(self, text: str) -> str:
        """Normalize and lemmatize input text"""
        tokens = word_tokenize(text.lower())
        return ' '.join([lemmatizer.lemmatize(token) for token in tokens])

    def _get_bert_embedding(self, text: str) -> np.ndarray:
        """Get BERT embedding for text"""
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, padding=True)
        with torch.no_grad():
            outputs = self.bert_model(**inputs)
        return outputs.last_hidden_state.mean(dim=1).numpy()

    def get_response(self, input_text: str) -> Tuple[str, float]:
        """Get best matching response with confidence score"""
        processed = self._preprocess_text(input_text)
        
        # First try exact matches
        for category, phrases in self.knowledge.items():
            if processed in phrases:
                return phrases[processed], 1.0
        
        # Then try semantic similarity
        best_response = ("I'm not sure how to respond to that.", 0.0)
        input_embedding = self._get_bert_embedding(processed)
        
        for category, phrases in self.knowledge.items():
            for phrase, response in phrases.items():
                phrase_embedding = self._get_bert_embedding(phrase)
                similarity = cosine_similarity(input_embedding, phrase_embedding)[0][0]
                
                if similarity > best_response[1]:
                    best_response = (response, similarity)
        
        return best_response if best_response[1] >= MIN_CONFIDENCE else ("I don't understand. Can you rephrase?", 0.0)

    def learn_phrase(self, input_text: str, response: str, category: str = "responses"):
        """Learn a new phrase-response pair"""
        processed = self._preprocess_text(input_text)
        
        if category not in self.knowledge:
            self.knowledge[category] = {}
            
        self.knowledge[category][processed] = response
        self._save_knowledge()
        self._init_vectorizer()  # Update vectorizer with new knowledge
        
    def batch_learn(self, phrases: List[Tuple[str, str, str]]):
        """Learn multiple phrase-response pairs at once"""
        for input_text, response, category in phrases:
            self.learn_phrase(input_text, response, category)
            
    def get_learning_stats(self) -> Dict:
        """Return statistics about learned knowledge"""
        return {
            "total_phrases": sum(len(cat) for cat in self.knowledge.values()),
            "categories": {k: len(v) for k, v in self.knowledge.items()}
        }

# Initialize singleton instance
model_handler = AIModelHandler()
