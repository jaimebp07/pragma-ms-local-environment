provider "aws" {
    region = "us-east-2"
}

############################################################
# 1 Rol I AM lambda
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
# 4 Crear SNS Topic para notificación de decisiones
resource "aws_sns_topic" "loan_decision_topic" {
  name = "loan-decision-topic"
  display_name = "Loan Decision Notifications"
}

resource "aws_sns_topic_subscription" "loan_decision_email_subscription" {
  topic_arn = aws_sns_topic.loan_decision_topic.arn
  protocol  = "email"
  endpoint  = "andrescodigo07@gmail.com"
}


############################################################
# 2 Adjuntar políticas predefinidas al rol IAM
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

# Política personalizada: solo publicar en este SNS topic
resource "aws_iam_policy" "lambda_publish_sns_policy" {
  name        = "lambda-publish-sns-policy"
  description = "Permite a la Lambda publicar en el topic SNS de decisiones de préstamo"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = ["sns:Publish"]
        Resource = "${aws_sns_topic.loan_decision_topic.arn}"
      }
    ]
  })
}

# Adjuntar la política personalizada al rol
resource "aws_iam_role_policy_attachment" "lambda_publish_sns" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = aws_iam_policy.lambda_publish_sns_policy.arn
}

############################################################
# 3 Cola SQS donde llegarán los mensajes
resource "aws_sqs_queue" "loan_decision_queue" {
  name = "loan-decision-queue"

  # Tiempo que otro consumidor debe esperar antes de volver a recibir un mensaje no procesado
  visibility_timeout_seconds = 30
}

resource "aws_sqs_queue" "loan_capacity_result_queue" {
  name = "loan-capacity-result-queue"
  visibility_timeout_seconds = 30
}


############################################################
# 5️ Función Lambda: notification-loan-decision
resource "aws_lambda_function" "notification_loan_decision" {
  function_name = "notification-loan-decision"
  runtime       = "python3.9"
  handler       = "handler.lambda_handler"

  filename         = "../lambdas/notification_loan_decision.zip"
  source_code_hash = filebase64sha256("../lambdas/notification_loan_decision.zip")

  role = aws_iam_role.lambda_exec.arn

  environment {
    variables = {
      TOPIC_ARN = aws_sns_topic.loan_decision_topic.arn
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
# 8 Output: mostrar URL de la cola SQS
output "sqs_decision_queue_url" {
  value = aws_sqs_queue.loan_decision_queue.url
  description = "URL pública de la cola SQS loan-decision-queue"
}

output "sqs_capacity_result_queue_url" {
  value = aws_sqs_queue.loan_capacity_result_queue.url
  description = "URL pública de la cola SQS loan-capacity-result-queue"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.loan_decision_topic.arn
  description = "ARN del SNS Topic para notificaciones de decisiones"
}