import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';
import 'package:skillhub/appwrite/database_api.dart';
import 'package:skillhub/appwrite/saved_data.dart';
import 'package:skillhub/constants/constants.dart';
import '../providers/registration_form_providers.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends ChangeNotifier {
  final Client client;
  late final Account account;
  late final Databases databases;
  final Storage storage;
  late DatabaseAPI database; // Add a DatabaseAPI instance

  late User _currentUser;
  AuthStatus _status = AuthStatus.uninitialized;

  // Constructor
  AuthAPI({required this.client})
      : storage = Storage(client),
        databases = Databases(client) {    
    account = Account(client);
    database = DatabaseAPI(auth: this); // Initialize the DatabaseAPI instance with this AuthAPI instance
    init();
  }

  // Initialize the Appwrite client
  void init() {
    client.setEndpoint(APPWRITE_URL).setProject(APPWRITE_PROJECT_ID).setSelfSigned();
    loadUser();
  }

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser.name;
  String? get email => _currentUser.email;
  String? get userid => _currentUser.$id;

  // Load user details
  Future<void> loadUser() async {
    try {
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

Future<String> createUser({required String email, required String password, required String username}) async {
  try {
    // Create a new user in Appwrite
    final user = await account.create(
      userId: ID.unique(),
      email: email,
      password: password,
      name: username,
    );
    
    // Save user data to your database
    await database.saveUserData(user.$id, username, email);
    
    // Optionally, send an email verification
    // Commented out as it should be handled based on your app's flow
    // await createEmailVerification(url: 'https://verify.skillhub.avodahsystems.com/verification');
    
    return "success";
  } on AppwriteException catch (e) {
    // Return the error message from Appwrite
    return e.message.toString();
  } finally {
    // Notify listeners of any state change
    notifyListeners();
  }
}

  Future<bool> createEmailSession({required String email, required String password}) async {
    try {
      final user = await account.createEmailPasswordSession(email: email, password: password);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;

      await database.getUserData();
      SavedData.saveUserId(user.userId);
      print('Login successful');
      return true;
    } 
    on AppwriteException catch (e) {
      print('AppwriteException: ${e.message}');
      return false;
    }finally {
      notifyListeners();
    }
  }

  Future<Session> signInWithProvider({required OAuthProvider provider}) async {
    try {
      final session = await account.createOAuth2Session(provider: provider);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
      notifyListeners();

      // Navigate to the HomePage() widget after successful sign out
      Navigator.pushReplacementNamed(context, '/');
    } finally {
      notifyListeners();
    }
  }

  Future<Preferences> getUserPreferences() async {
    return await account.getPrefs();
  }

  updatePreferences({required String bio, required String phone, String? profileImage}) async {
    return account.updatePrefs(prefs: {'bio': bio, 'phone': phone});
  }

  // Check if the user has a session
  Future<bool> checkSessions() async {
    try {
      await account.getSession(sessionId: 'current');
      return true;
    } catch (e) {
      return false;
    }
  }

  // New method for email verification
    Future<dynamic> createEmailVerification({required String url}) async {
    return await account.createVerification(url: url);
  }

  // New method for password recovery
  Future<dynamic> createRecovery({required String email, required String url}) async {
    return await account.createRecovery(email: email, url: url);
  }

  // In your AuthAPI class
Future<void> updateRecovery({
  required String userId,
  required String secret,
  required String password,
}) async {
  try {
    await account.updateRecovery(
      userId: userId,
      secret: secret,
      password: password,
    );
  } on AppwriteException catch (e) {
    throw e;
  }
}

}