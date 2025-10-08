provider "aws" {
    region = "us-east-1"
}

resource "aws_lambda_function" "automatic_loan_validation" {
  function_name = "lambda-notificaciones"
  runtime       = "python3.9"
  handler       = "handler.lambda_handler"

  filename         = "../notificaciones.zip"
  source_code_hash = filebase64sha256("../notificaciones.zip")

  role = aws_iam_role.lambda_exec.arn
}