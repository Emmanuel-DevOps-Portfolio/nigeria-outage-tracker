import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from datetime import datetime, timedelta
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])
threshold = int(os.environ['ALERT_THRESHOLD'])
lambda_client = boto3.client('lambda')

def lambda_handler(event, context):
    try:
        records = event.get('Records', [])
        print(f"Records received: {len(records)}")

        if not records:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No records to process'})
            }

        record = records[0]
        new_image = record.get('dynamodb', {}).get('NewImage', {})
        lga = new_image.get('lga', {}).get('S', '')
        print(f"LGA detected: {lga}")

        if not lga:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No LGA found in record'})
            }

        two_hours_ago = (datetime.utcnow() - timedelta(hours=2)).isoformat()
        print(f"Querying from: {two_hours_ago}")

        response = table.query(
            KeyConditionExpression=Key('PK').eq(f'LGA#{lga}') &
                                   Key('SK').gte(f'REPORT#{two_hours_ago}'),
            FilterExpression='#s = :active',
            ExpressionAttributeNames={'#s': 'status'},
            ExpressionAttributeValues={':active': 'active'}
        )

        report_count = len(response['Items'])
        print(f"Report count for {lga}: {report_count} | Threshold: {threshold}")

        alert_message = (
            f"OUTAGE ALERT: {report_count} reports received from "
            f"{lga} LGA in the last 2 hours. "
            f"Outage type: {new_image.get('outage_type', {}).get('S', 'unknown')}. "
            f"Reported at {datetime.utcnow().strftime('%H:%M UTC')}."
        )

        if report_count >= threshold:
            print(f"Threshold hit! Invoking Alert Lambda for {lga}")
            lambda_client.invoke(
                FunctionName='outage-alert',
                InvocationType='Event',
                Payload=json.dumps({
                    'lga': lga,
                    'report_count': report_count,
                    'alert_message': alert_message
                })
            )
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'alert': True,
                    'lga': lga,
                    'report_count': report_count,
                    'alert_message': alert_message
                })
            }
        else:
            print(f"Threshold not hit. {report_count} of {threshold} required.")
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'alert': False,
                    'lga': lga,
                    'report_count': report_count,
                    'alert_message': ''
                })
            }

    except Exception as e:
        print(f"ERROR: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
