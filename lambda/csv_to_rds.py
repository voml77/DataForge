import json
import boto3
import csv
import pymysql
import os
from io import StringIO
import logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

S3_BUCKET = os.environ['S3_BUCKET']
CSV_KEY = os.environ['CSV_KEY']  # z. B. 'csv/fact_appointments.csv'

def lambda_handler(event, context):
    secretsmanager = boto3.client('secretsmanager')
    secret_name = os.environ.get('RDS_SECRET_NAME')
    if not secret_name:
        logger.warning("Environment variable 'RDS_SECRET_NAME' not set. Using default secret name.")
        secret_name = "dataforge/rds/credentials"
    logger.info(f"Versuche Secret {secret_name} zu laden...")

    try:
        secret_response = secretsmanager.get_secret_value(SecretId=secret_name)
        logger.info("Secret erfolgreich geladen.")
    except Exception as e:
        logger.error(f"Fehler beim Laden des Secrets: {e}")
        raise e

    secret = json.loads(secret_response['SecretString'])

    required_keys = ['host', 'username', 'password', 'dbname']
    if not all(k in secret for k in required_keys):
        raise KeyError(f"Secret {secret_name} fehlt ein oder mehrere notwendige Felder: {required_keys}")

    RDS_HOST = secret['host']
    RDS_USER = secret['username']
    RDS_PASSWORD = secret['password']
    RDS_DB_NAME = secret['dbname']

    s3 = boto3.client('s3')
    logger.info("Lambda-Handler gestartet.")
    try:
        response = s3.get_object(Bucket=S3_BUCKET, Key=CSV_KEY)
        logger.info(f"CSV-Datei {CSV_KEY} erfolgreich aus dem Bucket {S3_BUCKET} geladen.")
        content = response['Body'].read().decode('utf-8')
        logger.info(f"CSV-Inhalt:\n{content}")
        csv_reader = csv.reader(StringIO(content))
        headers = next(csv_reader)  # Kopfzeile überspringen

        connection = pymysql.connect(
            host=RDS_HOST,
            user=RDS_USER,
            password=RDS_PASSWORD,
            database=RDS_DB_NAME,
            connect_timeout=30
        )
        logger.info(f"Verbindung zur RDS-Datenbank {RDS_DB_NAME} hergestellt.")

        with connection.cursor() as cursor:
            insert_stmt = """
                INSERT INTO fact_appointments (
                    appointment_id, patient_id, treatment_id, dentist_id,
                    appointment_date, total_cost, insurance_coverage, patient_payment
                )
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """
            rows_inserted = 0
            for row in csv_reader:
                logger.info(f"Einfügen von Zeile: {row}")
                cursor.execute(insert_stmt, row)
                rows_inserted += 1
            logger.info(f"Insgesamt eingefügte Zeilen: {rows_inserted}")
            connection.commit()

        return {
            'statusCode': 200,
            'body': f"{rows_inserted} records inserted successfully."
        }

    except Exception as e:
        logger.error(f"Fehler aufgetreten: {str(e)}")
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
