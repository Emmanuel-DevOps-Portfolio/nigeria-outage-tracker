import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from datetime import datetime, timedelta
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])
threshold = int(os.environ['ALERT_THRESHOLD'])

def lambda_handler(event, context):
    try:
        records = event.get('Records', [])

        if not records:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No records to process'})
            }

        record = records[0]
        new_image = record.get('dynamodb', {}).get('NewImage', {})
        lga = new_image.get('lga', {}).get('S', '')

        if not lga:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No LGA found in record'})
            }

        two_hours_ago = (datetime.utcnow() - timedelta(hours=2)).isoformat()

        response = table.query(
            KeyConditionExpression=Key('PK').eq(f'LGA#{lga}') &
                                   Key('SK').gte(f'REPORT#{two_hours_ago}'),
            FilterExpression='#s = :active',
            ExpressionAttributeNames={'#s': 'status'},
            ExpressionAttributeValues={':active': 'active'}
        )

        report_count = len(response['Items'])

        alert_message = (
            f"OUTAGE ALERT: {report_count} reports received from "
            f"{lga} LGA in the last 2 hours. "
            f"Outage type: {new_image.get('outage_type', {}).get('S', 'unknown')}. "
            f"Reported at {datetime.utcnow().strftime('%H:%M UTC')}."
        )

        if report_count >= threshold:
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
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
