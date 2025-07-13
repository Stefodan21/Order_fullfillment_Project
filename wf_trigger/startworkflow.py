import boto3 
import json
import os

def lambda_handler(event, context):
    try:
        client = boto3.client('stepfunctions')
        response = client.start_execution(
            stateMachineArn=os.environ['STATE_MACHINE_ARN'],
            input=json.dumps(event)
        )
        return {
            "statusCode": 200,
            "body": json.dumps({
                "message": "Workflow started successfully", 
                "executionArn": response["executionArn"]
            })
        }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "message": "Failed to start workflow",
                "error": str(e)
            })
       }

