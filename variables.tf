# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}


variable "lambda_payload_filename" {
  default = "./hello-world-function/target/HelloWorld-1.0.jar"
}

variable "lambda_function_handler" {
  default = "helloworld.App::handleRequest"
}

variable "lambda_runtime" {
  default = "java8.al2"
}