import json


def lambda_handler(event, _):
    # Parse input from API Gateway (assumes JSON body)
    try:
        if isinstance(event.get("body"), str):
            body = json.loads(event["body"])
        else:
            body = event.get("body", {})


    except (KeyError, json.JSONDecodeError) as e:
        print(f"Error: Unable to parse input. {e}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid input'})
        }
    
    # Extracting order details from the body    
    payment_info = body.get("payment", {})
    payment_status = payment_info.get("status", "Failed").lower()  # Default to 'Failed' if not provided

    if payment_status == "success":
        # Process the order
        print("Payment successful. Order validation completed")
        return {
    'statusCode': 200,
    'body': json.dumps({'message': 'Order validation completed'})
    }
    else:
        # Handles payment failure
            print("Payment failed. Order failed")
            return {
        'statusCode': 402,
        'body': json.dumps({'error': 'Payment failed'})
            }
    