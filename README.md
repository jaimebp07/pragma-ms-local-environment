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
      "Sid": "TerraformLambdaInfraPolicy",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:GetRole",
        "iam:ListRolePolicies",
        "iam:PassRole",
        "lambda:*",
        "sqs:*",
        "sns:*",
        "cloudwatch:*",
        "logs:*"
      ],
      "Resource": "*"
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
