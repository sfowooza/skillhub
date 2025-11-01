import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LikesAPI extends ChangeNotifier {
  final AuthAPI auth;
  late final Databases databases;

  LikesAPI({required this.auth}) {
    databases = Databases(auth.client);
  }

  // Check if current user has liked a skill (using HTTP to bypass SDK bug)
  Future<bool> hasLikedSkill(String skillId) async {
    try {
      final userId = auth.userid;
      if (userId?.isEmpty ?? true) return false;

      // Use HTTP directly to bypass SDK parsing bugs
      final url = '${Constants.endpoint}/databases/${Constants.databaseId}/collections/${Constants.likesCollectionId}/documents';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Appwrite-Project': Constants.projectId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data['documents'] as List;
        
        // Check if any document matches both userId and skillId
        final hasLike = documents.any((doc) {
          return doc['userId'] == userId && doc['skillId'] == skillId;
        });
        
        return hasLike;
      }
      return false;
    } catch (e) {
      print('⚠️ Error checking like status: $e');
      return false;
    }
  }

  // Toggle like status for a skill (using HTTP to prevent duplicates)
  Future<bool> toggleLike(String skillId) async {
    try {
      final userId = auth.userid;
      if (userId?.isEmpty ?? true) {
        print('User not authenticated');
        return false;
      }

      // Use HTTP to find existing likes (bypass SDK bug)
      final url = '${Constants.endpoint}/databases/${Constants.databaseId}/collections/${Constants.likesCollectionId}/documents';
      final httpResponse = await http.get(
        Uri.parse(url),
        headers: {
          'X-Appwrite-Project': Constants.projectId,
          'Content-Type': 'application/json',
        },
      );

      if (httpResponse.statusCode == 200) {
        final data = json.decode(httpResponse.body);
        final documents = data['documents'] as List;
        
        // Find if user already liked this skill
        final existingLike = documents.firstWhere(
          (doc) => doc['userId'] == userId && doc['skillId'] == skillId,
          orElse: () => null,
        );

        if (existingLike != null) {
          // Unlike: Remove from likes collection
          final likeDocId = existingLike[r'$id'];
          await databases.deleteDocument(
            databaseId: Constants.databaseId,
            collectionId: Constants.likesCollectionId,
            documentId: likeDocId,
          );

          print('✅ Skill unliked: $skillId by $userId');
          notifyListeners();
          return false;
        } else {
          // Like: Add to likes collection (only if not already liked)
          await databases.createDocument(
            databaseId: Constants.databaseId,
            collectionId: Constants.likesCollectionId,
            documentId: ID.unique(),
            data: {
              'userId': userId!,
              'skillId': skillId,
            },
            permissions: [
              Permission.read(Role.any()),
              Permission.delete(Role.user(userId)),
            ],
          );

          print('✅ Skill liked: $skillId by $userId');
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ Error toggling like: $e');
      return false;
    }
  }

  // Update the likes count on the skill document
  Future<void> _updateLikesCount(String skillId, int increment) async {
    try {
      // Get current skill document
      final skill = await databases.getDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: skillId,
      );

      // Handle null and convert to int safely
      final likesValue = skill.data['likesCount'];
      int currentLikes = 0;
      if (likesValue != null) {
        if (likesValue is int) {
          currentLikes = likesValue;
        } else if (likesValue is double) {
          currentLikes = likesValue.toInt();
        }
      }
      final newLikes = (currentLikes + increment).clamp(0, double.infinity).toInt();

      // Update likes count
      await databases.updateDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: skillId,
        data: {
          'likesCount': newLikes,
        },
      );
    } catch (e) {
      print('Error updating likes count: $e');
    }
  }

  // Get total likes for a skill (using HTTP to bypass SDK bug)
  Future<int> getLikesCount(String skillId) async {
    try {
      // Use HTTP directly to bypass SDK parsing bugs
      final url = '${Constants.endpoint}/databases/${Constants.databaseId}/collections/${Constants.likesCollectionId}/documents';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Appwrite-Project': Constants.projectId,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final documents = data['documents'] as List;
        
        // Count documents that match this skillId
        final count = documents.where((doc) => doc['skillId'] == skillId).length;
        
        if (count > 0) {
          print('✅ HTTP: Counted $count likes for skill $skillId');
        }
        return count;
      }
      return 0;
    } catch (e) {
      print('⚠️ Error getting likes count: $e');
      return 0;
    }
  }

  // Get list of users who liked a skill
  Future<List<String>> getUsersWhoLiked(String skillId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Constants.databaseId,
        collectionId: Constants.likesCollectionId,
        queries: [
          Query.equal('skillId', skillId),
        ],
      );

      return response.documents.map((doc) => doc.data['userId'] as String).toList();
    } catch (e) {
      print('Error getting users who liked: $e');
      return [];
    }
  }
}
