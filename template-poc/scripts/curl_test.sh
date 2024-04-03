#!/bin/bash

URL=localhost
PORTA=3000
BASE_URL="http://$URL:$PORTA/vehicles"

echo "Create Vehicle"
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL" -H 'Content-Type: application/json' -d '{"name": "Vehicle Test", "price": 12345.67}')
echo "Resposta: $CREATE_RESPONSE"
VEICULO_ID=$(echo $CREATE_RESPONSE | jq '.id')
echo "Create Vehicle ID: $VEICULO_ID"
echo

echo "List Vehicle"
curl -s -X GET "$BASE_URL"
echo
echo "List Vehicle ID: $VEICULO_ID"
echo

echo "Search Vehicle with ID $VEICULO_ID."
curl -s -X GET "$BASE_URL/$VEICULO_ID"
echo
echo

echo "Update Vehicle with ID $VEICULO_ID."
curl -s -X PUT "$BASE_URL/$VEICULO_ID" -H 'Content-Type: application/json' -d '{"name": "Vehicle updated", "price": 54321.89}'
echo
echo "Update Vehicle ID: $VEICULO_ID"
echo

echo "Delete Vehicle with ID $VEICULO_ID."
curl -s -X DELETE "$BASE_URL/$VEICULO_ID"
echo "Delete Vehicle ID: $VEICULO_ID"
echo