/**********************************************************
 ***************  API GATEWAY  ***************
***********************************************************/

variable "stage_name" {
  default = "dev"
  type    = string
}

resource "aws_api_gateway_rest_api" "api" {
  name = "hello-world-api-gateway"
  body = templatefile(
    "swagger.yml.tpl",
    {
      app_domain        = "gradapprev-qa.apps.asu.edu"
      helloworld_invoke = aws_lambda_function.hello_world.invoke_arn,
      authorizer_invoke = aws_lambda_function.hello_world_authorizer.invoke_arn
      authorizer_cred   = aws_iam_role.invocation_role.arn
    }
  )
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "apideploy" {
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }
  lifecycle {
    create_before_destroy = true
  }
  rest_api_id = aws_api_gateway_rest_api.api.id
}


resource "aws_api_gateway_stage" "api" {
  deployment_id = aws_api_gateway_deployment.apideploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.stage_name
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigwauthorizer" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world_authorizer.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}



output "base_url" {
  value = aws_api_gateway_deployment.apideploy.invoke_url
}


resource "aws_api_gateway_method_settings" "example" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled    = true
    logging_level      = "INFO"
    data_trace_enabled = true
  }
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api.id}/${var.stage_name}"
  retention_in_days = 3
  # ... potentially other configuration ...
}

