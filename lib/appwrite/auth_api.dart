import 'package:flutter/widgets.dart';
import 'package:skillhub/appwrite/database_api.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends ChangeNotifier {
  late DatabaseAPI database;
  
  String _currentUserId = 'test_user_id';
  String _currentUserName = 'Test User';
  String _currentUserEmail = 'test@example.com';
  AuthStatus _status = AuthStatus.authenticated; // Default to authenticated for simplified app

  // Constructor
  AuthAPI({dynamic client}) {
    database = DatabaseAPI(auth: this);
    init();
  }

  // Initialize
  void init() {
    loadUser();
  }

  // Getter methods
  AuthStatus get status => _status;
  String? get username => _currentUserName;
  String? get email => _currentUserEmail;
  String? get userid => _currentUserId;
  
  // Mock currentUser object for compatibility
  get currentUser => {
    'emailVerification': true,
    'name': _currentUserName,
    'email': _currentUserEmail,
    'id': _currentUserId,
  };

  // Load user details
  Future<void> loadUser() async {
    try {
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  Future<String> createUser({required String email, required String password, required String username}) async {
    try {
      // Simulate user creation
      _currentUserEmail = email;
      _currentUserName = username;
      _currentUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      
      // Save user data to database
      await database.saveUserData(_currentUserId, username, email);
      
      return "success";
    } catch (e) {
      return e.toString();
    } finally {
      notifyListeners();
    }
  }

  Future<bool> createEmailSession({required String email, required String password}) async {
    try {
      _currentUserEmail = email;
      _status = AuthStatus.authenticated;
      
      await database.getUserData();
      print('Login successful');
      return true;
    } catch (e) {
      print('Login error: $e');
      return false;
    } finally {
      notifyListeners();
    }
  }

  Future<dynamic> signInWithProvider({required dynamic provider}) async {
    try {
      _status = AuthStatus.authenticated;
      return {'success': true};
    } finally {
      notifyListeners();
    }
  }

  Future<void> signOut(BuildContext context) async {
    try {
      _status = AuthStatus.unauthenticated;
      notifyListeners();

      // Navigate to the HomePage() widget after successful sign out
      Navigator.pushReplacementNamed(context, '/');
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> getUserPreferences() async {
    return {
      'bio': 'Test bio',
      'phone': '+1234567890'
    };
  }

  updatePreferences({required String bio, required String phone, String? profileImage}) async {
    print('Updated preferences: bio=$bio, phone=$phone');
    return {'success': true};
  }

  // Check if the user has a session
  Future<bool> checkSessions() async {
    return _status == AuthStatus.authenticated;
  }

  // Email verification
  Future<dynamic> createEmailVerification({required String url}) async {
    print('Email verification sent to: $url');
    return {'success': true};
  }

  // Password recovery
  Future<dynamic> createRecovery({required String email, required String url}) async {
    print('Password recovery sent to: $email');
    return {'success': true};
  }

  Future<void> updateRecovery({
    required String userId,
    required String secret,
    required String password,
  }) async {
    print('Password updated for user: $userId');
  }
}
