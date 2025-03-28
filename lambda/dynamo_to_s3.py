import boto3
import json
import os
import datetime
from decimal import Decimal

# Hilfsklasse, um Decimals in JSON serialisierbar zu machen
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return float(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    s3 = boto3.client('s3')

    # Umgebungsvariablen
    table_name = os.environ.get('DYNAMODB_TABLE')
    bucket_name = os.environ.get('S3_BUCKET')

    if not table_name or not bucket_name:
        return {"statusCode": 500, "body": "Fehlende Umgebungsvariablen"}

    table = dynamodb.Table(table_name)

    try:
        response = table.scan()
        items = response.get('Items', [])

        if not items:
            print("Scan erfolgreich, aber keine Items gefunden.")
            return {"statusCode": 200, "body": "Keine Daten zum Exportieren gefunden."}

        print(f"{len(items)} Items aus DynamoDB gelesen: {items[:3]}...")  # Nur die ersten 3 anzeigen

        # Dateiname mit Zeitstempel
        timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H-%M-%S')
        filename = f"{table_name}_export_{timestamp}.json"

        # Zeilenweises Schreiben im JSONL-Stil (line-delimited JSON)
        json_lines = "\n".join(json.dumps(item, cls=DecimalEncoder) for item in items)

        s3.put_object(
            Bucket=bucket_name,
            Key = f"keyvalue/{filename}",
            Body=json_lines,
            ContentType='application/json'
        )
        print(f"Datei {filename} erfolgreich in {bucket_name} geschrieben.")

        return {
            "statusCode": 200,
            "body": f"{len(items)} Datensätze exportiert nach {filename} im Bucket {bucket_name}"
        }

    except Exception as e:
        return {"statusCode": 500, "body": f"Fehler: {str(e)}"}
