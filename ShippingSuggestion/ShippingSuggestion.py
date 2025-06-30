import json
from tracking_numbers import get_tracking_number
from utils.parser import parse_event_body
from utils.response import response

def lambda_handler(event, context):

    """
    AWS Lambda function that generates a shipping suggestion based on the provided tracking number.
    """
    body = parse_event_body(event)
    if not body:
        return response(400, {'error': 'Invalid input'})
    
    if "tracking_number" not in body:
        return response(400, {'error': 'Missing tracking number'})
  
    tracking_number = body["tracking_number"]
    if not tracking_number or not isinstance(tracking_number, str):
        return response(400, {'error': 'Invalid or missing tracking number'})
        
    weight = body.get("weight")
    if not weight or not isinstance(weight, (int, float)):
        return response(400, {'error': 'Invalid or missing weight'})
        
    destination = body.get("destination")
    if not destination or not isinstance(destination, str):
        return response(400, {'error': 'Invalid or missing destination'})
    # Validate tracking number
    tracking_info = get_tracking_number(tracking_number)
    carrier = tracking_info.courier.name if tracking_info and tracking_info.courier else "Unknown"

            # Get shipping suggestion
    shipping_suggestion = suggest_shipping_method(weight, destination, carrier)

    return {
            'statusCode': 200,
            'body': json.dumps({
                "tracking_number": tracking_number,
                "carrier": carrier,
                "tracking_url": getattr(tracking_info, 'tracking_url', "N/A"),
                "weight": weight,
                "destination": destination,
                "suggestion": shipping_suggestion
        })
    }
    
def suggest_shipping_method(weight, destination, carrier):
    """
    Determines the best shipping method based on weight, destination, and carrier.
    """
    if carrier in ["UPS", "FedEx"]:
        method = "Express Shipping"
        cost = 30
    elif carrier == "USPS":
        method = "Standard Postal Delivery"
        cost = 15
    else:
        method = "Generic Carrier Shipping"
        cost = 20

    if weight > 10:
        method = "Freight"
        cost += 20  # Adjust cost for heavy shipments

    return {"method": method, "estimated_cost": cost}

