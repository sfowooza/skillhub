#!/bin/bash

# Add businessName attribute to Skills collection

ENDPOINT="https://skillhub.avodahsystems.com/v1"
PROJECT_ID="68fbf8c7000da2a66231"
API_KEY="standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401"
DATABASE_ID="68fbfa9400035f96086e"
SKILLS_COLLECTION_ID="68fbfb01002ca99ab18e"

echo "=========================================="
echo "Adding businessName attribute to Skills Collection"
echo "=========================================="
echo "Collection ID: $SKILLS_COLLECTION_ID"
echo ""

# Add businessName attribute (string, optional)
curl -X POST \
  "${ENDPOINT}/databases/${DATABASE_ID}/collections/${SKILLS_COLLECTION_ID}/attributes/string" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: ${PROJECT_ID}" \
  -H "X-Appwrite-Key: ${API_KEY}" \
  -d '{
    "key": "businessName",
    "size": 255,
    "required": false,
    "default": ""
  }'

echo ""
echo ""
echo "=========================================="
echo "businessName attribute added successfully!"
echo "=========================================="
