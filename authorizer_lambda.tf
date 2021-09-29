/**********************************************************
 ***************  LAMBDA HELLO WORLD AUTHORIZER  ***************
***********************************************************/

resource "aws_api_gateway_authorizer" "helloAuthorizer" {
  name                   = "helloAuthorizer"
  rest_api_id            = aws_api_gateway_rest_api.api.id
  authorizer_uri         = aws_lambda_function.hello_world_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.invocation_role.arn
  type                   = "REQUEST"
}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.hello_world_authorizer.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda" {
  name = "demo-lambda"

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

resource "aws_lambda_function" "hello_world_authorizer" {
  function_name    = "HelloWorldAuthorizer"
  runtime          = "java8.al2"
  filename         = "./authorizer-function/target/HelloWorldAuthorizer-1.0.jar"
  source_code_hash = filebase64sha256("./authorizer-function/target/HelloWorldAuthorizer-1.0.jar")
  handler          = "authorizer.Authorizer::handleRequest"
  timeout          = 15
  memory_size      = 128
  //s3_bucket        = aws_s3_bucket.lambda_bucket.id
  //s3_key           = aws_s3_bucket_object.lambda_hello_world.key
  role = aws_iam_role.lambda.arn
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/hello_world_authorizer"
  retention_in_days = 3
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs_auth" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}