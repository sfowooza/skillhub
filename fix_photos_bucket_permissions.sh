#!/bin/bash

# Fix photos bucket permissions to allow public read access

ENDPOINT="https://skillhub.avodahsystems.com/v1"
PROJECT_ID="68fbf8c7000da2a66231"
API_KEY="standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401"
PHOTOS_BUCKET_ID="690467e10027d9964429"

echo "=========================================="
echo "Updating Photos Bucket Permissions"
echo "=========================================="
echo "Bucket ID: $PHOTOS_BUCKET_ID"
echo ""

# Update bucket permissions to allow public read access
curl -X PUT \
  "${ENDPOINT}/storage/buckets/${PHOTOS_BUCKET_ID}" \
  -H "Content-Type: application/json" \
  -H "X-Appwrite-Project: ${PROJECT_ID}" \
  -H "X-Appwrite-Key: ${API_KEY}" \
  -d '{
    "bucketId": "'"${PHOTOS_BUCKET_ID}"'",
    "name": "Photos",
    "permissions": ["read(\"any\")"],
    "fileSecurity": false,
    "enabled": true
  }'

echo ""
echo ""
echo "=========================================="
echo "Photos bucket permissions updated!"
echo "Public read access enabled: read(\"any\")"
echo "=========================================="
