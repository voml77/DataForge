import boto3
import os
import csv
import pymysql
from io import StringIO

# AWS-Konfiguration
region_name = "eu-central-1"
secret_name = "dataforge/rds/credentials"
s3_bucket = "dataforge-model-storage"
s3_key = "csv/fact_appointments.csv"

# Secrets abrufen
def get_db_credentials():
    client = boto3.client("secretsmanager", region_name=region_name)
    response = client.get_secret_value(SecretId=secret_name)
    secret = eval(response["SecretString"])  # Alternative: json.loads()
    return secret["username"], secret["password"]

# Verbindung zur RDS-Datenbank herstellen
def connect_to_rds(username, password):
    return pymysql.connect(
        host="dataforge-db.cpi0oiaymnc5.eu-central-1.rds.amazonaws.com",
        user=username,
        password=password,
        database="dataforge",
        cursorclass=pymysql.cursors.DictCursor
    )

# CSV aus S3 lesen
def read_csv_from_s3():
    s3 = boto3.client("s3", region_name=region_name)
    obj = s3.get_object(Bucket=s3_bucket, Key=s3_key)
    return csv.DictReader(StringIO(obj["Body"].read().decode("utf-8")))

# Daten einfügen
def insert_data(cursor, row):
    sql = """
        INSERT INTO fact_appointments (
            appointment_id, patient_id, treatment_id, dentist_id,
            appointment_date, total_cost, insurance_coverage, patient_payment
        )
        VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
    """
    values = (
        int(row["appointment_id"]),
        int(row["patient_id"]),
        int(row["treatment_id"]),
        int(row["dentist_id"]),
        row["appointment_date"],
        float(row["total_cost"]),
        float(row["insurance_coverage"]),
        float(row["patient_payment"])
    )
    cursor.execute(sql, values)

# Hauptfunktion
def main():
    username, password = get_db_credentials()
    connection = connect_to_rds(username, password)
    csv_rows = read_csv_from_s3()

    with connection:
        with connection.cursor() as cursor:
            for i, row in enumerate(csv_rows):
                print(f"Inserting row {i+1}: {row}")
                insert_data(cursor, row)
            connection.commit()
            print("✅ Daten erfolgreich eingefügt.")

if __name__ == "__main__":
    main()
