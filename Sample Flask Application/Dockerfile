# syntax=docker/dockerfile:1

FROM python:3.10-alpine

WORKDIR /python-docker

COPY requirements.txt requirements.txt
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

COPY . /python-docker

CMD ["python3", "main.py"]