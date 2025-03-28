import torch
from transformers import DistilBertTokenizer, DistilBertForSequenceClassification
from transformers import Trainer, TrainingArguments
from datasets import load_dataset
import logging
import numpy as np
from sklearn.model_selection import train_test_split

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize tokenizer
tokenizer = DistilBertTokenizer.from_pretrained('distilbert-base-uncased')

def tokenize_function(examples):
    return tokenizer(examples["text"], padding="max_length", truncation=True)

def train_model():
    # Load custom conversation dataset
    dataset = load_dataset('json', data_files='./model/dataset/sample_conversations.json')
    
    # Split into train/test (80/20)
    dataset = dataset['train'].train_test_split(test_size=0.2)
    
    # Create label mappings
    labels = list(set(dataset['train']['label']))
    num_labels = len(labels)
    
    # Preprocess data
    def preprocess_function(examples):
        return tokenizer(examples["text"], truncation=True, padding="max_length")
    
    tokenized_datasets = dataset.map(preprocess_function, batched=True)
    small_train_dataset = tokenized_datasets["train"]
    small_eval_dataset = tokenized_datasets["test"]
    
    # Initialize model with dynamic label count
    model = DistilBertForSequenceClassification.from_pretrained(
        "distilbert-base-uncased", 
        num_labels=num_labels,
        id2label={i: label for i, label in enumerate(labels)},
        label2id={label: i for i, label in enumerate(labels)}
    )
    
    # Training arguments
    training_args = TrainingArguments(
        output_dir="./results",
        evaluation_strategy="epoch",
        learning_rate=2e-5,
        per_device_train_batch_size=16,
        per_device_eval_batch_size=16,
        num_train_epochs=3,
        weight_decay=0.01,
    )
    
    # Train
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=small_train_dataset,
        eval_dataset=small_eval_dataset,
    )
    
    trainer.train()
    model.save_pretrained("./model/checkpoints")
    tokenizer.save_pretrained("./model/checkpoints")
    logger.info("Model training complete and saved to ./model/checkpoints")

if __name__ == "__main__":
    train_model()