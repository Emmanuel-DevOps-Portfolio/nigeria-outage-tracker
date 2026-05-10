import json
import boto3
import uuid
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('OutageEvents')

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        required = ['lga', 'state', 'outage_type']
        for field in required:
            if field not in body:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': f'Missing field: {field}'})
                    }

        report = {
            'PK': f'LGA#{body["lga"]}',
            'SK': f'REPORT#{datetime.utcnow().isoformat()}',
            'report_id': str(uuid.uuid4()),
            'lga': body['lga'],
            'state': body['state'],
            'outage_type': body['outage_type'],
            'notes': body.get('notes', ''),
            'status': 'active',
            'timestamp': datetime.utcnow().isoformat(),
            'ttl': int(datetime.utcnow().timestamp()) + (90 * 24 * 3600)
        }

        table.put_item(Item=report)

        return {
            'statusCode': 201,
            'body': json.dumps({
                'message': 'Report submitted successfully',
                'report_id': report['report_id']
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
