#!/bin/bash
set -e

LAMBDA_NAME=$1

cd "$(dirname "$0")"

cd $LAMBDA_NAME

# Instalar dependencias en la carpeta temporal
pip install -r requirements.txt -t ./package

# Copiar tu handler.py
cp handler.py ./package/

# Crear ZIP
cd package
zip -r ../../$LAMBDA_NAME.zip .

# Limpiar
cd ..
rm -rf package
cd ../..

#EJEMPLO DE USO:
#./package_lambda.sh notificaciones
#./package_lambda.sh capacidad
