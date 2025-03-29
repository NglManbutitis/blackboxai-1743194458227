import json
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
from transformers import AdamW, AutoTokenizer, AutoModel
from sklearn.model_selection import train_test_split
from config import MODEL_PATH, KNOWLEDGE_FILE
import logging

logger = logging.getLogger(__name__)

class ConversationDataset(Dataset):
    def __init__(self, texts, labels, tokenizer, max_length=128):
        self.texts = texts
        self.labels = labels
        self.tokenizer = tokenizer
        self.max_length = max_length
        
    def __len__(self):
        return len(self.texts)
        
    def __getitem__(self, idx):
        text = self.texts[idx]
        label = self.labels[idx]
        
        encoding = self.tokenizer(
            text,
            max_length=self.max_length,
            padding='max_length',
            truncation=True,
            return_tensors='pt'
        )
        
        return {
            'input_ids': encoding['input_ids'].flatten(),
            'attention_mask': encoding['attention_mask'].flatten(),
            'labels': torch.tensor(label, dtype=torch.long)
        }

class AIModel(nn.Module):
    def __init__(self, n_classes):
        super(AIModel, self).__init__()
        self.bert = AutoModel.from_pretrained('bert-base-uncased')
        self.drop = nn.Dropout(p=0.3)
        self.out = nn.Linear(self.bert.config.hidden_size, n_classes)
        
    def forward(self, input_ids, attention_mask):
        outputs = self.bert(
            input_ids=input_ids,
            attention_mask=attention_mask
        )
        pooled_output = outputs.pooler_output
        output = self.drop(pooled_output)
        return self.out(output)

def load_training_data():
    """Load training data from knowledge base"""
    with open(KNOWLEDGE_FILE, 'r') as f:
        knowledge = json.load(f)
        
    texts = []
    labels = []
    label_map = {}
    current_label = 0
    
    for category, phrases in knowledge.items():
        for text, response in phrases.items():
            texts.append(text)
            if response not in label_map:
                label_map[response] = current_label
                current_label += 1
            labels.append(label_map[response])
            
    return texts, labels, label_map

def train_model():
    """Train the AI model using knowledge base"""
    logger.info("Loading training data...")
    texts, labels, label_map = load_training_data()
    
    if not texts:
        logger.warning("No training data available in knowledge base")
        return False
        
    tokenizer = AutoTokenizer.from_pretrained('bert-base-uncased')
    
    # Split data into train and validation sets
    train_texts, val_texts, train_labels, val_labels = train_test_split(
        texts, labels, test_size=0.2, random_state=42
    )
    
    # Create datasets
    train_dataset = ConversationDataset(
        train_texts, train_labels, tokenizer
    )
    val_dataset = ConversationDataset(
        val_texts, val_labels, tokenizer
    )
    
    # Create data loaders
    train_loader = DataLoader(train_dataset, batch_size=16, shuffle=True)
    val_loader = DataLoader(val_dataset, batch_size=16)
    
    # Initialize model
    model = AIModel(n_classes=len(label_map))
    model = model.cuda() if torch.cuda.is_available() else model
    optimizer = AdamW(model.parameters(), lr=2e-5)
    criterion = nn.CrossEntropyLoss()
    
    # Training loop
    best_accuracy = 0
    for epoch in range(3):  # 3 epochs
        model.train()
        total_loss = 0
        
        for batch in train_loader:
            optimizer.zero_grad()
            
            input_ids = batch['input_ids'].cuda() if torch.cuda.is_available() else batch['input_ids']
            attention_mask = batch['attention_mask'].cuda() if torch.cuda.is_available() else batch['attention_mask']
            labels = batch['labels'].cuda() if torch.cuda.is_available() else batch['labels']
            
            outputs = model(
                input_ids=input_ids,
                attention_mask=attention_mask
            )
            loss = criterion(outputs, labels)
            total_loss += loss.item()
            
            loss.backward()
            optimizer.step()
            
        # Validation
        model.eval()
        val_accuracy = 0
        val_loss = 0
        
        with torch.no_grad():
            for batch in val_loader:
                input_ids = batch['input_ids'].cuda() if torch.cuda.is_available() else batch['input_ids']
                attention_mask = batch['attention_mask'].cuda() if torch.cuda.is_available() else batch['attention_mask']
                labels = batch['labels'].cuda() if torch.cuda.is_available() else batch['labels']
                
                outputs = model(
                    input_ids=input_ids,
                    attention_mask=attention_mask
                )
                loss = criterion(outputs, labels)
                val_loss += loss.item()
                
                _, preds = torch.max(outputs, dim=1)
                val_accuracy += torch.sum(preds == labels).item() / len(labels)
                
        val_accuracy /= len(val_loader)
        val_loss /= len(val_loader)
        
        logger.info(
            f"Epoch {epoch + 1} | "
            f"Train Loss: {total_loss / len(train_loader):.4f} | "
            f"Val Loss: {val_loss:.4f} | "
            f"Val Accuracy: {val_accuracy:.4f}"
        )
        
        if val_accuracy > best_accuracy:
            best_accuracy = val_accuracy
            torch.save(model.state_dict(), MODEL_PATH)
            logger.info(f"Saved new best model with accuracy {best_accuracy:.4f}")
    
    return True

if __name__ == '__main__':
    train_model()
