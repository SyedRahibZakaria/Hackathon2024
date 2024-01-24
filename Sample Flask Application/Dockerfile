# syntax=docker/dockerfile:1

FROM python:3.10

WORKDIR /python-nlp

COPY requirements.txt requirements.txt
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY . /python-nlp

CMD ["python3", "main.py"]