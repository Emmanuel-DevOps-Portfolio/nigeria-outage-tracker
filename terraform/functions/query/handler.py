import json
import boto3
import os
from boto3.dynamodb.conditions import Key

dynamodb = boto3.resource("dynamodb")
TABLE_NAME = os.environ["TABLE_NAME"]
table = dynamodb.Table(TABLE_NAME)  # type: ignore


def lambda_handler(event, context):
    try:
        params = event.get("queryStringParameters") or {}
        lga = params.get("lga")
        state = params.get("state")

        # Query by LGA
        if lga:
            response = table.query(
                KeyConditionExpression=Key("LGA").eq(lga)
            )
            items = response.get("Items", [])

        # Query by state using GSI
        elif state:
            response = table.query(
                IndexName="StateIndex",
                KeyConditionExpression=Key("state").eq(state)
            )
            items = response.get("Items", [])

        # Return all recent reports (scan — use sparingly)
        else:
            response = table.scan(Limit=50)
            items = response.get("Items", [])

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            },
            "body": json.dumps({
                "count": len(items),
                "reports": items
            }, default=str)
        }

    except Exception as e:
        print(f"Error querying outage data: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": "Internal server error"})
        }