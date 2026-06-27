import json
import boto3
import os
from datetime import datetime, timezone
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")

TABLE_NAME = os.environ["TABLE_NAME"]
SNS_TOPIC_ARN = os.environ["SNS_TOPIC_ARN"]

table = dynamodb.Table(TABLE_NAME)  # type: ignore


def lambda_handler(event, context):
    try:
        today = datetime.now(timezone.utc).strftime("%Y-%m-%d")

        # Scan for all reports today
        response = table.scan(
            FilterExpression="begins_with(#ts, :today)",
            ExpressionAttributeNames={"#ts": "timestamp"},
            ExpressionAttributeValues={":today": today}
        )

        items = response.get("Items", [])

        if not items:
            print("No outage reports found for today")
            return {"statusCode": 200, "body": "No reports today"}

        # Group reports by state
        state_counts = {}
        for item in items:
            state = item.get("state", "Unknown")
            state_counts[state] = state_counts.get(state, 0) + 1

        # Build summary message
        summary_lines = [
            f"Daily Outage Summary for {today}",
            f"Total reports: {len(items)}",
            "",
            "Reports by state:"
        ]

        for state, count in sorted(state_counts.items(),
                                   key=lambda x: x[1],
                                   reverse=True):
            summary_lines.append(f"  {state}: {count} report(s)")

        summary = "\n".join(summary_lines)

        # Publish daily summary to SNS
        sns.publish(
            TopicArn=SNS_TOPIC_ARN,
            Subject=f"Daily Outage Summary — {today}",
            Message=summary
        )

        print(f"Daily summary published: {len(items)} reports across "
              f"{len(state_counts)} states")

        return {
            "statusCode": 200,
            "body": json.dumps({
                "total_reports": len(items),
                "states_affected": len(state_counts),
                "summary": summary
            })
        }

    except Exception as e:
        print(f"Error generating daily summary: {str(e)}")
        raise e