/**********************************************************
 ***************  LAMBDA HELLO WORLD FUNCTION ***************
***********************************************************/
resource "aws_lambda_function" "hello_world" {
  function_name    = "HelloWorld"
  runtime          = "java8.al2"
  filename         = "./hello-world-function/target/HelloWorld-1.0.jar"
  source_code_hash = filebase64sha256("./hello-world-function/target/HelloWorld-1.0.jar")
  handler          = "helloworld.App::handleRequest"
  timeout          = 15
  memory_size      = 128
  role             = aws_iam_role.hello_lambda_role.arn
}

resource "aws_cloudwatch_log_group" "hello_world" {
  name              = "/aws/lambda/${aws_lambda_function.hello_world.function_name}"
  retention_in_days = 3
}

resource "aws_lambda_permission" "apigw_event_lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.hello_world.arn
  principal     = "apigateway.amazonaws.com"
  # How much can we restrict this for just this endpoint and function?
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}



resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.hello_lambda_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_role" "hello_lambda_role" {
  name               = "role_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}