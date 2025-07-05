import boto3
from datetime import datetime
import uuid
from fpdf import FPDF
import io
import json
from utils.parser import parse_event_body
from utils.response import response
from boto3.dynamodb.conditions import Key
import os

# This script generates an invoice in PDF format and stores it in an S3 bucket
# This function is used to place an invoice in the S3 bucket and update the DynamoDB table


def lambda_handler(event, context):
    
    # gets input from event parser (assumes JSON body)
    body = parse_event_body(event)
    if not body:
        return response(400, {'error': 'Invalid input'})
# ... other parsing logic

    customer_name = body.get('customer_name', 'Unknown')  # Default to 'Unknown' if not provided
    customer_address = body.get('customer_address', 'Unknown')
    business_name = body.get('business_name', 'Unknown')
    item_bought = body.get('item_purchased','Unknown') # Default to 'Unknown' if not provided
    item_price = body.get('item_price', 0) # Default to 0 if not provided
    item_quantity = body.get('item_quantity', 1)
    status = body.get('status', 'pending')  # Default to 'pending' if not provided
    
    # Initialize AWS resources
    s3 = boto3.resource('s3')
    dynamodb = boto3.resource('dynamodb')
    bucket_name = 'invoicestorage-ofp'
    table_name = 'OrderDetails'
    table = dynamodb.Table(table_name)
    # It generates a unique order ID, invoice number, and timestamp, and stores them in the DynamoDB table
    invnum = str(uuid.uuid4())
    OrderID = str(uuid.uuid4())
    orderedAt = str(datetime.now().isoformat() + "Z")

    item = {
        'customer_name': customer_name, # The name of the customer
        'order_id': OrderID,      # The unique ID for this order
        'OrderedAt': orderedAt,   # The timestamp when the order was created
        # 'Arrived': status,      # (Optional) Status of the order, currently commented out
    }

    table.put_item(Item=item)    # It retrieves the latest item from the table and constructs the invoice file name
    # gets the latest item from the DynamoDB table
    try:
        dbresponse = table.query(
        KeyConditionExpression=Key("order_id").eq(OrderID),
        ScanIndexForward=False,
        Limit=1,
        ConsistentRead=True
        )
        items = dbresponse.get("Items", [])
        latest_item = items[0] if items else item  # fallback to inserted item
    except Exception as e:
        print(f"Error: Fallback to inserted item. {e}")
        latest_item = item



    invoice_file_name_str = f"invoice_{latest_item['order_id']}_{latest_item['OrderedAt']}.pdf"
    invoice_file_path = f"{bucket_name}/{invoice_file_name_str}"  # Path in S3 bucket
    # Creates a PDF file for the invoice
    pdf = FPDF( orientation="portrait",
        unit="mm",
        format="A4")  
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    # Adds content to the PDF
    pdf.cell(200, 10, txt=f"Invoice from: {business_name}", ln=True, align='C')
    # A unique invoice number
    pdf.cell(200, 10, txt=f"Invoice Number: {invnum}", ln=True)
    pdf.cell(200, 10, txt=f"Order ID: {latest_item['order_id']}", ln=True)
    pdf.cell(200, 10, txt=f"Ordered At: {latest_item['OrderedAt']}", ln=True)
    pdf.cell(200, 10, txt="Thank you for your order!", ln=True)
    # Your business name and contact information
    # Name and address of the client
    pdf.cell(200, 10, txt=f"Customer Name: {customer_name}", ln=True)
    pdf.cell(200, 10, txt=f"Customer Address: {customer_address}", ln=True)
    # Invoice items , amoount and their prices
    pdf.cell(200, 10, txt=f"Item Purchased: {item_bought}", ln=True)
    pdf.cell(200, 10, txt=f"Item Price: ${item_price:.2f}", ln=True)
    pdf.cell(200, 10, txt=f"Item Quantity: {item_quantity}", ln=True)
    pdf.cell(200, 10, txt=f"Total Amount: ${item_price * item_quantity:.2f}", ln=True)
    pdf.cell(200, 10, txt=" ", ln=True)  # Blank line
    
    # Adding a folder to test the create of tghe inovice pdf
    # Create the folder if it doesn’t exist
    output_dir = "invoices"
    os.makedirs(output_dir, exist_ok=True)
    # Save the PDF to that folder
    file_path = os.path.join(output_dir, f"invoice.pdf")
    pdf.output(file_path)
    print(f"Invoice saved to: {file_path}")
    

    # ✅ Generate PDF as a string and wrap in BytesIO
    pdf_bytes = pdf.output(dest='S').encode('latin1')  # 'latin1' ensures compatibility
    pdf_buffer = io.BytesIO(pdf_bytes)


    # Upload the PDF to S3
    try:
        s3.Bucket(bucket_name).put_object(
            Key=invoice_file_path,
            Body=pdf_buffer.getvalue(),
            ContentType='application/pdf'
        )
        print(f"Invoice uploaded to S3: {bucket_name}/{invoice_file_path}")
    except Exception as e:
        print(f"Error: Unable to upload the invoice to S3. {e}")
        return response(500, {'error': 'Failed to upload invoice to S3'})

    return response(200, {'message': 'Invoice generated and uploaded successfully', 'invoice_path': invoice_file_path})





