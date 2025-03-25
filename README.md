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
├── insert_data.py          # Python-Skript für Testdaten
├── iam.tf                  # IAM-Rollen & Policies
├── lambda.tf               # Lambda Deployment
├── dynamodb.tf             # DynamoDB-Tabellen
├── outputs.tf              # (Optional) Outputs
├── variables.tf            # (Optional) Variablen
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

## 📅 Kommende Features

- [x] Infrastruktur mit Terraform
- [x] Datenexport mit Lambda
- [ ] Zeitbasierter Trigger via EventBridge
- [ ] Datenverarbeitung mit Glue
- [ ] Persistenz in SQL-DB (RDS / Redshift)
- [ ] CI/CD Pipeline (GitHub Actions)

---

## 🧠 Autor
**Vadim Ott** – Data Engineer in Progress 👨‍💻  
📍 München · GitHub: [@voml77](https://github.com/voml77)

---

## 📸 Screenshots / Diagramme (optional einfügen)

> ⚠️ Platzhalter – hier können später S3-Dateien, Terraform-Ausgaben, oder ein draw.io-Diagramm ergänzt werden.