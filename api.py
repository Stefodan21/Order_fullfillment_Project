from flask import Flask, request, jsonify
from InvoiceGenerator.InvoiceGenerator import lambda_handler as invoice_handler
from order_validation.order_validation import lambda_handler as validation_handler
from OrderStatusTracking.OrderStatusTracking import lambda_handler as tracking_handler
from ShippingSuggestion.ShippingSuggestion import lambda_handler as shipping_handler

api = Flask(__name__)

@api.route('/order_validation', methods=[])