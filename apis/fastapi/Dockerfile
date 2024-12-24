FROM --platform=linux/x86_64 python:3.11-alpine
WORKDIR /code
COPY ./requirements.txt /code/requirements.txt
RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt
COPY ./app /code/app
EXPOSE 8000
CMD ["fastapi", "run", "app/main.py", "--port", "8000"]