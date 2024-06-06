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
//Read documents for database collection

//List all Document 

Future getAllSkills() async {
  try {
    final data = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
    );
     return data.documents;
  } catch (e) {
    print(e);
  }
}

  // Future<DocumentList> getAllSkills() async{
  //   try{
  //      return await databases.listDocuments(
  //     databaseId: APPWRITE_DATABASE_ID,
  //     collectionId: COLLECTION_DB_ID,
  //   );
  //   } catch(e){
  //     print(e);
  //     throw AppwriteException('Failed to Get Skill Docs');
   
  // }}

   Future<DocumentList> getMessages() {
    return databases.listDocuments(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_DB_ID,);
  }

//create method to create documents to database
  Future<Document> createSkill({
    required String message,
    required String description,
    required RegistrationFields registrationFields,
    //required String image,
  }) async {
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
      'inSoleBusiness':registrationFields.inSoleBusiness,
      'image':registrationFields.image,
    };

    return await databases.createDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_DB_ID,
      documentId: ID.unique(),
      data: data,
    );
  }

  Future<dynamic> deleteMessage({required String id}) async {
    // Get the document to check the user_id
    Document document = await databases.getDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_DB_ID,
      documentId: id,
    );

    // Check if the authenticated user is the creator of the document
    if (document.data?['user_id'] == auth.userid) {
      // Delete the document
      return databases.deleteDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: id,
      );
    } else {
      // Throw an exception or return an error indicating unauthorized access
      throw Exception("Unauthorized access to delete this message");
    }
  }

  Future<void> saveUserData(String userId, String username, String email) async {
    return await databases.createDocument(
      databaseId: APPWRITE_DATABASE_ID,
      collectionId: COLLECTION_USER_ID,
      documentId: ID.unique(),
      data: {
        "userId": userId,
        "name": username,
        "email": email
      },
    ).then((value) => print("Document created")).catchError((e) => print(e));
  }

   // get user data from the database

Future getUserData() async {
  final id = SavedData.getUserId();
  try {
    final data = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_USER_ID,
        queries: [
          Query.equal("userId", id),
        ]);

    SavedData.saveUserName(data.documents[0].data['name']);
    SavedData.saveUserEmail(data.documents[0].data['email']);
    print(data);
  } catch (e) {
    print(e);
  }
}

// rsvp an event

Future rsvpEvent(List participants, String documentId) async {
  final userId = SavedData.getUserId();
  participants.add(userId);
  try {
    await databases.updateDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: documentId,
        data: {"participants": participants});
    return true;
  } catch (e) {
    print(e);
    return false;
  }
}

// list all event created by the user

Future manageSkills() async {
  final userId = SavedData.getUserId();
  try {
    final data = await databases.listDocuments(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        queries: [Query.equal("createdBy", userId)]);
    return data.documents;
  } catch (e) {
    print(e);
  }
}
// update the edited event

Future<void> updateSkill(
    //String name,
    String message,
    String description,
    RegistrationFields registrationFields,
    String docID) async {
  return await databases
      .updateDocument(
          databaseId: APPWRITE_DATABASE_ID,
          collectionId: COLLECTION_DB_ID,
          documentId: docID,
          data: {
            'text': message,
     'datetime': registrationFields.datetime,
     // 'message': message,
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
      'inSoleBusiness':registrationFields.inSoleBusiness,
      'image':registrationFields.image,
          })
      .then((value) => print("Skill Updated"))
      .catchError((e) => print(e));
}

Future deleteSkill(String docID) async {
  try {
    final response = await databases.deleteDocument(
        databaseId: APPWRITE_DATABASE_ID,
        collectionId: COLLECTION_DB_ID,
        documentId: docID);

    print(response);
  } catch (e) {
    print(e);
  }
}

}
