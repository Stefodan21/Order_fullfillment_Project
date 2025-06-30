import json
from utils.parser import parse_event_body
from utils.response import response

def lambda_handler(event, _):
    # Parse input from API Gateway (assumes JSON body)
    body = parse_event_body(event)
    if not body:
        return response(400, {'error': 'Invalid input'})
   
    # Extracting order details from the body    
    payment_info = body.get("payment", {})
    payment_status = payment_info.get("status", "Failed").lower()  # Default to 'Failed' if not provided

    if payment_status == "success":
        # Process the order
        print("Payment successful. Order validation completed")
        return response(200, {'message': 'Order validation completed'})
    else:
        # Handles payment failure
        print("Payment failed. Order failed")
        return response(402, {'error': 'Payment failed'})
        
    