import json
from api import api  # assuming api.py is in the root

def test_shipping_suggestion_success():
    client = api.test_client()
    payload = {
        "tracking_number": "1Z12345E0205271688",
        "weight": 8.5,
        "destination": "Kingston"
    }
    response = client.post(
        "/ShippingSuggestion",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 200
    data = response.get_json()
    assert "carrier" in data
    assert "suggestion" in data
    assert "method" in data["suggestion"]
    assert "estimated_cost" in data["suggestion"]

def test_shipping_missing_field():
    client = api.test_client()
    payload = {
        "tracking_number": "TRACK123XYZ",
        "weight": 8.5
    }
    response = client.post(
        "/ShippingSuggestion",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 400
    assert "error" in response.get_json()
