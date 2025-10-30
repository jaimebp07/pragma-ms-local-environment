#!/bin/bash
set -e

echo "🚀 Iniciando script de despliegue de infraestructura..."

COMMAND=$1

validate_aws_credentials() {
  echo "🔍 Verificando credenciales AWS..."
  aws sts get-caller-identity --output text >/dev/null 2>&1 || {
    echo "❌ Error: Las credenciales AWS no son válidas o no fueron cargadas."
    exit 1
  }
  echo "✅ Credenciales AWS válidas."
}

package_lambdas() {
  echo "Empaquetando lambdas..."
  cd lambdas
  ./package_lambda.sh notification_loan_decision
  #./package_lambda.sh automatic_loan_validation
  cd ..
  echo "Lambda empaquetada correctamente."
}

create_env_file() {
  mkdir -p /shared
  cat <<EOF > /shared/msloanapplications.env
SQS_DECISION_QUEUE_URL=${SQS_DECISION_QUEUE_URL}
SQS_CAPACITY_RESULT_QUEUE_URL=${SQS_CAPACITY_RESULT_QUEUE_URL}
EOF

  echo "📄 Archivo .env generado con variables de entorno:"
  cat /shared/msloanapplications.env
}

ensure_terraform_initialized() {
  echo "🧩 Verificando inicialización de Terraform..."
  cd terraform
  if [ ! -d ".terraform" ] || ! terraform providers >/dev/null 2>&1; then
    echo "⚙️  Terraform no inicializado. Ejecutando 'terraform init'..."
    terraform init -input=false
  else
    echo "✅ Terraform ya está inicializado."
  fi
  #terraform apply -auto-approve -refresh-only
  cd ..
}

apply_infra() {
  echo "Desplegando infraestructura AWS..."
  ensure_terraform_initialized
  cd terraform

  #echo "🧹 Limpiando configuración previa de Terraform..."
  #rm -rf .terraform .terraform.lock.hcl

  #echo "🚀 Ejecutando Terraform..."

  #terraform init -input=false
  terraform apply -auto-approve -input=false

  echo "Obteniendo URLs de las colas SQS..."

  if [[ -z "$SQS_DECISION_QUEUE_URL" ]]; then
    echo "⚠️ Advertencia: SQS_DECISION_QUEUE_URL está vacía"
  fi
  SQS_DECISION_QUEUE_URL=$(terraform output -raw sqs_decision_queue_url)
  SQS_CAPACITY_RESULT_QUEUE_URL=$(terraform output -raw sqs_capacity_result_queue_url || echo "")
  #SNS_TOPIC_ARN=$(terraform output -raw sns_topic_arn)
  
  echo "SQS_DECISION_QUEUE_URL: $SQS_DECISION_QUEUE_URL"
  echo "SQS_CAPACITY_RESULT_QUEUE_URL: $SQS_CAPACITY_RESULT_QUEUE_URL"

  cd ..

  create_env_file
}

update_infra() {
  echo "🔄 Actualizando infraestructura existente..."
  ensure_terraform_initialized
  cd terraform
  #terraform init -input=false
  terraform apply -auto-approve -input=false

  SQS_DECISION_QUEUE_URL=$(terraform output -raw sqs_decision_queue_url)
  SQS_CAPACITY_RESULT_QUEUE_URL=$(terraform output -raw sqs_capacity_result_queue_url || echo "")

  cd ..
  create_env_file
  echo "✅ Actualización completada."
}

destroy_infra() {
  echo "⚠️ Eliminando toda la infraestructura AWS..."
  ensure_terraform_initialized
  cd terraform
  terraform destroy -auto-approve
  cd ..
  echo "✅ Recursos eliminados correctamente."
}

case "$COMMAND" in
  "deploy"|"")
    echo "🟢 Iniciando despliegue completo..."
    validate_aws_credentials
    package_lambdas
    apply_infra
    ;;
  "update")
    echo "🟡 Ejecutando actualización..."
    validate_aws_credentials
    package_lambdas
    update_infra
    ;;
  "destroy")
    echo "🔴 Ejecutando eliminación completa..."
    validate_aws_credentials
    destroy_infra
    ;;
  *)
    echo "❌ Comando no reconocido: $COMMAND"
    echo "Uso: ./deploy_infra.sh [deploy|update|destroy]"
    exit 1
    ;;
esac
