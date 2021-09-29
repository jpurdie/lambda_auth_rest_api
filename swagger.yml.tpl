openapi: 3.0.0
servers: []
info:
  description: This is a simple API
  version: "1.0.0"
  title: Simple Hello World API
paths:
  /hello:
    post:
      tags:
        - hello
      summary: says hello world
      operationId: addInventory
      description: says hello world
      security:
        - helloAuthorizerDemo: []
      responses:
        200:
          description: Default response for CORS method
          headers:
            Access-Control-Allow-Origin:
              schema:
                type: string
            Access-Control-Allow-Methods:
              schema:
                type: string
            Access-Control-Allow-Headers:
              schema:
                type: string
          content: {}
      x-amazon-apigateway-integration:
        httpMethod: "POST"
        uri: ${helloworld_invoke}
        responses:
          default:
            statusCode: "200"
            responseParameters:
              method.response.header.Access-Control-Allow-Origin: "'*'"
        passthroughBehavior: "when_no_match"
        contentHandling: "CONVERT_TO_TEXT"
        type: "aws"
components:
  securitySchemes:
    helloAuthorizerDemo:
      type: "apiKey"
      name: "Authorization"
      in: "header"
      x-amazon-apigateway-authtype: "custom"
      x-amazon-apigateway-authorizer:
        authorizerUri: ${authorizer_invoke}
        authorizerCredentials: ${authorizer_cred}
        type: "token"
        identitySource: "method.request.header.Authorization"
        authorizerResultTtlInSeconds: 0