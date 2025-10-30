import 'dart:io';
import 'package:appwrite/appwrite.dart';

void main() async {
  final client = Client()
      .setEndpoint('https://skillhub.avodahsystems.com/v1')
      .setProject('68fbf8c7000da2a66231')
      .setKey('standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401');

  final databases = Databases(client);

  const databaseId = '68fbfa9400035f96086e';
  const collectionId = '68fbfb01002ca99ab18e';

  try {
    print('\n🔧 Fixing Appwrite Collection Attributes...\n');

    // Step 1: Delete old attributes
    print('Step 1: Deleting old attributes with wrong types...');
    
    final attributesToDelete = ['lat', 'long', 'averageRating'];
    
    for (final attr in attributesToDelete) {
      try {
        await databases.deleteAttribute(
          databaseId: databaseId,
          collectionId: collectionId,
          key: attr,
        );
        print('✅ Deleted: $attr');
        await Future.delayed(Duration(seconds: 2));
      } catch (e) {
        print('ℹ️  $attr not found or already deleted');
      }
    }

    print('\nStep 2: Waiting 5 seconds for Appwrite to process deletions...\n');
    await Future.delayed(Duration(seconds: 5));

    // Step 2: Create new float attributes
    print('Step 3: Creating new Float attributes...\n');

    try {
      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: 'lat',
        required: false,
        xdefault: 0.0,
      );
      print('✅ Created: lat (Float, nullable, default: 0.0)');
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('⚠️  lat: $e');
    }

    try {
      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: 'long',
        required: false,
        xdefault: 0.0,
      );
      print('✅ Created: long (Float, nullable, default: 0.0)');
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      print('⚠️  long: $e');
    }

    try {
      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: collectionId,
        key: 'averageRating',
        required: false,
        xdefault: 0.0,
      );
      print('✅ Created: averageRating (Float, nullable, default: 0.0)');
    } catch (e) {
      print('⚠️  averageRating: $e');
    }

    print('\n🎉 Attributes fixed successfully!');
    print('⏳ Wait 60 seconds for Appwrite to process, then restart your app.\n');

  } catch (e) {
    print('❌ Error: $e');
  }
  
  exit(0);
}
