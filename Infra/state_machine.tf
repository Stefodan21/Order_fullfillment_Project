// Step Functions state machine for order fulfillment workflow
// Orchestrates Lambda functions for validation, invoice generation, shipping, and tracking
resource "aws_sfn_state_machine" "OrderFullfillment" {
  name     = "${var.project_name}-${var.environment}"
  role_arn = aws_iam_role.StepFunctionExecutionRole.arn

  definition = <<EOF
{
  "StartAt": "OrderValidation",
  "States": {
    "OrderValidation": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.validate_order.arn}",
      "Next": "InvoiceGeneration"
    },
    "InvoiceGeneration": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.generate_invoice.arn}",
      "Next": "ShippingRecommendation"
    },
    "ShippingRecommendation": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.shipping_suggestion.arn}",
      "Next": "StatusTracking"
    },
    "StatusTracking": {
      "Type": "Task",
      "Resource": "${aws_lambda_function.order_status_tracking.arn}",
      "End": true
    }
  }
}
EOF
}
