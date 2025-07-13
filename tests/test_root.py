from api import api

def test_root_alive():
    client = api.test_client()
    res = client.get("/")
    assert res.status_code == 200
    assert "Order Fulfillment API is Running!" in res.get_data(as_text=True)

