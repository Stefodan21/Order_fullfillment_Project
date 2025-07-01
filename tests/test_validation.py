import json
from api import api  # import your Flask app

def test_validate_order_success():
    client = api.test_client()
    payload = {
        "payment": {
            "status": "success"
        }
    }
    response = client.post(
        "/order_validation",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 200
    data = response.get_json()
    assert data["message"] == "Order validation completed"

def test_validate_order_failure():
    client = api.test_client()
    payload = {
        "payment": {
            "status": "failed"
        }
    }
    response = client.post(
        "/order_validation",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 402
    data = response.get_json()
    assert data["error"] == "Payment failed"
