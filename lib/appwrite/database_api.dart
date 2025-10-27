import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/models/registration_fields.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:flutter/material.dart';

class DatabaseAPI extends ChangeNotifier {
  final AuthAPI auth;
  late final Databases databases;

  DatabaseAPI({required this.auth}) {
    databases = Databases(auth.client);
  }

  Future<List<Map<String, dynamic>>> getAllSkills() async {
    try {
      final response = await databases.listDocuments(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
      );
      
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print('Error getting all skills: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSkillsBySubCategory(String subCategory) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        queries: [
          Query.equal('selectedSubcategory', subCategory),
        ],
      );
      
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print('Error getting skills by subcategory: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    return await getAllSkills();
  }

  Future<Map<String, dynamic>> createSkill({
    required String message,
    required String description,
    required String gmaplocation,
    required RegistrationFields registrationFields,
    required double latitude,
    required double longitude,
    required String whatsappLinkController,
  }) async {
    try {
      final data = {
        'text': message,
        'description': description,
        'gmaplocation': gmaplocation,
        'firstName': registrationFields.firstName,
        'lastName': registrationFields.lastName,
        'phoneNumber': registrationFields.phoneNumber,
        'location': registrationFields.location,
        'email': registrationFields.email,
        'selectedCategory': registrationFields.selectedCategory,
        'selectedSubcategory': registrationFields.selectedSubcategory,
        'participants': registrationFields.participants,
        'createdBy': registrationFields.createdBy,
        'inSoleBusiness': registrationFields.inSoleBusiness,
        'image': registrationFields.image,
        'gmap_location': gmaplocation,
        'lat': latitude,
        'long': longitude,
        'link': whatsappLinkController,
        'datetime': DateTime.now().toIso8601String(),
        'user_id': auth.userid ?? '',
      };

      final response = await databases.createDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: ID.unique(),
        data: data,
      );

      return response.data;
    } catch (e) {
      print('Error creating skill: $e');
      rethrow;
    }
  }

