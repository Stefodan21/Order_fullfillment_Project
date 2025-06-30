import json
from tracking_numbers import get_tracking_number



def lambda_handler(event, context):
    """
    AWS Lambda function that validates a tracking number
    and provides carrier information using `tracking-numbers`.
    """
    try:
        # Safely parse JSON body
        body_content = event.get('body', '{}')
        if not isinstance(body_content, str):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Invalid body format, expected a JSON string'})
            }
        body = json.loads(body_content)
        if "tracking_number" not in body:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'Missing "tracking_number" key in the request body'})
            }
        tracking_number = body["tracking_number"]
    except json.JSONDecodeError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid JSON input', 'details': str(e)})
        }

    if not tracking_number or not isinstance(tracking_number, str):
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid or missing tracking number'})
        }

    # Get carrier details using tracking-numbers library
    try:
        tracking_info = get_tracking_number(tracking_number)
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to process tracking number', 'details': str(e)})
        }

    if not tracking_info:
        return {
        'statusCode': 404,
        'body': json.dumps({'error': 'Tracking number not found or unrecognized'})
        }


    # Prepare response with extracted details
    order_status = {
        "tracking_number": tracking_number,
        "carrier": tracking_info.courier.name if tracking_info.courier else "Unknown",
        "tracking_url": getattr(tracking_info, 'tracking_url', "N/A")
    }

    return {
        'statusCode': 200,
        'body': json.dumps(order_status)
    }

