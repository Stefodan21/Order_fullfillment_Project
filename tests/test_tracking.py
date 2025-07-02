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
def test_tracking_found():
    client = api.test_client()
    payload = {
        "tracking_number": "1Z12345E0205271688"
    }
    response = client.post(
        "/OrderStatusTracking",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 200
    assert "carrier" in response.get_json()

def test_tracking_not_found():
    client = api.test_client()
    payload = {
        "tracking_number": "NONEXISTENT123"
    }
    response = client.post(
        "/OrderStatusTracking",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 404
    data = response.get_json()
    assert "message" in data or "error" in data

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
