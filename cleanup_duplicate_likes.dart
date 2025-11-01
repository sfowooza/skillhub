import 'dart:io';
import 'dart:convert';

// Read from .env file
String? getEnvValue(String key) {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('❌ .env file not found');
    return null;
  }
  
  final lines = envFile.readAsLinesSync();
  for (var line in lines) {
    if (line.startsWith(key)) {
      return line.split('=')[1].trim();
    }
  }
  return null;
}

final String endpoint = getEnvValue('APPWRITE_ENDPOINT') ?? 'https://skillhub.avodahsystems.com/v1';
final String projectId = getEnvValue('APPWRITE_PROJECT_ID') ?? '68fbf8c7000da2a66231';
final String databaseId = getEnvValue('APPWRITE_DATABASE_ID') ?? '68fbfa9400035f96086e';
final String likesCollectionId = getEnvValue('APPWRITE_LIKES_COLLECTION_ID') ?? 'likes_collection';
final String? apiKey = getEnvValue('APPWRITE_API_SECRET');

void main() async {
  print('🔍 Starting duplicate likes cleanup...\n');

  try {
    // Fetch all likes using HTTP
    final url = '$endpoint/databases/$databaseId/collections/$likesCollectionId/documents';
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('X-Appwrite-Project', projectId);
    request.headers.set('Content-Type', 'application/json');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode != 200) {
      print('❌ Error fetching likes: ${response.statusCode}');
      client.close();
      return;
    }

    final data = json.decode(responseBody);
    final documents = data['documents'] as List;

    print('📊 Total likes found: ${documents.length}\n');

    // Group likes by userId + skillId combination
    Map<String, List<dynamic>> likeGroups = {};
    
    for (var doc in documents) {
      final userId = doc['userId'] as String;
      final skillId = doc['skillId'] as String;
      final key = '$userId-$skillId';
      
      if (!likeGroups.containsKey(key)) {
        likeGroups[key] = [];
      }
      likeGroups[key]!.add(doc);
    }

    // Find duplicates
    int duplicateCount = 0;
    int deletedCount = 0;
    List<String> toDelete = [];

    for (var entry in likeGroups.entries) {
      if (entry.value.length > 1) {
        duplicateCount += entry.value.length - 1;
        print('🔍 Found ${entry.value.length} likes for ${entry.key}');
        
        // Keep the first, delete the rest
        for (int i = 1; i < entry.value.length; i++) {
          final docId = entry.value[i][r'$id'];
          toDelete.add(docId);
        }
      }
    }

    print('\n📈 Summary:');
    print('   Total unique user-skill pairs: ${likeGroups.length}');
    print('   Total duplicate likes to delete: $duplicateCount');

    if (toDelete.isEmpty) {
      print('\n✅ No duplicates found! Collection is clean.');
      return;
    }

    print('\n🗑️  Deleting duplicate likes...\n');

    if (apiKey == null || apiKey!.isEmpty) {
      print('❌ Cannot delete: API key not found in .env file');
      print('   Make sure APPWRITE_API_SECRET is set in your .env file\n');
      print('\n📋 Duplicate document IDs to delete manually:');
      for (var docId in toDelete) {
        print('   - $docId');
      }
      client.close();
      return;
    }
    
    print('✅ Using API key from .env file');
    print('⚠️  About to delete $duplicateCount duplicate likes...\n');

    // Delete duplicates using HTTP DELETE
    for (var docId in toDelete) {
      try {
        final deleteUrl = '$endpoint/databases/$databaseId/collections/$likesCollectionId/documents/$docId';
        final deleteRequest = await client.deleteUrl(Uri.parse(deleteUrl));
        deleteRequest.headers.set('X-Appwrite-Project', projectId);
        deleteRequest.headers.set('X-Appwrite-Key', apiKey!);
        deleteRequest.headers.set('Content-Type', 'application/json');
        
        final deleteResponse = await deleteRequest.close();
        
        if (deleteResponse.statusCode == 204 || deleteResponse.statusCode == 200) {
          deletedCount++;
          print('✅ Deleted duplicate like: $docId');
        } else {
          print('❌ Failed to delete $docId: Status ${deleteResponse.statusCode}');
        }
      } catch (e) {
        print('❌ Failed to delete $docId: $e');
      }
    }
    
    client.close();

    print('\n🎉 Cleanup completed!');
    print('   Deleted: $deletedCount duplicates');
    print('   Remaining: ${documents.length - deletedCount} unique likes');

  } catch (e) {
    print('❌ Error during cleanup: $e');
  }
}
