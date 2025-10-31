#!/bin/bash

# Create release keystore for SkillHub app

echo "=========================================="
echo "Creating Release Keystore for SkillHub"
echo "=========================================="
echo ""

# Generate keystore
keytool -genkey -v -keystore android/release-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias skillhub-key \
  -storepass skillhub123 \
  -keypass skillhub123 \
  -dname "CN=SkillHub, OU=Development, O=Avodah, L=Kampala, ST=Uganda, C=UG"

echo ""
echo "=========================================="
echo "Keystore created successfully!"
echo "=========================================="
echo ""
echo "Location: android/release-keystore.jks"
echo "Alias: skillhub-key"
echo "Store Password: skillhub123"
echo "Key Password: skillhub123"
echo ""
echo "IMPORTANT: Keep these credentials safe!"
echo "=========================================="
