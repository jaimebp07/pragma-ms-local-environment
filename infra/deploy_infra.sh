#!/bin/bash
set -e

echo "Empaquetando lambdas..."

cd lambdas
./package_lambda.sh notification_loan_decision
#./package_lambda.sh automatic_loan_validation
cd ..

echo "Lambda empaquetada correctamente."

echo "Desplegando infraestructura AWS..."

cd terraform

# Inicializa y aplica Terraform
terraform init -input=false
terraform apply -auto-approve -input=false

# Captura los outputs
SQS_DECISION_QUEUE_URL=$(terraform output -raw sqs_decision_queue_url)
#SNS_TOPIC_ARN=$(terraform output -raw sns_topic_arn)

cd ..

# Crea el archivo .env compartido
mkdir -p /shared
cat <<EOF > /shared/.env
SQS_DECISION_QUEUE_URL=${SQS_DECISION_QUEUE_URL}
EOF
#SNS_TOPIC_ARN=${SNS_TOPIC_ARN}
#EOF

echo "✅ Infraestructura desplegada correctamente."
echo "📄 Archivo .env generado con variables de entorno:"
cat /shared/.env