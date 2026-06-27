import json
import boto3
import os
from datetime import datetime, timezone

dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")

TABLE_NAME = os.environ["TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]
ALERT_THRESHOLD = int(os.environ.get("ALERT_THRESHOLD", "3"))

table = dynamodb.Table(TABLE_NAME) # type: ignore

def lambda_handler(event, context):
    for record in event["Records"]:
        try:
            report = json.loads(record["body"])

            # Calculate TTL — 90 days from now
            ttl = int(datetime.now(timezone.utc).timestamp()) + (90 * 24 * 60 * 60)

            # Write to DynamoDB
            table.put_item(
                Item={
                    "LGA": report["lga"],
                    "timestamp": report["timestamp"],
                    "state": report["state"],
                    "reporter_name": report["reporter_name"],
                    "description": report["description"],
                    "report_id": report["report_id"],
                    "status": "received",
                    "expiry": ttl
                }
            )

            # Check how many reports exist for this LGA today
            today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
            response = table.query(
                KeyConditionExpression="LGA = :lga AND begins_with(#ts, :today)",
                ExpressionAttributeNames={"#ts": "timestamp"},
                ExpressionAttributeValues={
                    ":lga": report["lga"],
                    ":today": today
                }
            )

            report_count = response["Count"]

            # Send SNS alert if threshold exceeded
            if report_count >= ALERT_THRESHOLD:
                sns.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Subject=f"Power Outage Alert: {report['lga']}, {report['state']}",
                    Message=(
                        f"Power outage alert for {report['lga']}, {report['state']}.\n\n"
                        f"{report_count} reports received today.\n\n"
                        f"Latest report: {report['description']}\n"
                        f"Reported by: {report['reporter_name']}\n"
                        f"Time: {report['timestamp']}"
                    )
                )

        except Exception as e:
            print(f"Error processing record: {str(e)}")
            raise e

    return {"statusCode": 200}