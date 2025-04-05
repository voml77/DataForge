# 🛠️ DataForge – Automatisierte Datenpipeline mit Terraform & AWS 🚀

**DataForge** ist ein Infrastructure-as-Code-Projekt, das eine skalierbare, serverlose Datenpipeline auf AWS erstellt – vollständig automatisiert mit Terraform und Python.

## 📌 Ziel
Daten automatisiert erfassen, speichern, transformieren – und das cloudbasiert, versionierbar und erweiterbar.

---

## ⚙️ Architekturübersicht

```text
+-------------+         +----------------+         +----------------+
| DynamoDB    |  --->   | AWS Lambda     |  --->   | S3-Bucket       |
| (Rohdaten)  |         | (Export)       |         | (Staging Layer) |
+-------------+         +----------------+         +----------------+
                                                         ↓
                                                  +------------------+
                                                  | AWS RDS (MySQL)  |
                                                  | (Persistenz)     |
                                                  +------------------+
                                                         ↓
                                                  +------------------+
                                                  | dbt-Modelle:     |
                                                  |  - fact_appointments |
                                                  |  - dim_patient        |
                                                  |  - dim_dentist        |
                                                  |  - dim_treatment      |
                                                  |  - appointment_financials |
                                                  |  - dim_date           |
                                                  +------------------+
                                                         ↓
                                                 [Power BI / QS]
```

---

## 🔧 Technologien

- **Terraform** – Infrastruktur als Code
- **AWS DynamoDB** – Speicherung strukturierter & semi-strukturierter Daten
- **AWS Lambda (Python)** – Datenexport & Integration
- **S3** – Staging Layer für strukturierte Daten
- **AWS RDS (MySQL)** – relationale Persistenz
- **dbt (Data Build Tool)** – Transformation & semantische Anreicherung
- **GitHub** – CI/CD & Versionierung
- **Power BI / QuickSight** – Visualisierung

---

## 🗂️ Projektstruktur

```
DataForge/
├── lambda/                 # Lambda-Code (Python)
│   ├── dynamo_to_s3.py
│   └── csv_to_rds.py
├── scripts/                # Jobs & Hilfsskripte
│   ├── export_to_csv.py
│   └── insert_data.py
├── data/                   # JSON/CSV-Testdaten
│   └── csv/
│       ├── fact_appointments.csv
│       └── structured_export.csv
├── terraform/              # Infrastruktur mit Terraform
│   ├── main.tf
│   ├── rds.tf
│   ├── iam.tf
│   ├── dynamodb.tf
│   ├── network.tf
│   └── ...
├── models/                 # dbt-Modelle für DWH
│   ├── appointment_financials.sql
│   ├── dim_patient.sql
│   ├── dim_dentist.sql
│   ├── dim_treatment.sql
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
- [x] Datenverarbeitung mit AWS Glue (frühere Implementierung – entfernt)
- [x] SQL-Persistenz mit AWS RDS (MySQL)
- [x] CSV zu Parquet (ehemals Glue Job) – wird neu gedacht
- [x] Datenintegration über Lambda in RDS (funktioniert, wird weiter verbessert)
- [x] Transformationen & Datenaufwertung mit dbt
- [x] Aufbau eines Mini-Data Warehouses (Fact & Dimensions)
- [x] Erstellung eines KPI-Views (appointment_financials) mit dbt
- [x] Visualisierung mit Power BI oder QuickSight
- [ ] CI/CD Pipeline mit GitHub Actions
- [ ] Visuelle Architektur-Doku (draw.io)
- [ ] Verbindung von QuickSight zur RDS über VPC-Verbindung finalisieren

### 🧭 Geplante Erweiterungen (Phase 2 – reloaded)

- Datenintegration via Lambda → RDS (statt Glue)
- Visualisierung mit Power BI oder QuickSight
- GitHub Actions für CI/CD Checks & Deployment

---

## 📊 Datenquellen & Formate

- **Structured:** Sensor-Messdaten (ID, Timestamp, Value, Status) → Parquet
- **JSON Events:** Benutzeraktionen (Login, Upload etc.) → Parquet
- **Key-Value Configs:** Versionen & Parameter → Parquet
- CSV-Dateien: Faktendaten zu Terminen (fact_appointments.csv) → Parquet → MySQL

Ursprünglich wurden alle Daten via AWS Glue katalogisiert – mittlerweile setzen wir auf einen schlanken Lambda→RDS Flow mit optionaler dbt-Transformation.

Zusätzlich wurde eine Data Warehouse-Schicht auf Basis der Faktentabelle `fact_appointments` modelliert, inklusive der Dimensionstabellen `dim_patient`, `dim_dentist`, `dim_treatment` sowie einer analytischen View `appointment_financials`.
Die Transformationen erfolgen über dbt und können modular erweitert werden.

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
🔁 Hinweis: Wenn du die RDS-Instanz später erneut aktivierst, prüfe:
- Ist sie wieder als „öffentlich zugänglich“ markiert (Publicly Accessible = Yes)?
- Ist die passende Inbound-Regel in der Security Group gesetzt (MySQL-Port 3306 für deine aktuelle IP)?

📌 Beachte: Nach dem Neustart der RDS-Instanz muss häufig erneut:
- „Publicly Accessible“ auf „Yes“ gesetzt werden
- Eine Inbound-Regel für deine aktuelle IP-Adresse freigegeben werden (Port 3306, TCP)