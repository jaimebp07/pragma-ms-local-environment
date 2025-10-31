#!/bin/bash
set -e

BUCKET_NAME="terraform-state-crediya"
DYNAMO_TABLE="terraform-locks-crediya"
REGION="us-east-2"

echo "🔍 Verificando bucket S3 para backend..."
if ! aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
  echo "🪣 Bucket no existe. Creando bucket S3: $BUCKET_NAME..."
  aws s3api create-bucket --bucket "$BUCKET_NAME" --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
  aws s3api put-bucket-versioning --bucket "$BUCKET_NAME" --versioning-configuration Status=Enabled
else
  echo "✅ Bucket S3 ya existe."
fi

echo "🔍 Verificando tabla DynamoDB para locks..."
if ! aws dynamodb describe-table --table-name "$DYNAMO_TABLE" >/dev/null 2>&1; then
  echo "🧩 Tabla no existe. Creando tabla DynamoDB: $DYNAMO_TABLE..."
  aws dynamodb create-table \
    --table-name "$DYNAMO_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$REGION"
  echo "⌛ Esperando a que la tabla esté activa..."
  aws dynamodb wait table-exists --table-name "$DYNAMO_TABLE"
else
  echo "✅ Tabla DynamoDB ya existe."
fi

echo "🧩 Backend remoto asegurado correctamente."
