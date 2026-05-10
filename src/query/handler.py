import json
import boto3
import os
from boto3.dynamodb.conditions import Key
from decimal import Decimal

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['TABLE_NAME'])

class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super().default(obj)

def lambda_handler(event, context):
    try:
        query_params = event.get('queryStringParameters') or {}
        lga = query_params.get('lga')

        if lga:
            response = table.query(
                KeyConditionExpression=Key('PK').eq(f'LGA#{lga}'),
                FilterExpression='#s = :active',
                ExpressionAttributeNames={'#s': 'status'},
                ExpressionAttributeValues={':active': 'active'}
            )
            items = response['Items']
        else:
            response = table.query(
                IndexName='StatusIndex',
                KeyConditionExpression=Key('status').eq('active')
            )
            items = response['Items']

        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'count': len(items),
                'reports': items
            }, cls=DecimalEncoder)
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
