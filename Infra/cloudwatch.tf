// CloudWatch dashboard for monitoring Lambda invocations
// Provides visibility into function usage and performance
resource "aws_cloudwatch_dashboard" "cloudwatchMonitoring" {
    dashboard_name = "OrderProcessingMonitoring"
    dashboard_body = <<EOF
    {
        "widgets": [
            // Lambda function metrics: start_workflow
            {
                "type": "metric",
                "x": 0,
                "y": 0,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.start_workflow.function_name}" ],
                        [ "AWS/Lambda", "Errors", "FunctionName", "${aws_lambda_function.start_workflow.function_name}" ],
                        [ "AWS/Lambda", "Duration", "FunctionName", "${aws_lambda_function.start_workflow.function_name}" ],
                        [ "AWS/Lambda", "Throttles", "FunctionName", "${aws_lambda_function.start_workflow.function_name}" ],
                        [ "AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${aws_lambda_function.start_workflow.function_name}" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${var.region}",
                    "title": "Start Workflow Lambda Metrics"
                }
            },
            // Lambda function metrics: validate_order
            {
                "type": "metric",
                "x": 6,
                "y": 0,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.validate_order.function_name}" ],
                        [ "AWS/Lambda", "Errors", "FunctionName", "${aws_lambda_function.validate_order.function_name}" ],
                        [ "AWS/Lambda", "Duration", "FunctionName", "${aws_lambda_function.validate_order.function_name}" ],
                        [ "AWS/Lambda", "Throttles", "FunctionName", "${aws_lambda_function.validate_order.function_name}" ],
                        [ "AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${aws_lambda_function.validate_order.function_name}" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${var.region}",
                    "title": "Validate Order Lambda Metrics"
                }
            },
            // Lambda function metrics: generate_invoice
            {
                "type": "metric",
                "x": 0,
                "y": 6,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.generate_invoice.function_name}" ],
                        [ "AWS/Lambda", "Errors", "FunctionName", "${aws_lambda_function.generate_invoice.function_name}" ],
                        [ "AWS/Lambda", "Duration", "FunctionName", "${aws_lambda_function.generate_invoice.function_name}" ],
                        [ "AWS/Lambda", "Throttles", "FunctionName", "${aws_lambda_function.generate_invoice.function_name}" ],
                        [ "AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${aws_lambda_function.generate_invoice.function_name}" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${var.region}",
                    "title": "Generate Invoice Lambda Metrics"
                }
            },
            // Lambda function metrics: shipping_suggestion
            {
                "type": "metric",
                "x": 6,
                "y": 6,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.shipping_suggestion.function_name}" ],
                        [ "AWS/Lambda", "Errors", "FunctionName", "${aws_lambda_function.shipping_suggestion.function_name}" ],
                        [ "AWS/Lambda", "Duration", "FunctionName", "${aws_lambda_function.shipping_suggestion.function_name}" ],
                        [ "AWS/Lambda", "Throttles", "FunctionName", "${aws_lambda_function.shipping_suggestion.function_name}" ],
                        [ "AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${aws_lambda_function.shipping_suggestion.function_name}" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${var.region}",
                    "title": "Shipping Suggestion Lambda Metrics"
                }
            },
            // Lambda function metrics: order_status_tracking
            {
                "type": "metric",
                "x": 12,
                "y": 0,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/Lambda", "Invocations", "FunctionName", "${aws_lambda_function.order_status_tracking.function_name}" ],
                        [ "AWS/Lambda", "Errors", "FunctionName", "${aws_lambda_function.order_status_tracking.function_name}" ],
                        [ "AWS/Lambda", "Duration", "FunctionName", "${aws_lambda_function.order_status_tracking.function_name}" ],
                        [ "AWS/Lambda", "Throttles", "FunctionName", "${aws_lambda_function.order_status_tracking.function_name}" ],
                        [ "AWS/Lambda", "ConcurrentExecutions", "FunctionName", "${aws_lambda_function.order_status_tracking.function_name}" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${var.region}",
                    "title": "Order Status Tracking Lambda Metrics"
                }
            },
            // S3 bucket metrics
            {
                "type": "metric",
                "x": 7,
                "y": 0,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/S3", "NumberOfObjects", "BucketName", "invoicestorage-ofp", "StorageType", "AllStorageTypes" ],
                        [ "AWS/S3", "BucketSizeBytes", "BucketName", "invoicestorage-ofp", "StorageType", "StandardStorage" ]
                    ],
                    "period": 86400,
                    "stat": "Average",
                    "region": "${var.region}",
                    "title": "${var.project_name} ${var.environment} Invoice Storage S3 Metrics"
                }
            },
            // DynamoDB metrics
            {
                "type": "metric",
                "x": 0,
                "y": 7,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/DynamoDB", "ConsumedReadCapacityUnits", "TableName", "OrderDetails" ],
                        [ "AWS/DynamoDB", "ConsumedWriteCapacityUnits", "TableName", "OrderDetails" ],
                        [ "AWS/DynamoDB", "SuccessfulRequestLatency", "TableName", "OrderDetails" ]
                    ],
                    "period": 300,
                    "stat": "Average",
                    "region": "${var.region}",
                    "title": "${var.project_name} ${var.environment} OrderDetails DynamoDB Metrics"
                }
            },
            // Step Functions metrics
            {
                "type": "metric",
                "x": 7,
                "y": 7,
                "width": 6,
                "height": 6,
                "properties": {
                    "metrics": [
                        [ "AWS/States", "ExecutionsStarted", "StateMachineArn", "${aws_sfn_state_machine.OrderFullfillment.arn}" ],
                        [ "AWS/States", "ExecutionsSucceeded", "StateMachineArn", "${aws_sfn_state_machine.OrderFullfillment.arn}" ],
                        [ "AWS/States", "ExecutionsFailed", "StateMachineArn", "${aws_sfn_state_machine.OrderFullfillment.arn}" ]
                    ],
                    "period": 300,
                    "stat": "Sum",
                    "region": "${var.region}",
                    "title": "${var.project_name} ${var.environment} Step Functions Metrics"
                }
            }
        ]
    }
    EOF
}