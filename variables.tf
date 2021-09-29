# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."
  type        = string
  default     = "us-east-1"
}

variable "lambda_payload_filename" {
  default = "./hello-world-function/target/HelloWorld-1.0.jar"
}

variable "lambda_auth_payload_filename" {
  default = "./authorizer-function/target/HelloWorldAuthorizer-1.0.jar"
}

variable "app_domain" {
  default = "gradapprev-qa.apps.asu.edu"
}

variable "lambda_runtime" {
  default = "java8.al2"
}