from api import api

def test_root_alive():
    client = api.test_client()
    res = client.get("/")
    assert res.status_code == 200
    assert b"Order Fulfillment API is running" in res.data
