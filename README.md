# 🛠️ DataForge – Automatisierte Datenpipeline mit Terraform & AWS 🚀

**DataForge** ist ein Infrastructure-as-Code-Projekt, das eine skalierbare, serverlose Datenpipeline auf AWS erstellt – vollständig automatisiert mit Terraform und Python.

## 📌 Ziel
Daten automatisiert erfassen, speichern, transformieren – und das cloudbasiert, versionierbar und erweiterbar.

---

## ⚙️ Architekturübersicht

```text
+-------------+         +----------------+         +----------------+
| DynamoDB    |  --->   | AWS Lambda     |  --->   | S3-Bucket       |
| (Rohdaten)  |         | (Export)       |         | (Zwischenspeicher)|
+-------------+         +----------------+         +----------------+
                                                       ↓
                                                 +-------------+
                                                 | AWS Glue    |
                                                 | (optional)  |
                                                 +-------------+
                                                       ↓
                                                [SQL / Analytics]
```

---

## 🔧 Technologien

- **Terraform** – Infrastruktur als Code
- **AWS DynamoDB** – Speicherung strukturierter & semi-strukturierter Daten
- **AWS Lambda (Python)** – Exportservice in S3
- **S3** – JSON-Zwischenspeicher für Analyse
- **AWS Glue (optional)** – Datenaufbereitung
- **GitHub** – CI/CD & Versionierung

---

## 🗂️ Projektstruktur

```
DataForge/
├── lambda/                 # Lambda-Code (Python)
│   └── dynamo_to_s3.py
├── scripts/                # Glue-Jobs & CSV-Exporter
│   ├── glue_job.py
│   └── insert_data.py
├── data/                   # JSON/CSV-Testdaten
│   ├── structured_data.jsonl
│   ├── localfile.json
│   └── output.json
├── terraform/              # Infrastruktur mit Terraform
│   ├── main.tf
│   ├── glue.tf
│   ├── iam.tf
│   ├── dynamodb.tf
│   ├── ...
├── .gitignore
└── README.md
```

---

## 🚀 Erste Schritte

```bash
terraform init
terraform apply
```

📌 Testdaten einfügen:
```bash
python insert_data.py --records 10 --table all
```

---

## 📅 Fortschritt & Kommende Features

- [x] Infrastruktur mit Terraform
- [x] Datenexport mit AWS Lambda
- [x] Zeitbasierter Trigger via EventBridge
- [x] Datenverarbeitung mit AWS Glue (Datenkatalog)
- [x] Glue Jobs für Transformation (Parquet für Structured, JSON, Key-Value)
- [x] Datenabfrage mit Athena (JSON & Parquet)
- [x] SQL-Persistenz mit AWS RDS (MySQL)
- [x] CSV zu Parquet (Glue Job für fact_appointments.csv)
- [ ] CI/CD Pipeline mit GitHub Actions
- [ ] Visuelle Architektur-Doku (draw.io)

### 🔧 Geplante Erweiterungen (Phase 2)

- Direkter Glue Job Parquet → MySQL (RDS)
- CSV-basierte ETL-Pipeline mit Glue → RDS (bereit zur Umsetzung)
- Aufbau eines Mini-Data Warehouses (SQL)
- Visualisierung mit Power BI oder QuickSight
- GitHub Actions für CI/CD Checks & Deployment

---

## 📊 Datenquellen & Formate

- **Structured:** Sensor-Messdaten (ID, Timestamp, Value, Status) → Parquet
- **JSON Events:** Benutzeraktionen (Login, Upload etc.) → Parquet
- **Key-Value Configs:** Versionen & Parameter → Parquet
- CSV-Dateien: Faktendaten zu Terminen (fact_appointments.csv) → Parquet → MySQL

Alle Daten werden über AWS Glue katalogisiert und sind per Athena abfragbar.

--- 

## 🧠 Autor
**Vadim Ott** – Data Engineer in Progress 👨‍💻  
📍 München · GitHub: [@voml77](https://github.com/voml77)

---

## 📸 Screenshots / Diagramme (optional einfügen)

> ⚠️ Platzhalter – hier können später S3-Dateien, Terraform-Ausgaben, oder ein draw.io-Diagramm ergänzt werden.
> 🔧 Derzeit in Arbeit: draw.io-Diagramm zur End-to-End-Pipeline.

---

## 💸 Hinweis zu Kosten / Ressourcen

Die AWS RDS Instanz läuft dauerhaft, sofern sie nicht gestoppt oder gelöscht wird. Um unnötige Kosten zu vermeiden:

- Nutze möglichst die Free Tier-Größe (`db.t3.micro`) – bereits gewählt
- RDS verursacht Kosten **auch im Leerlauf** – ggf. regelmäßig stoppen
- Speicherplatz (z. B. 20 GB) wird ebenfalls berechnet

🔧 Empfehlung: Instanz manuell stoppen, wenn nicht aktiv verwendet (z. B. über die AWS Console)