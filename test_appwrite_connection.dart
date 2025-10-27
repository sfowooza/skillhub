import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  final endpoint = dotenv.env['APPWRITE_ENDPOINT'] ?? '';
  final projectId = dotenv.env['APPWRITE_PROJECT_ID'] ?? '';
  final apiSecret = dotenv.env['APPWRITE_API_SECRET'] ?? '';
  
  print('Testing Appwrite Connection...');
  print('Endpoint: $endpoint');
  print('Project ID: $projectId');
  print('API Secret: ${apiSecret.substring(0, 20)}...');
  
  // Test 1: Check project exists
  await testProjectConnection(endpoint, projectId, apiSecret);
  
  // Test 2: List users in Auth
  await testListUsers(endpoint, projectId, apiSecret);
  
  // Test 3: Check database exists
  await testDatabaseConnection(endpoint, projectId, apiSecret);
}

Future<void> testProjectConnection(String endpoint, String projectId, String apiSecret) async {
  try {
    final response = await http.get(
      Uri.parse('$endpoint/projects/$projectId'),
      headers: {
        'X-Appwrite-Project': projectId,
        'X-Appwrite-Key': apiSecret,
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Project Connection: SUCCESS');
      print('   Project Name: ${data['name']}');
    } else {
      print('❌ Project Connection: FAILED');
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Project Connection: ERROR - $e');
  }
}

Future<void> testListUsers(String endpoint, String projectId, String apiSecret) async {
  try {
    final response = await http.get(
      Uri.parse('$endpoint/users'),
      headers: {
        'X-Appwrite-Project': projectId,
        'X-Appwrite-Key': apiSecret,
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Auth Users: SUCCESS');
      print('   Total Users: ${data['total']}');
      if (data['users'] != null && data['users'].length > 0) {
        print('   Recent Users:');
        for (var user in data['users'].take(3)) {
          print('     - ${user['email']} (${user['\$id']})');
        }
      }
    } else {
      print('❌ Auth Users: FAILED');
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Auth Users: ERROR - $e');
  }
}

Future<void> testDatabaseConnection(String endpoint, String projectId, String apiSecret) async {
  try {
    final databaseId = dotenv.env['APPWRITE_DATABASE_ID'] ?? '';
    final response = await http.get(
      Uri.parse('$endpoint/databases/$databaseId'),
      headers: {
        'X-Appwrite-Project': projectId,
        'X-Appwrite-Key': apiSecret,
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('✅ Database Connection: SUCCESS');
      print('   Database Name: ${data['name']}');
    } else {
      print('❌ Database Connection: FAILED');
      print('   Status: ${response.statusCode}');
      print('   Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Database Connection: ERROR - $e');
  }
}
