import json
from tracking_numbers import get_tracking_number
from utils.parser import parse_event_body
from utils.response import response


def lambda_handler(event, context):
    """
    AWS Lambda function that validates a tracking number
    and provides carrier information using `tracking-numbers`.
    """
    body = parse_event_body(event)
    if not body:
        return response(400, {'error': 'Invalid input'})


    tracking_number = body.get("tracking_number")
    if not tracking_number or not isinstance(tracking_number, str):
        return response(400, {'error': 'Missing tracking number'})


    # Get carrier details using tracking-numbers library
    try:
        tracking_info = get_tracking_number(tracking_number)
    except Exception as e:
        return response(500, {'error': 'Failed to process tracking number', 'details': str(e)})

    if not tracking_info:
        return response(404, {'error': 'Tracking number not found or unrecognized'}) 

    # Prepare response with extracted details
    order_status = {
        "tracking_number": tracking_number,
        "carrier": tracking_info.courier.name if tracking_info.courier else "Unknown",
        "tracking_url": getattr(tracking_info, 'tracking_url', "N/A")
    }

    return response(200, order_status)