import json
import boto3
import os

sns = boto3.client("sns")

def lambda_handler(event, context):
    topic_arn = os.environ.get("TOPIC_ARN", 
        "arn:aws:sns:us-east-2:484558640369:loan-decision-topic")  # Obtiene la variable de entorno TOPIC_ARN, si no existe utiliza el valor por defecto

    for record in event.get("Records", []):
        try:
            body = json.loads(record["body"])
            # Construye el mensaje con los campos esperados
            message = (
                f"Hola, {body.get('name', 'Cliente')}. "
                f"La solicitud {body.get('loanId', '')} fue {body.get('status', '')}."
            )

            sns.publish(
                TopicArn=topic_arn,
                Message=message,
                Subject="Resultado de tu solicitud de crédito"
            )
        except Exception as e:
            print(f"Error procesando el mensaje {record}: {e}")
            # opcional: lanzar la excepción para que SQS lo reintente

    return {"status": "ok"}