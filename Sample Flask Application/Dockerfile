FROM python:3.11-alpine

ADD . .

RUN pip install -r requirements.txt

CMD ["flask", "--app", "main", "run" ]