import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:appwrite/enums.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:skillhub/appwrite/saved_data.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends ChangeNotifier {
  final Client client = Client();
  late final Account account;
  late final Databases databases;
  final Storage storage = Storage(Client());

  AuthStatus _status = AuthStatus.uninitialized;
  User? _currentUser;
  String? _userid;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get userid => _userid;

  AuthAPI() {
    account = Account(client);
    databases = Databases(client);
    init();
  }

  // Initialize
  void init() {
    client
        .setEndpoint(Constants.endpoint)
        .setProject(Constants.projectId)
        .setSelfSigned();
    loadUser();
  }

  // Load user details
  Future<void> loadUser() async {
    try {
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
      _userid = user.$id;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _userid = null;
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> createUserAccount({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: username,
      );
      
      // Automatically log in the user after account creation
      final loginResult = await createEmailSession(email: email, password: password);
      if (loginResult['success']) {
        // Save user data to Users collection
        final databaseAPI = databases;
        try {
          await databaseAPI.createDocument(
            databaseId: Constants.databaseId,
            collectionId: Constants.usersCollectionId,
            documentId: user.$id,
            data: {
              'userId': user.$id,
              'username': username,
              'email': email,
              'createdAt': DateTime.now().toIso8601String(),
            },
          );
          print('User data saved to Users collection');
        } catch (e) {
          print('Error saving user data to collection: $e');
        }
        
        print('User account created and logged in successfully');
        return {'success': true, 'message': 'Account created and logged in successfully'};
      } else {
        print('Account created but login failed');
        return {'success': false, 'message': 'Account created but login failed: ${loginResult['message']}'};
      }
    } catch (e) {
      print('Account creation error: $e');
      String errorMessage = 'Registration failed';
      
      if (e.toString().contains('user_already_exists')) {
        errorMessage = 'An account with this email already exists. Please use a different email or try logging in.';
      } else if (e.toString().contains('password')) {
        errorMessage = 'Password must be at least 8 characters long.';
      } else if (e.toString().contains('email')) {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Registration failed: ${e.toString()}';
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<Map<String, dynamic>> createEmailSession({
    required String email,
    required String password,
  }) async {
    try {
      await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final user = await account.get();
      _currentUser = user;
      _userid = user.$id;
      _status = AuthStatus.authenticated;
      
      // Save user data to SharedPreferences
      await SavedData.saveUserId(user.$id);
      await SavedData.saveUserEmail(user.email);
      await SavedData.saveUserName(user.name ?? 'User');
      print('User data saved: ${user.name ?? "User"}, ${user.email}');
      
      notifyListeners();
      return {'success': true, 'message': 'Login successful'};
    } catch (e) {
      print('Login error: $e');
      String errorMessage = 'Login failed';
      
      if (e.toString().contains('invalid_credentials')) {
        errorMessage = 'Invalid email or password. Please check your credentials.';
      } else if (e.toString().contains('user_not_found')) {
        errorMessage = 'No account found with this email. Please sign up first.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else {
        errorMessage = 'Login failed: ${e.toString()}';
      }
      
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<dynamic> signInWithProvider({required dynamic provider}) async {
    try {
      // OAuth implementation would go here
      _status = AuthStatus.authenticated;
      return {'success': true};
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      return {'error': e.toString()};
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _userid = null;
    } catch (e) {
      print('Sign out error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOutUser(BuildContext context) async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      _userid = null;
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      print('Sign out error: $e');
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    try {
      final prefs = await account.getPrefs();
      return prefs.data;
    } catch (e) {
      print('Error getting user preferences: $e');
      return {
        'theme': 'light',
        'notifications': true,
      };
    }
  }

  Future<void> updateUserPreferences(Map<String, dynamic> prefs) async {
    try {
      await account.updatePrefs(prefs: prefs);
    } catch (e) {
      print('Error updating user preferences: $e');
    }
  }

  Future<void> createEmailVerification({required String url}) async {
    try {
      await account.createVerification(url: url);
    } catch (e) {
      print('Error creating email verification: $e');
    }
  }

  Future<void> updateVerification({required String userId, required String secret}) async {
    try {
      await account.updateVerification(userId: userId, secret: secret);
    } catch (e) {
      print('Error updating verification: $e');
    }
  }

  // Password recovery
  Future<dynamic> createRecovery({required String email, required String url}) async {
    try {
      await account.createRecovery(email: email, url: url);
      return {'success': true};
    } catch (e) {
      print('Error creating password recovery: $e');
      return {'error': e.toString()};
    }
  }

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
    } catch (e) {
      print('Error updating password recovery: $e');
    }
  }
}
