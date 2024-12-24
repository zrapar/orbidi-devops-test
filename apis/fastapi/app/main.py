from fastapi import FastAPI, HTTPException
import boto3
import psycopg2
from psycopg2.extras import RealDictCursor
import logging
import os

app = FastAPI()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

SECRET_NAME = os.getenv("SECRET_NAME", "fast-api-db")
REGION_NAME = os.getenv("AWS_REGION", "us-east-1")

db_connection = None

def get_secret():
    try:
        client = boto3.client("secretsmanager", region_name=REGION_NAME)
        response = client.get_secret_value(SecretId=SECRET_NAME)
        secret_string = response.get("SecretString")

        if secret_string:
            return eval(secret_string)
        else:
            raise ValueError("No valid value")
    except Exception as e:
        logger.error(f"Error getting secret from aws: {e}")
        raise

def connect_to_db():
    global db_connection
    try:
        secret = get_secret()
        db_connection = psycopg2.connect(
            host=secret["HOST"],
            database=secret["NAME"],
            user=secret["USER"],
            password=secret["PASS"],
            port=secret["PORT"],
            cursor_factory=RealDictCursor
        )
        logger.info("Successfully DB Connection")
    except Exception as e:
        logger.error(f"Error connecting to db: {e}")
        raise

@app.on_event("startup")
async def startup_event():
    logger.info("Starting application...")

@app.on_event("shutdown")
async def shutdown_event():
    global db_connection
    logger.info("Closing application...")
    if db_connection:
        db_connection.close()
        logger.info("DB Connection closed successfully.")

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/health")
def health():
    return {"status": "ok", "message": "Service is healthy."}

@app.get("/check-secret")
def check_secret():
    try:
        secret = get_secret()
        logger.info(f"secret {secret}")
        logger.info(f"SECRET_NAME {SECRET_NAME}")
        logger.info(f"REGION_NAME {REGION_NAME}")
        return {"status": "ok", "message": "Secret Health"}
    except Exception as e:
        return {"status": "error", "message": "Secret Unhealthy"}

@app.get("/check-db")
def check_db():
    try:
        connect_to_db()
        return {"status": "ok", "message": "DB Health"}
    except Exception as e:
        return {"status": "error", "message": "DB Unhealthy"}
        
    