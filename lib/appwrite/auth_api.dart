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
      final user = await account.create(
          userId: ID.unique(),
          email: email,
          password: password,
          name: username);
      await database.saveUserData(user.$id, username, email); // Call the saveUserData() method of the DatabaseAPI instance
      return "success";
    } on AppwriteException catch(e) {return e.message.toString();}finally{
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

}
