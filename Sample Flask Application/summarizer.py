from transformers import T5Tokenizer, T5ForConditionalGeneration
import requests
from bs4 import BeautifulSoup


def extract_text_from_url(url: str) -> str:
    raw_page_code = requests.get(url)
    text_from_code = BeautifulSoup(raw_page_code.content, "html.parser")
    paragraphs = text_from_code.find_all("p")
    text = " ".join([p.get_text() for p in paragraphs])
    return text


def summerize_text(input_text: str) -> str:
    model_name = "t5-small"
    tokenizer = T5Tokenizer.from_pretrained(model_name)
    model = T5ForConditionalGeneration.from_pretrained(model_name)
    inputs = tokenizer.encode("summarize: " + input_text, return_tensors="pt", max_length=1024, truncation=True)
    summary_ids = model.generate(inputs, max_length=150, min_length=50, length_penalty=2.0, num_beams=4,
                                 early_stopping=True)

    summary = tokenizer.decode(summary_ids[0], skip_special_tokens=True)
    return summary
