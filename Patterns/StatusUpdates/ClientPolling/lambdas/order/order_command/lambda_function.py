import json
import boto3

def lambda_handler(event, context):
    # Crie uma resposta de sucesso
    response = {
        "statusCode": 200,
        "body": json.dumps({"message": "Sucesso!"}),
    }

    return response
