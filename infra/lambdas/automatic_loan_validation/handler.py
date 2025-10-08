import json, math, boto3
from decimal import Decimal

sqs = boto3.client('sqs')
sns = boto3.client('sns')

RESULT_QUEUE_URL = "https://sqs.us-east-2.amazonaws.com/1234567890/loan-capacity-result-queue"
TOPIC_ARN = "arn:aws:sns:us-east-2:1234567890:loan-decision-topic"

def lambda_handler(event, context):
    for record in event['Records']:
        body = json.loads(record['body'])

        loan = body['loan']
        customer = body['customer']
        current_monthly_debt = Decimal(str(body.get('currentMonthlyDebt', 0)))

        base_salary = Decimal(str(customer['baseSalary']))
        amount = Decimal(str(loan['amount']))
        term = int(loan['term'])

        # --- Cálculos ---
        max_capacity = base_salary * Decimal('0.35')
        available_capacity = max_capacity - current_monthly_debt

        monthly_rate = Decimal('0.015')  # 1.5 % mensual de ejemplo
        new_quota = monthly_fee(amount, monthly_rate, term)

        if new_quota <= available_capacity:
            decision = "APPROVED"
            if amount > base_salary * Decimal('5'):
                decision = "MANUAL_REVIEW"
        else:
            decision = "REJECTED"

        plan = plan_pagos(amount, monthly_rate, term)

        result = {
            "loanId": loan['id'],
            "decision": decision,
            "plan": plan,
            "email": customer['email'],
            "customerName": f"{customer['firstName']} {customer['lastName']}"
        }

        # --- Publicar resultado en otra cola ---
        sqs.send_message(
            QueueUrl=RESULT_QUEUE_URL,
            MessageBody=json.dumps(result, default=str)
        )

        # --- Opcional: enviar correo directo por SNS ---
        mensaje = f"Hola {result['customerName']}, la solicitud {loan['id']} fue {decision}."
        sns.publish(
            TopicArn=TOPIC_ARN,
            Subject="Resultado de tu solicitud de crédito",
            Message=mensaje
        )

    return {"status": "ok"}


def monthly_fee(P, i, n):
    """
    P: monto (Decimal)
    i: tasa mensual (Decimal)
    n: número de meses (int)
    """
    if i == 0:
        return P / n
    factor = (1 + i) ** n
    return P * i * factor / (factor - 1)


def plan_pagos(P, i, n):
    cuota = monthly_fee(P, i, n)
    saldo = P
    plan = []
    for m in range(1, n + 1):
        interes = saldo * i
        abono = cuota - interes
        saldo -= abono
        plan.append({
            "mes": m,
            "cuota": round(cuota, 2),
            "abono_capital": round(abono, 2),
            "interes": round(interes, 2),
            "saldo_restante": round(max(saldo, 0), 2)
        })
    return plan
