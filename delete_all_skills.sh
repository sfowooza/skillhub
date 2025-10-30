#!/bin/bash

ENDPOINT="https://skillhub.avodahsystems.com/v1"
PROJECT_ID="68fbf8c7000da2a66231"
API_KEY="standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401"
DATABASE_ID="68fbfa9400035f96086e"
COLLECTION_ID="68fbfb01002ca99ab18e"

echo ""
echo "🗑️  Deleting all existing skills documents..."
echo ""

# Get all document IDs
DOC_IDS=$(curl -s "$ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/documents" \
    -H "X-Appwrite-Project: $PROJECT_ID" \
    -H "X-Appwrite-Key: $API_KEY" | jq -r '.documents[].$id')

# Count documents
COUNT=$(echo "$DOC_IDS" | wc -l)
echo "Found $COUNT documents to delete"
echo ""

# Delete each document
i=1
for doc_id in $DOC_IDS; do
    echo "Deleting document $i/$COUNT: $doc_id"
    curl -s -X DELETE "$ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/documents/$doc_id" \
        -H "X-Appwrite-Project: $PROJECT_ID" \
        -H "X-Appwrite-Key: $API_KEY" > /dev/null
    echo "✅ Deleted"
    ((i++))
done

echo ""
echo "🎉 All documents deleted!"
echo ""
echo "Now restart your app and create new skills. They will render correctly!"
echo ""
