import json
import boto3
import os

sns = boto3.client('sns', region_name='eu-west-1')
TOPIC_ARN = os.environ['ALERT_TOPIC_ARN']

def lambda_handler(event, context):
    try:
        print(f"Event received: {json.dumps(event)}")

        # Handle both direct invocation and API Gateway
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            body = event

        alert_message = body.get('alert_message', '')
        lga = body.get('lga', '')
        report_count = body.get('report_count', 0)

        print(f"LGA: {lga} | Count: {report_count} | Message: {alert_message}")

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

        print(f"Alert sent successfully for {lga}")

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Alert sent successfully',
                'lga': lga,
                'report_count': report_count
            })
        }

    except Exception as e:
        print(f"ERROR: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
