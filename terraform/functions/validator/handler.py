import json
import boto3
import os
import uuid
from datetime import datetime, timezone

sqs = boto3.client("sqs")
QUEUE_URL = os.environ["QUEUE_URL"]

REQUIRED_FIELDS = ["lga", "state", "reporter_name", "description"]

def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))
    except json.JSONDecodeError:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid JSON"})
        }

    # Validate required fields
    missing = [f for f in REQUIRED_FIELDS if not body.get(f)]
    if missing:
        return {
            "statusCode": 400,
            "body": json.dumps({
                "error": f"Missing required fields: {missing}"
            })
        }

    # Build outage report
    report = {
        "report_id": str(uuid.uuid4()),
        "lga": body["lga"].strip(),
        "state": body["state"].strip(),
        "reporter_name": body["reporter_name"].strip(),
        "description": body["description"].strip(),
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "status": "pending"
    }

    # Send to SQS
    sqs.send_message(
        QueueUrl=QUEUE_URL,
        MessageBody=json.dumps(report)
    )

    return {
        "statusCode": 202,
        "body": json.dumps({
            "message": "Outage report received",
            "report_id": report["report_id"]
        })
    }