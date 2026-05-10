# ⚡ Nigeria Power Outage Tracker

A serverless AWS application that allows Nigerian citizens to report, track, and receive alerts about power outages across all 774 LGAs in Nigeria.

## 🇳🇬 The Problem
Epileptic power supply is a daily reality for millions of Nigerians. No reliable system exists to report or track outages in real time. This project solves that.

## 🏗️ Architecture
Built entirely on AWS serverless services:

| Service | Role |
|---|---|
| API Gateway | Receives outage reports from citizens |
| Lambda (Ingest) | Validates and stores reports |
| Lambda (Query) | Fetches reports for the dashboard |
| Lambda (Aggregator) | Counts reports per LGA and checks threshold |
| Lambda (Alert) | Sends SNS email alerts to subscribers |
| DynamoDB | Stores all outage reports with 90-day TTL |
| SNS | Delivers email alerts to subscribers |
| EventBridge | Monitors DynamoDB streams |

## 🚀 API Endpoints

| Method | Endpoint | Description |
|---|---|---|
| POST | `/reports` | Submit an outage report |
| GET | `/reports` | Get all active outages |
| GET | `/reports?lga=Ikeja` | Get outages by LGA |
| POST | `/alert` | Send an alert to subscribers |

## 📦 Sample Report Payload
```json
{
  "lga": "Ikeja",
  "state": "Lagos",
  "outage_type": "total",
  "notes": "No light since 6am, no EKEDC notice"
}
```

## 🛠️ Prerequisites
- AWS CLI configured
- SAM CLI installed
- Python 3.12
- Docker

## ⚙️ Deploy

```bash
sam build
sam deploy --guided
```

## 🧪 Test

Submit a report:
```bash
curl -X POST <API_URL>/reports \
  -H "Content-Type: application/json" \
  -d '{"lga": "Ikeja", "state": "Lagos", "outage_type": "total"}'
```

Fetch all active outages:
```bash
curl <API_URL>/reports
```

## 💰 Cost
Runs on AWS free tier and pay-per-use pricing. At civic app scale, costs under $2/month.

## 👨🏾‍💻 Author
**Emmanuel Ulu** — DevOps/Cloud Engineer | AWS Community Builder 2026
- GitHub: [Emmanuel-DevOps-Portfolio](https://github.com/Emmanuel-DevOps-Portfolio)
- LinkedIn: [linkedin.com/in/emmanuelulu](https://linkedin.com/in/emmanuelulu)

## 📄 License
MIT
