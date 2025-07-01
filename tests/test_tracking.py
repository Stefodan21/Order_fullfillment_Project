import json
from api import api

def test_tracking_success():
    client = api.test_client()
    payload = {
        "tracking_number": "1Z12345E0205271688"
    }
    response = client.post(
        "/OrderStatusTracking",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code in [200, 404]
    assert "carrier" in response.get_json()

def test_tracking_invalid_input():
    client = api.test_client()
    payload = {
        "tracking": "missing_key"
    }
    response = client.post(
        "/OrderStatusTracking",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 400
    assert "error" in response.get_json()
