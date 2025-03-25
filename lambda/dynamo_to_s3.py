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
            return {"statusCode": 200, "body": "Keine Daten zum Exportieren gefunden."}

        # Dateiname mit Zeitstempel
        timestamp = datetime.datetime.utcnow().strftime('%Y-%m-%dT%H-%M-%S')
        filename = f"{table_name}_export_{timestamp}.json"

        # Upload in S3
        s3.put_object(
            Bucket=bucket_name,
            Key=filename,
            Body=json.dumps(items, cls=DecimalEncoder),
            ContentType='application/json'
        )

        return {
            "statusCode": 200,
            "body": f"{len(items)} Datensätze exportiert nach {filename} im Bucket {bucket_name}"
        }

    except Exception as e:
        return {"statusCode": 500, "body": f"Fehler: {str(e)}"}
