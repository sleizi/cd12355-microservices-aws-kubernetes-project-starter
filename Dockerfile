# FROM python:3.9.19-slim
FROM public.ecr.aws/docker/library/python:3.10-slim-buster

COPY . /app
WORKDIR /app
COPY . .

RUN pip install --upgrade pip
RUN pip install -r analytics/requirements.txt

EXPOSE 5153

CMD ["python", "analytics/app.py"]