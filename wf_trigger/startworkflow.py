import boto3, json

def lambda_handler(event, context):
    client = boto3.client('stepfunctions')
    response = client.start_execution(
        stateMachineArn="arn:aws:states:us-east-1:123456789012:stateMachine:OrderProcessing",
        input=json.dumps(event)
    )
    return {
        "statusCode": 200,
        "body": json.dumps({"message": "Workflow started", "executionArn": response["executionArn"]})
    }