  Future<bool> deleteMessage({required String id}) async {
    try {
      await databases.deleteDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: id,
      );
      return true;
    } catch (e) {
      print('Error deleting skill: $e');
      return false;
    }
  }

  Future<void> saveUserData(String userId, String username, String email) async {
    try {
      final data = {
        'userId': userId,
        'username': username,
        'email': email,
        'createdAt': DateTime.now().toIso8601String(),
      };

      await databases.createDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.usersCollectionId,
        documentId: userId,
        data: data,
      );
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      if (auth.userid == null) return null;
      
      final response = await databases.getDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.usersCollectionId,
        documentId: auth.userid!,
      );
      
      return response.data;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<bool> rsvpEvent(List participants, String documentId) async {
    try {
      await databases.updateDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: documentId,
        data: {'participants': participants},
      );
      return true;
    } catch (e) {
      print('Error updating RSVP: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> manageSkills() async {
    try {
      if (auth.userid == null) return [];
      
      final response = await databases.listDocuments(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        queries: [
          Query.equal('user_id', auth.userid!),
        ],
      );
      
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print('Error getting user skills: $e');
      return [];
    }
  }

  Future<void> createSkillNew(
    String message,
    String description,
    double? latitude,
    double? longitude,
    String gmaplocation,
    String whatsappLinkController,
    RegistrationFields registrationFields,
  ) async {
    try {
      final data = {
        'text': message,
        'description': description,
        'lat': latitude,
        'long': longitude,
        'gmaplocation': gmaplocation,
        'link': whatsappLinkController,
        'firstName': registrationFields.firstName,
        'lastName': registrationFields.lastName,
        'phoneNumber': registrationFields.phoneNumber,
        'location': registrationFields.location,
        'email': registrationFields.email,
        'selectedCategory': registrationFields.selectedCategory,
        'selectedSubcategory': registrationFields.selectedSubcategory,
        'participants': registrationFields.participants,
        'createdBy': registrationFields.createdBy,
        'inSoleBusiness': registrationFields.inSoleBusiness,
        'image': registrationFields.image,
        'datetime': DateTime.now().toIso8601String(),
        'user_id': auth.userid ?? '',
      };

      await databases.createDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: ID.unique(),
        data: data,
      );
    } catch (e) {
      print('Error creating new skill: $e');
      rethrow;
    }
  }

  Future<void> updateSkill(
    String message,
    String description,
    double? latitude,
    double? longitude,
    String gmaplocation,
    String whatsappLinkController,
    RegistrationFields registrationFields,
    String docID,
  ) async {
    try {
      final data = {
        'text': message,
        'description': description,
        'lat': latitude,
        'long': longitude,
        'gmaplocation': gmaplocation,
        'link': whatsappLinkController,
        'firstName': registrationFields.firstName,
        'lastName': registrationFields.lastName,
        'phoneNumber': registrationFields.phoneNumber,
        'location': registrationFields.location,
        'email': registrationFields.email,
        'selectedCategory': registrationFields.selectedCategory,
        'selectedSubcategory': registrationFields.selectedSubcategory,
        'participants': registrationFields.participants,
        'createdBy': registrationFields.createdBy,
        'inSoleBusiness': registrationFields.inSoleBusiness,
        'image': registrationFields.image,
        'datetime': DateTime.now().toIso8601String(),
      };

      await databases.updateDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: docID,
        data: data,
      );
    } catch (e) {
      print('Error updating skill: $e');
      rethrow;
    }
  }

  Future<void> deleteSkill(String docID) async {
    try {
      await databases.deleteDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: docID,
      );
    } catch (e) {
      print('Error deleting skill: $e');
      rethrow;
    }
  }

  Stream<Map<String, dynamic>> getSkillRatings(String skillId) {
    return Stream.fromFuture(_getSkillRatings(skillId));
  }

  Future<Map<String, dynamic>> _getSkillRatings(String skillId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: Constants.databaseId,
        collectionId: Constants.ratingsCollectionId,
        queries: [
          Query.equal('skillId', skillId),
        ],
      );

      final ratings = response.documents.map((doc) => doc.data).toList();
      double averageRating = 0.0;
      Map<String, double> userRatings = {};

      if (ratings.isNotEmpty) {
        double totalRating = 0.0;
        for (var rating in ratings) {
          totalRating += rating['rating'] ?? 0.0;
          userRatings[rating['userId']] = rating['rating'] ?? 0.0;
        }
        averageRating = totalRating / ratings.length;
      }

      return {
        'id': skillId,
        'averageRating': averageRating,
        'ratings': userRatings,
      };
    } catch (e) {
      print('Error getting skill ratings: $e');
      return {
        'id': skillId,
        'averageRating': 0.0,
        'ratings': <String, double>{},
      };
    }
  }

  Future<void> updateRating(String skillId, double rating) async {
    try {
      if (auth.userid == null) return;

      final data = {
        'skillId': skillId,
        'userId': auth.userid!,
        'rating': rating,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Try to update existing rating first
      try {
        final existingRatings = await databases.listDocuments(
          databaseId: Constants.databaseId,
          collectionId: Constants.ratingsCollectionId,
          queries: [
            Query.equal('skillId', skillId),
            Query.equal('userId', auth.userid!),
          ],
        );

        if (existingRatings.documents.isNotEmpty) {
          // Update existing rating
          await databases.updateDocument(
            databaseId: Constants.databaseId,
            collectionId: Constants.ratingsCollectionId,
            documentId: existingRatings.documents.first.$id,
            data: data,
          );
        } else {
          // Create new rating
          await databases.createDocument(
            databaseId: Constants.databaseId,
            collectionId: Constants.ratingsCollectionId,
            documentId: ID.unique(),
            data: data,
          );
        }
      } catch (e) {
        // If query fails, just create new rating
        await databases.createDocument(
          databaseId: Constants.databaseId,
          collectionId: Constants.ratingsCollectionId,
          documentId: ID.unique(),
          data: data,
        );
      }
    } catch (e) {
      print('Error updating rating: $e');
    }
  }

  Future<Map<String, dynamic>> getSkillById(String skillId) async {
    try {
      final response = await databases.getDocument(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
        documentId: skillId,
      );
      
      return response.data;
    } catch (e) {
      print('Error getting skill by ID: $e');
      // Fallback to getting from all skills
      final skills = await getAllSkills();
      return skills.firstWhere(
        (skill) => skill['\$id'] == skillId,
        orElse: () => skills.isNotEmpty ? skills.first : {},
      );
    }
  }
}
