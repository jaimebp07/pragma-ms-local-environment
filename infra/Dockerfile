# Imagen base con Python, Terraform y AWS CLI
FROM hashicorp/terraform:1.9.5

# Instalar Python y zip
RUN apk add --no-cache python3 py3-pip zip bash

WORKDIR /app

COPY ./terraform ./terraform
COPY ./lambdas ./lambdas
COPY deploy_infra.sh .

# Variables AWS
ENV AWS_ACCESS_KEY_ID=""
ENV AWS_SECRET_ACCESS_KEY=""
ENV AWS_REGION="us-east-2"

RUN chmod +x deploy_infra.sh ./lambdas/package_lambda.sh

#CMD ["bash", "./deploy_all.sh"]
ENTRYPOINT ["./deploy_infra.sh"]
