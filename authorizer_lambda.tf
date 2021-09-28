/**********************************************************
 ***************  LAMBDA HELLO WORLD AUTHORIZER  ***************
***********************************************************/
resource "aws_api_gateway_authorizer" "helloAuthorizerDemo" {
  name                   = "helloAuthorizerDemo"
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







//
//resource "aws_lambda_permission" "apigw_authorizer_lambda_permission" {
//  statement_id  = "AllowExecutionFromAPIGateway"
//  action        = "lambda:InvokeFunction"
//  function_name = aws_lambda_function.hello_world_authorizer.arn
//  principal     = "apigateway.amazonaws.com"
//  # How much can we restrict this for just this endpoint and function?
//  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
//}
//
//resource "aws_iam_role" "authorizer_lambda_role" {
//  name               = "gradapprev-authorizer_lambda_role"
//  description        = "IAM role for ortn authorizer lambda function in ${terraform.workspace}"
//  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
//}
//
//resource "aws_cloudwatch_log_group" "hello_world_authorizer" {
//  name              = "/aws/lambda/${aws_lambda_function.hello_world_authorizer.function_name}"
//  retention_in_days = 3
//}
//
//resource "aws_iam_role_policy_attachment" "authorizer_lambda_vpc_policy_attachment" {
//  role       = aws_iam_role.authorizer_lambda_role.name
//  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
//}
//
//
//# Try to store this here centrally for use in all lambda functions.
//data "aws_iam_policy_document" "lambda_assume_role_policy" {
//  version = "2012-10-17"
//  statement {
//    sid     = ""
//    effect  = "Allow"
//    actions = ["sts:AssumeRole"]
//
//    principals {
//      type        = "Service"
//      identifiers = ["lambda.amazonaws.com"]
//    }
//  }
//}