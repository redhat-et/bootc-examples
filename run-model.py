import os
import time
from transformers import T5Tokenizer, T5ForConditionalGeneration

class TimerError(Exception):
    """A custom exception used to report errors in use of Timer class"""

class Timer:
    def __init__(self):
        self._start_time = None

    def __enter__(self):
        if self._start_time is not None:
            raise TimerError(f"Timer is running. Use .stop() to stop it")
        self._start_time = time.perf_counter()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        if self._start_time is None:
            raise TimerError(f"Timer is not running. Use .start() to start it")
        elapsed_time = time.perf_counter() - self._start_time
        self._start_time = None
        print(f"Elapsed time: {elapsed_time:0.4f} seconds")

# Initialize the tokenizer with legacy=False
tokenizer = T5Tokenizer.from_pretrained("lmsys/fastchat-t5-3b-v1.0", legacy=False)

# Initialize the model
model = T5ForConditionalGeneration.from_pretrained("lmsys/fastchat-t5-3b-v1.0")

def generate_text(prompt):
    input_ids = tokenizer.encode(prompt, return_tensors="pt")
    output = model.generate(input_ids, max_length=1000)
    return tokenizer.decode(output[0], skip_special_tokens=True)

# Prompt for user input
user_prompt = input("Please ask me anything: ")

with Timer():
    generated_text = generate_text(user_prompt)
    print("\nAnswer:")
    print(generated_text)

