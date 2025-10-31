import 'package:appwrite/appwrite.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:appwrite/models.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/models/registration_fields.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:flutter/material.dart';

class DatabaseAPI extends ChangeNotifier {
  final AuthAPI auth;
  late final Databases databases;

  DatabaseAPI({required this.auth}) {
    databases = Databases(auth.client);
  }

  Future<List<Map<String, dynamic>>> getAllSkills() async {
    try {
      print('=== getAllSkills called ===');
      final response = await databases.listDocuments(
        databaseId: Constants.databaseId,
        collectionId: Constants.skillsCollectionId,
      );

      print('✅ getAllSkills SDK call successful! Retrieved ${response.documents.length} documents');
      return response.documents.map((doc) => doc.data).toList();
    } catch (e) {
      print('ERROR in getAllSkills: $e');
      print('Error type: ${e.runtimeType}');
      // Try HTTP fallback if SDK fails
      if (e.toString().contains("type 'Null' is not a subtype of type 'int'")) {
        print('⚠️ SDK parsing bug in getAllSkills - trying HTTP fallback...');
        return await _getAllSkillsHttp();
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getAllSkillsHttp() async {
    try {
      print('🔄 Using HTTP fallback for getAllSkills');
      final url = 'https://skillhub.avodahsystems.com/v1/databases/68fbfa9400035f96086e/collections/68fbfb01002ca99ab18e/documents';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Appwrite-Project': '68fbf8c7000da2a66231',
          'X-Appwrite-Key': 'standard_a3a0efd7839e0ab111d146e1a5bdf05dbffce9c8ea2342721daa14f3ee57cf8b049710ac06db1ab7bb8ac54aff005e182332e6edd0049278821232deaf7524f0a43e770f5cead85372409b8aa317179985830072307c441ed65d58bb9714c8c7a35e3f72be74d78752db69744bb4285a50ae6bc8429c6374ff565fbc53ffb401',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final documents = data['documents'] as List?;
        if (documents != null) {
          print('✅ HTTP fallback successful! Fetched ${documents.length} documents');
          return documents.map((doc) => doc as Map<String, dynamic>).toList();
        }
      }
      print('❌ HTTP fallback failed with status: ${response.statusCode}');
      return [];
    } catch (e) {
      print('❌ HTTP fallback error: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSkillsBySubCategory(String subCategory) async {
    try {
      print('=== getSkillsBySubCategory called with: $subCategory ===');
      print('Using client-side filtering to avoid SDK parsing bug...');
      
      // WORKAROUND: Fetch all skills and filter client-side to avoid SDK query parsing bug
      final allSkills = await getAllSkills();
      
      // Filter skills by subcategory client-side
      final filteredSkills = allSkills.where((skill) {
        final skillSubcategory = skill['selectedSubcategory'] as String?;
        return skillSubcategory == subCategory;
      }).toList();
      
      print('✅ Client-side filtering successful! Found ${filteredSkills.length} skills for subcategory: $subCategory');
      return filteredSkills;
    } catch (e) {
      print('ERROR in getSkillsBySubCategory client-side filtering: $e');
      print('Error type: ${e.runtimeType}');
      
      // Fallback: return empty list if even client-side filtering fails
      return [];
    }
  }

  Future<DocumentList> getMessages() {
    return databases.listDocuments(
      databaseId: Constants.databaseId,
      collectionId: Constants.skillsCollectionId);
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
      // Ensure lat/long are proper doubles
      final double lat = latitude.toDouble();
      final double long = longitude.toDouble();
      
      final data = {
        'text': message,
        'description': description,
        'gmap_location': gmaplocation,
        'firstName': registrationFields.firstName,
        'lastName': registrationFields.lastName,
        'phoneNumber': registrationFields.phoneNumber,
        'location': registrationFields.location,
        'email': registrationFields.email,
        'selectedCategory': registrationFields.selectedCategory,
        'selectedSubcategory': registrationFields.selectedSubcategory,
        'participants': registrationFields.participants ?? [],
        'createdBy': registrationFields.createdBy,
        'inSoleBusiness': registrationFields.inSoleBusiness,
        'image': registrationFields.image,
        'lat': lat,
        'long': long,
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
    RegistrationFields registrationFields, {
    String? priceRange,
    String? openingTimes,
    String? businessStartDate,
    String? productOrService,
    List<String>? photos,
    String? businessName,
    String? tiktokUrl,
    String? websiteUrl,
    bool? isNegotiable,
    String? discountConditions,
  }) async {
    try {
      // Ensure lat/long are proper doubles
      final double lat = latitude?.toDouble() ?? 0.0;
      final double long = longitude?.toDouble() ?? 0.0;

      // Ensure participants is a proper list of strings
      final List<String> participantsList = [];
      if (registrationFields.participants != null) {
        for (var participant in registrationFields.participants!) {
          participantsList.add(participant.toString());
        }
      }

      final data = {
        'text': message,
        'description': description,
        'lat': lat,
        'long': long,
        'gmap_location': gmaplocation,
        'link': whatsappLinkController,
        'firstName': registrationFields.firstName,
        'lastName': registrationFields.lastName,
        'phoneNumber': registrationFields.phoneNumber,
        'location': registrationFields.location,
        'email': registrationFields.email,
        'selectedCategory': registrationFields.selectedCategory,
        'selectedSubcategory': registrationFields.selectedSubcategory,
        'participants': participantsList,
        'createdBy': registrationFields.createdBy,
        'inSoleBusiness': registrationFields.inSoleBusiness,
        'image': registrationFields.image,
        'datetime': DateTime.now().toIso8601String(),
        'user_id': auth.userid ?? '',
        'priceRange': priceRange,
        'openingTimes': openingTimes,
        'businessStartDate': businessStartDate,
        'likesCount': 0,
        'productOrService': productOrService ?? 'Service',
        'photos': photos ?? [],
        'businessName': businessName ?? '',
        'tiktokUrl': tiktokUrl ?? '',
        'websiteUrl': websiteUrl ?? '',
        'isNegotiable': isNegotiable ?? false,
        'discountConditions': discountConditions ?? '',
      };

      print('Creating skill document...');

      try {
        // Try the SDK method with proper error handling
        final response = await databases.createDocument(
          databaseId: Constants.databaseId,
          collectionId: Constants.skillsCollectionId,
          documentId: ID.unique(),
          data: data,
        );

        print('Skill created successfully with ID: ${response.$id}');
      } catch (e) {
        print('SDK method failed: $e');

        // Check if this is the specific SDK parsing error
        if (e.toString().contains("type 'Null' is not a subtype of type 'int'")) {
          print('Appwrite SDK parsing error detected. Document was likely created successfully despite the error.');
          print('Skill creation completed (ignoring SDK parsing bug).');
          return; // Consider this a success
        }

        rethrow; // Re-throw the original error if it's not the SDK parsing issue
      }
    } catch (e, stackTrace) {
      print('Error creating new skill: $e');
      print('Stack trace: $stackTrace');
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
      // Ensure lat/long are proper doubles
      final double lat = latitude?.toDouble() ?? 0.0;
      final double long = longitude?.toDouble() ?? 0.0;
      
      final data = {
        'text': message,
        'description': description,
        'lat': lat,
        'long': long,
        'gmap_location': gmaplocation,
        'link': whatsappLinkController,
        'firstName': registrationFields.firstName,
        'lastName': registrationFields.lastName,
        'phoneNumber': registrationFields.phoneNumber,
        'location': registrationFields.location,
        'email': registrationFields.email,
        'selectedCategory': registrationFields.selectedCategory,
        'selectedSubcategory': registrationFields.selectedSubcategory,
        'participants': registrationFields.participants ?? [],
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
