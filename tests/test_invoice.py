import json
from api import api

def test_generate_invoice_success():
    client = api.test_client()
    payload = {
        "customer_name": "Stefaan",
        "customer_address": "Jamaica",
        "business_name": "CloudSoft",
        "item_purchased": "Serverless Mastery",
        "item_price": 120,
        "item_quantity": 2,
        "status": "confirmed"
    }
    response = client.post(
        "/invoiceGenerator",
        data=json.dumps(payload),
        content_type="application/json"
    )
    assert response.status_code == 200
    data = response.get_json()
    assert "invoice_path" in data  # or check a message string

