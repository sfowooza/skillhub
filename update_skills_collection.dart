import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';

void main() async {
  // Appwrite configuration
  final endpoint = 'https://skillhub.avodahsystems.com/v1';
  final projectId = '68fbf8c7000da2a66231';
  final apiSecret = 'standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401';
  final databaseId = '68fbfa9400035f96086e';
  final skillsCollectionId = '68fbfb01002ca99ab18e';

  print('🔧 Updating Skills Collection Attributes...');
  print('Endpoint: $endpoint');
  print('Database ID: $databaseId');
  print('Collection ID: $skillsCollectionId\n');

  final client = Client()
      .setEndpoint(endpoint)
      .setProject(projectId)
      .setKey(apiSecret);

  final databases = Databases(client);

  try {
    // Add productOrService attribute (enum: Product or Service)
    print('📝 Adding productOrService attribute...');
    try {
      await databases.createEnumAttribute(
        databaseId: databaseId,
        collectionId: skillsCollectionId,
        key: 'productOrService',
        elements: ['Product', 'Service'],
        required: true,
        xdefault: 'Service',
      );
      print('✅ productOrService attribute added successfully');
    } catch (e) {
      print('⚠️ productOrService attribute might already exist: $e');
    }

    // Add photos attribute (array of strings for photo IDs)
    print('📝 Adding photos attribute...');
    try {
      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: skillsCollectionId,
        key: 'photos',
        size: 10000, // Large size to store array of photo IDs
        required: false,
        xdefault: '[]',
        array: true,
      );
      print('✅ photos attribute added successfully');
    } catch (e) {
      print('⚠️ photos attribute might already exist: $e');
    }

    print('\n✅ Skills collection updated successfully!');
    print('📋 New attributes:');
    print('   - productOrService (enum): Product | Service');
    print('   - photos (string array): Photo file IDs from storage');
    
  } catch (e) {
    print('❌ Error updating collection: $e');
    exit(1);
  }
}
