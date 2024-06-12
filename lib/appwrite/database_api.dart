import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:skillhub/models/registration_fields.dart';

class DatabaseAPI {
  Client client = Client();
  late final Account account;
  late final Databases databases;
  late final AuthAPI auth;

  DatabaseAPI({required AuthAPI auth}) {
    this.auth = auth;
    init();
  }

  void init() {
    client
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned();
    account = Account(client);
    databases = Databases(client);
  }

  // Read documents for database collection
  Future<List<Document>> getAllSkills() async {
    try {
      final data = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
      );

      // Log each document for inspection
      for (var doc in data.documents) {
        print('Document data: ${doc.data}');
      }

      return data.documents;
    } catch (e) {
      print('Error fetching skills: $e');
      return [];
    }
  }

  Future<DocumentList> getMessages() async {
    return databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_DB_ID,
    );
  }

  // Create method to create documents to database
  Future<Document> createSkill({
    required String message,
    required String description,
    required String gmaplocation,
    required RegistrationFields registrationFields,
    required double latitude,
    required double longitude,
    required String whatsappLinkController,
  }) async {
    if (latitude < -90 || latitude > 90) {
      throw ArgumentError('Latitude must be between -90 and 90 degrees.');
    }
    if (longitude < -180 || longitude > 180) {
      throw ArgumentError('Longitude must be between -180 and 180 degrees.');
    }

    final data = {
      'text': message,
      'datetime': DateTime.now().toString(),
      'user_id': auth.userid,
      'description': description,
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
    };

    try {
      return await databases.createDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: ID.unique(),
        data: data,
      );
    } catch (e) {
      print('Error creating document: $e');
      rethrow;
    }
  }

  Future<dynamic> deleteMessage({required String id}) async {
    try {
      Document document = await databases.getDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: id,
      );

      if (document.data?['user_id'] == auth.userid) {
        return databases.deleteDocument(
          databaseId: APPWRITE_DATABASE_ID,
          collectionId: COLLECTION_DB_ID,
          documentId: id,
        );
      } else {
        throw Exception("Unauthorized access to delete this message");
      }
    } catch (e) {
      print('Error deleting message: $e');
      throw Exception("Failed to delete message: $e");
    }
  }

  Future<void> saveUserData(String userId, String username, String email) async {
    try {
      await databases.createDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_USER_ID,
        documentId: ID.unique(),
        data: {
          "userId": userId,
          "name": username,
          "email": email
        },
      );
      print("Document created");
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  Future<void> getUserData() async {
    final id = SavedData.getUserId();
    try {
      final data = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_USER_ID,
        queries: [
          Query.equal("userId", id),
        ],
      );

      if (data.documents.isNotEmpty) {
        SavedData.saveUserName(data.documents[0].data['name']);
        SavedData.saveUserEmail(data.documents[0].data['email']);
        print(data.documents[0].data);
      } else {
        print('No user data found');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

 Future<bool> rsvpEvent(List participants, String documentId) async {
  final userId = SavedData.getUserId();
  participants.add(userId);
  try {
    await databases.updateDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_DB_ID,
      documentId: documentId,
      data: {"participants": participants},
    );
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}


  Future<List<Document>> manageSkills() async {
    final userId = SavedData.getUserId();
    try {
      final data = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        queries: [Query.equal("createdBy", userId)],
      );

      // Log each document for inspection
      for (var doc in data.documents) {
        print('Document data: ${doc.data}');
      }

      return data.documents;
    } catch (e) {
      print('Error managing skills: $e');
      return [];
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
      await databases.updateDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: docID,
        data: {
          'text': message,
          'datetime': registrationFields.datetime,
          'description': description,
          'lat': latitude,
          'long': longitude,
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
          'link': whatsappLinkController,
        },
      );
      print("Skill Updated");
    } catch (e) {
      print('Error updating skill: $e');
    }
  }

  Future<void> deleteSkill(String docID) async {
    try {
      final response = await databases.deleteDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: docID,
      );
      print('Skill deleted: $response');
    } catch (e) {
      print('Error deleting skill: $e');
    }
  }

  Future<String?> getWhatsappLink() async {
    try {
      final response = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID, // Replace with your database ID
        collectionId: COLLECTION_DB_ID, // Replace with your collection ID
      );

      // Log the complete response for debugging
      print('Response: ${response.toMap()}');

      // Check if there are any documents returned
      if (response.documents.isNotEmpty) {
        for (var document in response.documents) {
          print('Document data: ${document.data}');
          final link = document.data['link'];
          print('Link value: $link');
          print('Link data type: ${link.runtimeType}');
          if (link != null && link is String && link.isNotEmpty) {
            return link;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching WhatsApp link: $e');
      return null;
    }
  }
}
