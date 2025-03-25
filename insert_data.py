import boto3
import json
import random
import time
from datetime import datetime, timezone
from decimal import Decimal
import argparse

# DynamoDB Ressourcen konfigurieren
dynamodb = boto3.resource('dynamodb')

# Tabellen referenzieren
table_structured = dynamodb.Table('DataForge_Structured')
table_json = dynamodb.Table('DataForge_JSON')
table_kv = dynamodb.Table('DataForge_KeyValue')


def generate_random_data(num_records=10):
    """Generiert zufällige Datensätze für die drei Tabellen."""
    data = []
    for i in range(num_records):
        id = f"{i+1:03}" #ID im Format 001, 002 usw
        timestamp = int(time.time()) # aktuelle unix-timestamp
        sensor_value = Decimal(str(round(random.uniform(20.0, 30.0), 1))) #Decimal-Typ verwenden
        status = random.choice(["OK", "WARNING", "ERROR"]) #zufälliger Status
        user = random.choice(["Vadim", "Alice", "Bob"]) #zufällige User
        action = random.choice(["Login", "Logout", "Upload", "Download"]) #zufällige Action
        data.append({
            "structured": {
                "ID": id,
                "Timestamp": timestamp,
                "SensorValue": sensor_value,
                "Status": status
            },
            "json": {
                "PK": f"event_{i+100}",  # neue event IDs
                "Data": json.dumps({"User": user, "Action": action, "Time": datetime.now(tz=timezone.utc).isoformat()})
            },
            "kv": {
                "Key": f"config_{i+1}", # neue Keys
                "Value": f"1.0.{i+3}" # neue Versionsnummer
            }
        })
    return data


def write_data_to_dynamodb(data):
    """Schreibt die Daten in die DynamoDB-Tabellen."""
    for record in data:
        try:
            table_structured.put_item(Item=record['structured'])
            table_json.put_item(Item=record['json'])
            table_kv.put_item(Item=record['kv'])
            print(f"Record written successfully: {record}")
        except Exception as e:
            print(f"Error writing record: {e}")

def parse_arguments():
    parser = argparse.ArgumentParser(description="Daten in DynamoDB einfügen")
    parser.add_argument("--records", type=int, default=10, help="Anzahl der zu erzeugenden Datensätze")
    parser.add_argument("--table", choices=["all", "structured", "json", "kv"], default="all", help="Zieltabellen")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    random_data = generate_random_data(num_records=args.records)
    
    for record in random_data:
        try:
            if args.table in ["all", "structured"]:
                table_structured.put_item(Item=record['structured'])
            if args.table in ["all", "json"]:
                table_json.put_item(Item=record['json'])
            if args.table in ["all", "kv"]:
                table_kv.put_item(Item=record['kv'])
            print(f"Record written: {record}")
        except Exception as e:
            print(f"Error writing record: {e}")

    print("Data insertion completed.")
