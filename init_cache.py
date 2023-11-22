# cache_init.py
from transformers import AutoModel, AutoTokenizer

model_name = "lmsys/fastchat-t5-3b-v1.0"
AutoTokenizer.from_pretrained(model_name)
AutoModel.from_pretrained(model_name)
