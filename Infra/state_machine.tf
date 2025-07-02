// workflow outline 
resource "aws_sfn_state_machine" "OrderFullfillment" {
    name = "OrderProcessing"
    role_arn = "arn:aws:iam::478517495734:role/Order_fullfillment_project_user.StepFunctionRole" //arn role for step function
    definition = <<EOF
    {
        "StartAt" : "OrderValidation",
        "States": {
            "OrderValidation": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.validate_order.arn}",
                "Next": "InvoiceGeneration"
            },
            "InvoiceGeneration": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.generate_invoice.arn}",
                "Next":"ShippingRecommendation"
            },
            "ShippingRecommendation": {
                "Type": "Task",
                "Resource": "${aws_lambda_function.shipping_suggestion.arn}",
                "Next":"StatusTracking",
            },
            "StatusTracking": {
                "Type": "Task"
                "Resource":"${aws_lambda_function.order_status_tracking.arn}",
                "End": true
            }
        }


    }
    EOF

}   