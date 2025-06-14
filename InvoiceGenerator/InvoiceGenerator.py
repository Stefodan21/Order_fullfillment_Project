import boto3
from datetime import datetime
import uuid
from fpdf import FPDF
import io
import json

# This script generates an invoice in PDF format and stores it in an S3 bucket
# This function is used to place an invoice in the S3 bucket and update the DynamoDB table

def lambda_handler(event, context):
    
    # Parse input from API Gateway (assumes JSON body)
    try:
        body = json.loads(event['body'])
        status = body.get('status', 'Pending')  # Default to 'Pending' if not provided
    except (KeyError, json.JSONDecodeError) as e:
        print(f"Error: Unable to parse input. {e}")
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid input'})
        }
    
    customer_name = body.get('customer_name', 'Unknown')  # Default to 'Unknown' if not provided
    customer_address = body.get('customer_address', 'Unknown')
    business_name = body.get('business_name', 'Unknown')
    item_bought = body.get('item_purchased','Unknown') # Default to 'Unknown' if not provided
    item_price = body.get('item_price', 0) # Default to 0 if not provided
    item_quantity = body.get('item_quantity', 1) # Default to 1 if not provided

    # Initialize AWS resources
    s3 = boto3.resource('s3')
    dynamodb = boto3.resource('dynamodb')
    bucket_name = 'invoicestorage'
    table_name = 'OrderDetails'
    table = dynamodb.Table(table_name)

    # It generates a unique order ID, invoice number, and timestamp, and stores them in the DynamoDB table
    invnum = str(uuid.uuid4())
    OrderID = str(uuid.uuid4())
    orderedAt = str(datetime.now().isoformat() + "Z")

    item = {
        'order_id': OrderID,      # The unique ID for this order
        'OrderedAt': orderedAt,   # The timestamp when the order was created
        # 'Arrived': status,      # (Optional) Status of the order, currently commented out
    }

    table.put_item(Item=item)

    # It retrieves the latest item from the table and constructs the invoice file name
    # gets the latest item from the DynamoDB table
    try:
        response = table.query(
            IndexName='OrderedAt-index',  # Use the index to query by OrderedAt
            ScanIndexForward=False,      # Retrieve items in descending order
            Limit=1                      # Limit to the most recent item
        )
        if 'Items' in response and response['Items']:
            latest_item = response['Items'][0]
        else:
            latest_item = None
    except Exception as e:
        print(f"Error: Unable to find the latest item in the table. {e}")
        latest_item = None

    if not latest_item:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Could not retrieve latest order'})
        }

    invoice_file_name_str = f"invoice_{latest_item['order_id']}_{latest_item['OrderedAt']}.pdf"
    invoice_file_path = f"invoicestorage/{invoice_file_name_str}"

    # Creates a PDF file for the invoice
    pdf = FPDF()  
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

    # Save PDF to a bytes buffer
    pdf_buffer = io.BytesIO()
    pdf.output(pdf_buffer)
    pdf_buffer.seek(0)

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
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Failed to upload invoice to S3'})
        }

    return {
        'statusCode': 200,
        'body': json.dumps({'message': 'Invoice generated and uploaded successfully', 'invoice_path': invoice_file_path})
    }





