---
swagger: "2.0"
info:
  description: "API for Hello World"
  version: "1.0"
  title: "hello world"
host: "${app_domain}"
schemes:
- "https"
paths:
  /hello:
    post:
      produces:
      - "application/json"
      responses:
        "200":
          description: "200 response"
          schema:
            $ref: "#/definitions/Empty"
          headers:
            Access-Control-Allow-Origin:
              type: "string"
      security:
      - helloAuthorizer: []
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
securityDefinitions:
  helloAuthorizer:
    type: "apiKey"
    name: "Authorization"
    in: "header"
    x-amazon-apigateway-authtype: "custom"
    x-amazon-apigateway-authorizer:
      authorizerUri: ${authorizer_invoke}
      authorizerCredentials: ${authorizer_cred}
      type: "request"
      identitySource: "method.request.header.Authorization"
      authorizerResultTtlInSeconds: 0

