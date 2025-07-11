from flask import Flask, request, jsonify
import json
from InvoiceGenerator.InvoiceGenerator import lambda_handler as invoice_handler
from order_validation.order_validation import lambda_handler as validation_handler
from OrderStatusTracking.OrderStatusTracking import lambda_handler as tracking_handler
from ShippingSuggestion.ShippingSuggestion import lambda_handler as shipping_handler

api = Flask(__name__)

@api.route('/')
def home():
    return """
    <html>
        <head>
            <title>Order Fulfillment API</title>
            <style>
                body { font-family: sans-serif; background-color: #f9f9f9; padding: 40px; }
                h1 { color: #333; }
                code { background: #eee; padding: 4px 6px; border-radius: 4px; }
                a { color: #007bff; text-decoration: none; }
            </style>
        </head>
        <body>
            <h1>🚀 Order Fulfillment API is Running!</h1>
            <p>Welcome to the microservice hub for validation, invoices, shipping suggestions, and tracking.</p>
            <h3>Available Endpoints:</h3>
            <ul>
                <li><code>POST /order_validation</code></li>
                <li><code>POST /invoiceGenerator</code></li>
                <li><code>POST /ShippingSuggestion</code></li>
                <li><code>POST /OrderStatusTracking</code></li>
            </ul>
            <p>See the <a href="https://github.com/Stefodan21/Order_fullfillment_Project" target="_blank">GitHub repository</a> for usage details.</p>
        </body>
    </html>
    """

@api.route('/order_validation', methods=['POST'])
def validate():
    event = {'body': request.json}
    print("Received validation request:", request.json)
    result = validation_handler(event, None)
    return jsonify(json.loads(result['body'])), result['statusCode']

@api.route('/invoiceGenerator', methods=['POST'])
def gen_invoice():
    event = {"body": request.json}
    result = invoice_handler(event, None)
    return jsonify(json.loads(result['body'])), result['statusCode']

@api.route('/ShippingSuggestion', methods=['POST'])
def shipping_suggestion():
    event = {'body': request.json}
    result = shipping_handler(event, None)
    return jsonify(json.loads(result['body'])), result['statusCode']


@api.route('/OrderStatusTracking', methods=['POST'])
def track_status():
    event = {'body': request.json}
    result = tracking_handler(event, None)
    return jsonify(json.loads(result['body'])), result['statusCode']


if __name__ == '__main__':
    api.run(debug=True)