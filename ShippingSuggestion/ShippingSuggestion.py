import json
from tracking_numbers import get_tracking_number

def lambda_handler(event, context):

    """
    AWS Lambda function that generates a shipping suggestion based on the provided tracking number.
    """
    try:
        # Safely parse JSON body
        body = json.loads(event.get('body', '{}'))

    except json.JSONDecodeError as e:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid JSON input', 'details': str(e)})
        }
    if "tracking_number" not in body:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Missing "tracking_number" key in the request body'})
        }   
    tracking_number = body["tracking_number"]
    if not tracking_number or not isinstance(tracking_number, str):
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid or missing tracking number'})
        }
    weight = body.get("weight")
    if not weight or not isinstance(weight, (int, float)):
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid or missing weight'})
        }
    destination = body.get("destination")
    if not destination or not isinstance(destination, str):
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid or missing destination'})
        }
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

