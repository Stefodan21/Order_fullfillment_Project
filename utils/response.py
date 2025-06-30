import json

def response(status_code, body_dict):
    """
    Formats a standard Lambda-style HTTP response.

    Args:
        status_code (int): The HTTP status code (e.g. 200, 400).
        body_dict (dict): A dictionary that will be JSON-stringified as the response body.

    Returns:
        dict: A Lambda-compatible response object.
    """
    return {
        'statusCode': status_code,
        'body': json.dumps(body_dict)
    }
