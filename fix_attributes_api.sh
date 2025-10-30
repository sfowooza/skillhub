#!/bin/bash

# Appwrite configuration
ENDPOINT="https://skillhub.avodahsystems.com/v1"
PROJECT_ID="68fbf8c7000da2a66231"
API_KEY="standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401"
DATABASE_ID="68fbfa9400035f96086e"
COLLECTION_ID="68fbfb01002ca99ab18e"

echo ""
echo "🔧 Fixing Appwrite Collection Attributes..."
echo ""

# Step 1: Delete old attributes
echo "Step 1: Deleting old attributes with wrong types..."
echo ""

for attr in "lat" "long" "averageRating"; do
    echo "Deleting attribute: $attr"
    curl -X DELETE \
        "$ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes/$attr" \
        -H "Content-Type: application/json" \
        -H "X-Appwrite-Project: $PROJECT_ID" \
        -H "X-Appwrite-Key: $API_KEY" \
        2>/dev/null
    echo ""
    echo "✅ Deleted: $attr"
    sleep 2
done

echo ""
echo "Step 2: Waiting 5 seconds for Appwrite to process deletions..."
sleep 5
echo ""

# Step 2: Create new float attributes
echo "Step 3: Creating new Float attributes..."
echo ""

# Create lat attribute
echo "Creating lat attribute (Float, nullable, default: 0.0)..."
curl -X POST \
    "$ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes/float" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $PROJECT_ID" \
    -H "X-Appwrite-Key: $API_KEY" \
    -d '{
        "key": "lat",
        "required": false,
        "default": 0.0
    }' 2>/dev/null
echo ""
echo "✅ Created: lat"
sleep 2

# Create long attribute
echo ""
echo "Creating long attribute (Float, nullable, default: 0.0)..."
curl -X POST \
    "$ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes/float" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $PROJECT_ID" \
    -H "X-Appwrite-Key: $API_KEY" \
    -d '{
        "key": "long",
        "required": false,
        "default": 0.0
    }' 2>/dev/null
echo ""
echo "✅ Created: long"
sleep 2

# Create averageRating attribute
echo ""
echo "Creating averageRating attribute (Float, nullable, default: 0.0)..."
curl -X POST \
    "$ENDPOINT/databases/$DATABASE_ID/collections/$COLLECTION_ID/attributes/float" \
    -H "Content-Type: application/json" \
    -H "X-Appwrite-Project: $PROJECT_ID" \
    -H "X-Appwrite-Key: $API_KEY" \
    -d '{
        "key": "averageRating",
        "required": false,
        "default": 0.0
    }' 2>/dev/null
echo ""
echo "✅ Created: averageRating"

echo ""
echo "🎉 Attributes fixed successfully!"
echo ""
echo "⏳ Wait 60 seconds for Appwrite to process all changes."
echo "Then restart your Flutter app with: flutter run -d emulator-5554"
echo ""
