# Imagen base con Python, Terraform y AWS CLI
#FROM hashicorp/terraform:1.9.5

# Instalar Python y zip
#RUN apk add --no-cache python3 py3-pip zip bash curl groff less

# Imagen base Debian slim (no Alpine)
FROM python:3.11-slim

# Instalar Terraform y utilidades
RUN apt-get update && apt-get install -y \
    curl unzip bash zip gnupg lsb-release ca-certificates \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update && apt-get install -y terraform \
    && rm -rf /var/lib/apt/lists/*
# Instalar AWS CLI v2 para validar credenciales
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf aws awscliv2.zip

WORKDIR /app

COPY ./terraform ./terraform
COPY ./lambdas ./lambdas
COPY deploy_infra.sh .

# Variables AWS
#ENV AWS_ACCESS_KEY_ID=""
#ENV AWS_SECRET_ACCESS_KEY=""
#ENV AWS_REGION="us-east-2"

RUN chmod +x deploy_infra.sh ./lambdas/package_lambda.sh

ENTRYPOINT ["./deploy_infra.sh"]
