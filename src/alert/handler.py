import json
import boto3
import os

sns = boto3.client('sns', region_name='eu-west-1')
TOPIC_ARN = os.environ['ALERT_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])
        alert_message = body.get('alert_message', '')
        lga = body.get('lga', '')
        report_count = body.get('report_count', 0)

        if not alert_message:
            return {
                'statusCode': 200,
                'body': json.dumps({'message': 'No alert message provided'})
            }

        sns.publish(
            TopicArn=TOPIC_ARN,
            Subject=f"⚡ Power Outage Alert — {lga} LGA",
            Message=alert_message
        )

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Alert sent successfully',
                'lga': lga,
                'report_count': report_count
            })
        }

    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
