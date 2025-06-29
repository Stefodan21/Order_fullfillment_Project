from flask import Flask, request, jsonify
import json
from InvoiceGenerator.InvoiceGenerator import lambda_handler as invoice_handler
from order_validation.order_validation import lambda_handler as validation_handler
from OrderStatusTracking.OrderStatusTracking import lambda_handler as tracking_handler
from ShippingSuggestion.ShippingSuggestion import lambda_handler as shipping_handler

api = Flask(__name__)

@api.route('/order_validation', methods=['POST'])
def validate():
    event = {'body': request.json}
    print("Received validation request:", request.json)
    result = validation_handler(event, None)
    return jsonify(json.loads(result['body'])), result['statusCode']

@api.route('/invoiceGenerator', methods=['GET'])
def gen_invoice():
    event = {"body": request.json}
    return jsonify(invoice_handler(event, None))

@api.route('/ShippingSuggestion', methods=['POST'])
def shipping_suggestion():
    event = {'body': request.json}
    return jsonify(shipping_handler(event, None))

@api.route('/OrderStatusTracking', methods=['POST'])
def track_status():
    event = {'body': request.json}
    return jsonify(tracking_handler(event, None))

if __name__ == '__main__':
    api.run(debug=True)