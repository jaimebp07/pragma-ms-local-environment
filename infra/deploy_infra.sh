#!/bin/bash
set -e

echo "🔍 Verificando credenciales AWS..."

echo "AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY: $AWS_SECRET_ACCESS_KEY"
echo "AWS_REGION: $AWS_REGION"

aws sts get-caller-identity --output text >/dev/null 2>&1 || {
  echo "❌ Error: Las credenciales AWS no son válidas o no fueron cargadas."
  exit 1
}
echo "✅ Credenciales AWS válidas."


echo "Empaquetando lambdas..."

cd lambdas
./package_lambda.sh notification_loan_decision
#./package_lambda.sh automatic_loan_validation
cd ..

echo "Lambda empaquetada correctamente."

echo "Desplegando infraestructura AWS..."

cd terraform

echo "🌍 Verificando variables de entorno antes de Terraform:"
env | grep AWS

echo "🧹 Limpiando configuración previa de Terraform..."
rm -rf .terraform .terraform.lock.hcl

echo "🚀 Ejecutando Terraform..."

# Inicializa y aplica Terraform
terraform init -input=false
terraform apply -auto-approve -input=false

# Captura los outputs
SQS_DECISION_QUEUE_URL=$(terraform output -raw sqs_decision_queue_url)
#SNS_TOPIC_ARN=$(terraform output -raw sns_topic_arn)

echo "SQS_DECISION_QUEUE_URL: $SQS_DECISION_QUEUE_URL"

cd ..

# Crea el archivo .env compartido
mkdir -p /shared
cat <<EOF > /shared/msloanapplications.env
SQS_DECISION_QUEUE_URL=${SQS_DECISION_QUEUE_URL}
EOF
#SNS_TOPIC_ARN=${SNS_TOPIC_ARN}
#EOF

echo "✅ Infraestructura desplegada correctamente."
echo "📄 Archivo .env generado con variables de entorno:"
cat /shared/msloanapplications.env