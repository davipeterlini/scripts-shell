#!/usr/bin/env bash
set -e

PROJECT_ID="SEU_PROJECT_ID"
REGION="southamerica-east1"
SERVICE="cloudrun-gcs-iap"
BUCKET="flow_coder"

echo "➡️ Configurando projeto: $PROJECT_ID"
gcloud config set project $PROJECT_ID

echo "➡️ Enviando build..."
gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE

echo "➡️ Deploy no Cloud Run..."
gcloud run deploy $SERVICE \
  --image gcr.io/$PROJECT_ID/$SERVICE \
  --platform managed \
  --region $REGION \
  --no-allow-unauthenticated \
  --set-env-vars BUCKET_NAME=$BUCKET

RUN_URL=$(gcloud run services describe $SERVICE \
  --platform managed --region $REGION \
  --format="value(status.url)")
echo "🚀 Serviço Cloud Run disponível em: $RUN_URL"

echo "➡️ Habilitando IAP..."
gcloud services enable iap.googleapis.com

echo "➡️ Adicionando acesso IAP para *@empresa.com..."
gcloud iap web add-iam-policy-binding \
  --resource-type=cloud-run \
  --service=$SERVICE \
  --member="allUsers" \
  --role="roles/iap.httpsResourceAccessor" \
  --condition=None \
  --project=$PROJECT_ID \
  --location=$REGION

echo "✅ Deploy e IAP configurados com sucesso!"
echo "Teste: ${RUN_URL}/download/SEU_ARQUIVO.ext"
