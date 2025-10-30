import 'dart:io';
import 'package:appwrite/appwrite.dart';

void main() async {
  // Initialize Appwrite client
  final client = Client()
      .setEndpoint('https://skillhub.avodahsystems.com/v1')
      .setProject('68fbf8c7000da2a66231')
      .setKey('standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401');

  final databases = Databases(client);

  const databaseId = '68fbfa9400035f96086e'; // userData database ID
  const collectionId = '68fbfb01002ca99ab18e'; // Skills Collection ID

  try {
    print('🔧 Updating Appwrite collection attributes...\n');

    // Delete old attributes that have wrong types
    print('Step 1: Deleting old numeric attributes with wrong types...');
    
    final attributesToDelete = ['lat', 'long', 'averageRating'];
    
    for (final attr in attributesToDelete) {
      try {
        await databases.deleteAttribute(
          databaseId: databaseId,
          collectionId: collectionId,
          key: attr,
        );
        print('✅ Deleted attribute: $attr');
        await Future.delayed(Duration(seconds: 2)); // Wait for Appwrite to process
      } catch (e) {
        print('ℹ️  Attribute $attr might not exist or already deleted: $e');
      }
    }

    print('\nStep 2: Creating new attributes with correct types (float)...\n');

    // Wait a bit to ensure deletions are processed
    await Future.delayed(Duration(seconds: 3));

    // Create lat attribute as float (required: false, default: 0.0)
    try {
      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: 'lat',
        required: false,
        xdefault: 0.0,
      );
      print('✅ Created lat attribute (float, nullable, default: 0.0)');
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('❌ Error creating lat attribute: $e');
    }

    // Create long attribute as float (required: false, default: 0.0)
    try {
      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: 'long',
        required: false,
        xdefault: 0.0,
      );
      print('✅ Created long attribute (float, nullable, default: 0.0)');
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('❌ Error creating long attribute: $e');
    }

    // Create averageRating attribute as float (required: false, default: 0.0)
    try {
      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: 'averageRating',
        required: false,
        xdefault: 0.0,
      );
      print('✅ Created averageRating attribute (float, nullable, default: 0.0)');
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('❌ Error creating averageRating attribute: $e');
    }

    print('\n🎉 Collection attributes updated successfully!');
    print('\n⚠️  IMPORTANT: Wait 30-60 seconds for Appwrite to process all changes.');
    print('Then restart your Flutter app and the skills should render correctly.\n');

  } catch (e) {
    print('❌ Error updating collection attributes: $e');
  }
}
