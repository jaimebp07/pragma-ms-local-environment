# pragma-ms-local-environment


## EJECUTAR PROYECTO

### Configuraciones previas

#### Crear grupo IAM y User IAM

🧩 1. Crear una politica personalizada que contenga los permisos mínimos para crear tus recursos (Lambda, SQS, IAM, CloudWatch, etc.)
``` json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "LambdaAndExecution",
            "Effect": "Allow",
            "Action": [
                "lambda:CreateFunction",
                "lambda:UpdateFunctionCode",
                "lambda:UpdateFunctionConfiguration",
                "lambda:GetFunction",
                "lambda:DeleteFunction",
                "lambda:ListFunctions",
                "lambda:listversionsbyfunction",
                "lambda:getfunctioncodesigningconfig",
                "lambda:AddPermission",
                "lambda:RemovePermission",
                "lambda:getpolicy",
                "lambda:geteventsourceMapping",
                "lambda:listeventsourcemappings",
                "lambda:listtags"
            ],
            "Resource": "*"
        },
        {
            "Sid": "LogsAndMonitoring",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:PutLogEvents",
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricData",
                "cloudwatch:ListMetrics"
            ],
            "Resource": "*"
        },
        {
            "Sid": "SQSAccess",
            "Effect": "Allow",
            "Action": [
                "sqs:CreateQueue",
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl",
                "sqs:ListQueues",
                "sqs:SendMessage",
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:PurgeQueue",
                "sqs:listqueuetags"
            ],
            "Resource": "*"
        },
        {
            "Sid": "SNSAccess",
            "Effect": "Allow",
            "Action": [
                "sns:CreateTopic",
                "sns:DeleteTopic",
                "sns:Publish",
                "sns:Subscribe",
                "sns:GetTopicAttributes",
                "sns:SetTopicAttributes",
                "sns:ListTopics",
                "sns:ListSubscriptionsByTopic",
                "sns:listtagsforresource",
                "sns:getsubscriptionattributes"
            ],
            "Resource": "*"
        },
        {
            "Sid": "IamRoleManagement",
            "Effect": "Allow",
            "Action": [
                "iam:GetRole",
                "iam:PassRole",
                "iam:CreateRole",
                "iam:AttachRolePolicy",
                "iam:DetachRolePolicy",
                "iam:PutRolePolicy",
                "iam:ListRolePolicies",
                "iam:ListAttachedRolePolicies",
                "iam:CreatePolicy",
                "iam:getpolicy",
                "iam:getpolicyversion",
                "iam:listpolicyversions",
                "iam:deletepolicy"
            ],
            "Resource": "*"
        },
        {
            "Sid": "TerraformBackendS3",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:CreateBucket",
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:PutBucketVersioning"
            ],
            "Resource": [
                "arn:aws:s3:::terraform-state-crediya",
                "arn:aws:s3:::terraform-state-crediya/*"
            ]
        },
        {
            "Sid": "TerraformLockDynamoDB",
            "Effect": "Allow",
            "Action": [
                "dynamodb:CreateTable",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:PutItem",
                "dynamodb:DeleteItem",
                "dynamodb:Scan",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:us-east-2:484558640369:table/terraform-locks-crediya"
        }
    ]
}
```
👥 2. Crear un grupo IAM (por ejemplo crediya_terraform_group) y agregar las politicas creadas anteriormente.

👤 3. Crear un usuario (por ejemplo crediya_terraform_user) y agregar el usuario al grupo (crediya_terraform_group)

🔑 4. Crear clave de acceso para el usuario crediya_terraform_user, esto generara un ACCESS_KEY_ID y un SECRET_ACCESS_KEY.

📄 5. crear un archivo `.env` en la raiz del proyecto (usa el `.env.example`z| como referencia). 
Ejemplo de contenido:
```bash
AWS_ACCESS_KEY_ID=TU_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=TU_SECRET_ACCESS_KEY
AWS_REGION=us-east-2
```


#### Ejecutar proyecto en local

Si quiere ejectutar el proyecto de forma local con la infraestructura desplegada en AWS puede ejecutar el siguiente comando desde powershell
```sh
 docker-compose up infradeployer
```

#### Ejecutar proyecto completo en docker

* Suficiente si no hubo cambios en Dockerfile o dependencias.
 
```sh
docker-compose up
```

* Compilar imágenes sin levantarlas
```sh
docker-compose build --no-cache
```

* compilar y levantar de una vez, ideal en el primer arranque o tras cambios de código
```sh
docker-compose up --build
```

Comandos que si funcionan desde ubuntu
docker compose build infradeployer
docker compose run --rm -it 
infradeployer bash
