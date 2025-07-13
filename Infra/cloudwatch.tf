// CloudWatch dashboard for monitoring Lambda invocations
// Provides visibility into function usage and performance
resource "aws_cloudwatch_dashboard" "cloudwatchMonitoring" {
    dashboard_name = "OrderProcessingMonitoring"
    dashboard_body = <<EOF
    {
        "widgets": [
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "${aws_lambda_function.validate_order.arn}", "Invocations" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${us-east-1}",
                    "title": "Lambda Invocations"
                }
            }
        ]
    }
    EOF
}