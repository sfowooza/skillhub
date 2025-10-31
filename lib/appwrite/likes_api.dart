import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/material.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/constants/constants.dart';

class LikesAPI extends ChangeNotifier {
  final AuthAPI auth;
  late final Databases databases;

  LikesAPI({required this.auth}) {
    databases = Databases(auth.client);
  }

  // Check if current user has liked a skill
  Future<bool> hasLikedSkill(String skillId) async {
    try {
      final userId = auth.userid;
      if (userId?.isEmpty ?? true) return false;

      final response = await databases.listDocuments(
        databaseId: Constants.databaseId,
        collectionId: Constants.likesCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('skillId', skillId),
        ],
      );

      return response.documents.isNotEmpty;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }

  // Toggle like status for a skill
  Future<bool> toggleLike(String skillId) async {
    try {
      final userId = auth.userid;
      if (userId?.isEmpty ?? true) {
        print('User not authenticated');
        return false;
      }

      // Check if already liked
      final hasLiked = await hasLikedSkill(skillId);

      if (hasLiked) {
        // Unlike: Remove from likes collection
        final response = await databases.listDocuments(
          databaseId: Constants.databaseId,
          collectionId: Constants.likesCollectionId,
          queries: [
            Query.equal('userId', userId),
            Query.equal('skillId', skillId),
          ],
        );

        if (response.documents.isNotEmpty) {
          await databases.deleteDocument(
            databaseId: Constants.databaseId,
            collectionId: Constants.likesCollectionId,
            documentId: response.documents[0].$id,
          );
        }

        // Decrement likes count
        await _updateLikesCount(skillId, -1);
        print('Skill unliked: $skillId');
        notifyListeners();
        return false;
      } else {
        // Like: Add to likes collection
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

        // Increment likes count
        await _updateLikesCount(skillId, 1);
        print('Skill liked: $skillId');
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error toggling like: $e');
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
      
      // Calculate new value, ensuring it doesn't go below 0
      final newLikes = (currentLikes + increment).clamp(0, double.infinity).toInt();
      
      print('Updating likesCount for skill $skillId: $currentLikes -> $newLikes');

      // Update likes count - always set it even if null
      await databases.updateDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: skillId,
        data: {
          'likesCount': newLikes,
        },
      );
      
      print('Successfully updated likesCount to $newLikes');
    } catch (e) {
      print('Error updating likes count: $e');
      // If update fails, try to initialize the field
      try {
        print('Attempting to initialize likesCount field...');
        await databases.updateDocument(
          databaseId: Constants.databaseId,
          collectionId: Constants.skillsCollectionId,
          documentId: skillId,
          data: {
            'likesCount': increment > 0 ? 1 : 0,
          },
        );
        print('Initialized likesCount successfully');
      } catch (e2) {
        print('Failed to initialize likesCount: $e2');
      }
    }
  }

  // Get total likes for a skill
  Future<int> getLikesCount(String skillId) async {
    try {
      final skill = await databases.getDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: skillId,
      );

      return skill.data['likesCount'] ?? 0;
    } catch (e) {
      print('Error getting likes count: $e');
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
