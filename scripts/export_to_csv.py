import csv
import boto3
import random
from datetime import datetime, timedelta

# Einstellungen
FILENAME = "data/csv/fact_appointments.csv"
S3_BUCKET = "dataforge-model-storage"
S3_KEY = "csv/fact_appointments.csv"
NUM_RECORDS = 600

# Zufallsbasierte Faktendaten erzeugen
def generate_fact_appointments(n=NUM_RECORDS):
    records = []
    for i in range(1, n + 1):
        appointment_id = i
        patient_id = random.randint(1000, 1050)
        treatment_id = random.randint(1, 10)
        dentist_id = random.randint(1, 5)
        appointment_date = (datetime.now() - timedelta(days=random.randint(0, 90))).date().isoformat()
        total_cost = round(random.uniform(50.0, 500.0), 2)
        insurance_coverage = round(total_cost * random.uniform(0.4, 0.9), 2)
        patient_payment = round(total_cost - insurance_coverage, 2)

        records.append({
            "appointment_id": appointment_id,
            "patient_id": patient_id,
            "treatment_id": treatment_id,
            "dentist_id": dentist_id,
            "appointment_date": appointment_date,
            "total_cost": total_cost,
            "insurance_coverage": insurance_coverage,
            "patient_payment": patient_payment
        })
    return records

# CSV schreiben
def write_csv(records, filename=FILENAME):
    with open(filename, mode="w", newline="") as file:
        writer = csv.DictWriter(file, fieldnames=[
            "appointment_id", "patient_id", "treatment_id", "dentist_id",
            "appointment_date", "total_cost", "insurance_coverage", "patient_payment"
        ])
        writer.writeheader()
        writer.writerows(records)
    print(f"✅ CSV-Datei erstellt: {filename}")

# Upload nach S3
def upload_to_s3(filename, bucket, key):
    s3 = boto3.client("s3")
    with open(filename, "rb") as f:
        s3.upload_fileobj(f, bucket, key)
    print(f"☁️  Datei nach S3 hochgeladen: s3://{bucket}/{key}")

if __name__ == "__main__":
    data = generate_fact_appointments()
    write_csv(data)
    upload_to_s3(FILENAME, S3_BUCKET, S3_KEY)
