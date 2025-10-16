provider "aws" {
    region = "us-east-2"
    profile = "default"
}

############################################################
# 2 Rol de ejecución (IAM Role) para la Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  # Política que permite a Lambda asumir este rol
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

############################################################
# 3 Adjuntar políticas predefinidas al rol IAM
# Permite a la Lambda escribir logs en CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Permite a la Lambda recibir y borrar mensajes SQS
resource "aws_iam_role_policy_attachment" "lambda_sqs_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

# Permite a la Lambda publicar mensajes en SNS
resource "aws_iam_role_policy_attachment" "lambda_sns_exec" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

############################################################
# 4️ Cola SQS donde llegarán los mensajes
resource "aws_sqs_queue" "loan_decision_queue" {
  name = "loan-decision-queue"

  # Tiempo que otro consumidor debe esperar antes de volver a recibir un mensaje no procesado
  visibility_timeout_seconds = 30
}

############################################################
# 5️ Función Lambda: notification-loan-decision
resource "aws_lambda_function" "notification_loan_decision" {
  function_name = "notification-loan-decision"
  runtime       = "python3.9"
  handler       = "handler.lambda_handler"

  # Ruta relativa al ZIP generado en el contenedor Docker
  filename         = "../lambdas/notification_loan_decision.zip"
  source_code_hash = filebase64sha256("../lambdas/notification_loan_decision.zip")

  # Rol IAM que la Lambda utilizará
  role = aws_iam_role.lambda_exec.arn

  # Variables de entorno que la Lambda puede usar
  environment {
    variables = {
      TOPIC_ARN = "arn:aws:sns:us-east-2:484558640369:loan-decision-topic"
    }
  }
}

############################################################
# 6️ Permitir que SQS invoque la Lambda
resource "aws_lambda_permission" "allow_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.notification_loan_decision.function_name
  principal     = "sqs.amazonaws.com"
  source_arn    = aws_sqs_queue.loan_decision_queue.arn
}

############################################################
# 7️ Vincular la cola SQS con la Lambda
resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.loan_decision_queue.arn
  function_name    = aws_lambda_function.notification_loan_decision.arn
  batch_size       = 1
  enabled          = true
}

############################################################
# 8️ Output: mostrar URL de la cola SQS
output "sqs_result_queue_url" {
  value = aws_sqs_queue.loan_decision_queue.url
  description = "URL pública de la cola SQS loan-decision-queue"
}
