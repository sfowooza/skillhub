// Stub implementations for Appwrite classes to allow building without Appwrite dependency
import 'dart:io' as io;

class Client {
  Client setEndpoint(String endpoint) => this;
  Client setProject(String project) => this;
  Client setSelfSigned({bool status = true}) => this;
}

class Account {
  Account(Client client);
  
  Future<User> get() async {
    return User(
      $id: 'stub_user_id',
      $createdAt: DateTime.now().toIso8601String(),
      $updatedAt: DateTime.now().toIso8601String(),
      name: 'Stub User',
      email: 'stub@example.com',
      phone: '',
      labels: [],
      prefs: Preferences(data: {}),
    );
  }
  
  Future<void> deleteSession({required String sessionId}) async {
    // Stub implementation
  }
  
  Future<Session> getSession({required String sessionId}) async {
    return Session(
      $id: sessionId,
      $createdAt: DateTime.now().toIso8601String(),
      userId: 'stub_user_id',
      expire: DateTime.now().add(Duration(days: 30)).toIso8601String(),
      provider: 'email',
      providerUid: 'stub@example.com',
      providerAccessToken: '',
      providerAccessTokenExpiry: '',
      providerRefreshToken: '',
      ip: '127.0.0.1',
      osCode: 'android',
      osName: 'Android',
      osVersion: '13',
      clientType: 'mobile',
      clientCode: 'flutter',
      clientName: 'Flutter',
      clientVersion: '3.0.0',
      clientEngine: 'dart',
      clientEngineVersion: '3.0.0',
      deviceName: 'Emulator',
      deviceBrand: 'Google',
      deviceModel: 'Android SDK',
      countryCode: 'US',
      countryName: 'United States',
      current: true,
    );
  }
  
  Future<Token> createVerification({required String url}) async {
    return Token(
      $id: 'stub_token_id',
      $createdAt: DateTime.now().toIso8601String(),
      userId: 'stub_user_id',
      secret: 'stub_secret',
      expire: DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      phrase: 'verification',
    );
  }
  
  Future<Token> createRecovery({required String email, required String url}) async {
    return Token(
      $id: 'stub_recovery_id',
      $createdAt: DateTime.now().toIso8601String(),
      userId: 'stub_user_id',
      secret: 'stub_recovery_secret',
      expire: DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      phrase: 'recovery',
    );
  }
  
  Future<Token> updateRecovery({
    required String userId,
    required String secret,
    required String password,
    required String passwordAgain,
  }) async {
    return Token(
      $id: 'stub_recovery_update_id',
      $createdAt: DateTime.now().toIso8601String(),
      userId: userId,
      secret: secret,
      expire: DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      phrase: 'recovery_update',
    );
  }
  
  Future<Session> createEmailPasswordSession({
    required String email,
    required String password,
  }) async {
    return Session(
      $id: 'stub_session_id',
      $createdAt: DateTime.now().toIso8601String(),
      userId: 'stub_user_id',
      expire: DateTime.now().add(Duration(days: 30)).toIso8601String(),
      provider: 'email',
      providerUid: email,
      providerAccessToken: '',
      providerAccessTokenExpiry: '',
      providerRefreshToken: '',
      ip: '127.0.0.1',
      osCode: 'android',
      osName: 'Android',
      osVersion: '13',
      clientType: 'mobile',
      clientCode: 'flutter',
      clientName: 'Flutter',
      clientVersion: '3.0.0',
      clientEngine: 'dart',
      clientEngineVersion: '3.0.0',
      deviceName: 'Emulator',
      deviceBrand: 'Google',
      deviceModel: 'Android SDK',
      countryCode: 'US',
      countryName: 'United States',
      current: true,
    );
  }
  
  Future<Session> createOAuth2Session({required OAuthProvider provider}) async {
    return Session(
      $id: 'stub_oauth_session_id',
      $createdAt: DateTime.now().toIso8601String(),
      userId: 'stub_user_id',
      expire: DateTime.now().add(Duration(days: 30)).toIso8601String(),
      provider: provider.toString(),
      providerUid: 'oauth_user',
      providerAccessToken: 'stub_access_token',
      providerAccessTokenExpiry: DateTime.now().add(Duration(hours: 1)).toIso8601String(),
      providerRefreshToken: 'stub_refresh_token',
      ip: '127.0.0.1',
      osCode: 'android',
      osName: 'Android',
      osVersion: '13',
      clientType: 'mobile',
      clientCode: 'flutter',
      clientName: 'Flutter',
      clientVersion: '3.0.0',
      clientEngine: 'dart',
      clientEngineVersion: '3.0.0',
      deviceName: 'Emulator',
      deviceBrand: 'Google',
      deviceModel: 'Android SDK',
      countryCode: 'US',
      countryName: 'United States',
      current: true,
    );
  }
  
  Future<Preferences> getPrefs() async {
    return Preferences(data: {'bio': 'Stub bio', 'phone': '123-456-7890'});
  }
  
  Future<User> updatePrefs({required Map<String, dynamic> prefs}) async {
    return User(
      $id: 'stub_user_id',
      $createdAt: DateTime.now().toIso8601String(),
      $updatedAt: DateTime.now().toIso8601String(),
      name: 'Stub User',
      email: 'stub@example.com',
      phone: prefs['phone'] ?? '',
      labels: [],
      prefs: Preferences(data: prefs),
    );
  }
  
  Future<User> create({
    required String userId,
    required String email,
    required String password,
    String? name,
  }) async {
    return User(
      $id: userId,
      $createdAt: DateTime.now().toIso8601String(),
      $updatedAt: DateTime.now().toIso8601String(),
      name: name ?? 'New User',
      email: email,
      phone: '',
      labels: [],
      prefs: Preferences(data: {}),
    );
  }
}

class Databases {
  Databases(Client client);
  
  Future<Document> getDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    return Document(
      $id: documentId,
      $collectionId: collectionId,
      $databaseId: databaseId,
      $createdAt: DateTime.now().toIso8601String(),
      $updatedAt: DateTime.now().toIso8601String(),
      $permissions: [],
      data: {'title': 'Stub Document', 'description': 'This is a stub document'},
    );
  }
  
  Future<DocumentList> listDocuments({
    required String databaseId,
    required String collectionId,
    List<String>? queries,
  }) async {
    return DocumentList(
      total: 0,
      documents: [],
    );
  }
  
  Future<Document> createDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    required Map<String, dynamic> data,
    List<String>? permissions,
  }) async {
    return Document(
      $id: documentId,
      $collectionId: collectionId,
      $databaseId: databaseId,
      $createdAt: DateTime.now().toIso8601String(),
      $updatedAt: DateTime.now().toIso8601String(),
      $permissions: permissions ?? [],
      data: data,
    );
  }
  
  Future<Document> updateDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
    Map<String, dynamic>? data,
    List<String>? permissions,
  }) async {
    return Document(
      $id: documentId,
      $collectionId: collectionId,
      $databaseId: databaseId,
      $createdAt: DateTime.now().toIso8601String(),
      $updatedAt: DateTime.now().toIso8601String(),
      $permissions: permissions ?? [],
      data: data ?? {},
    );
  }
  
  Future<void> deleteDocument({
    required String databaseId,
    required String collectionId,
    required String documentId,
  }) async {
    // Stub implementation
  }
}

class Storage {
  Storage(Client client);
  
  Future<void> deleteFile({
    required String bucketId,
    required String fileId,
  }) async {
    // Stub implementation
  }
  
  Future<AppwriteFile> createFile({
    required String bucketId,
    required String fileId,
    required InputFile file,
    List<String>? permissions,
  }) async {
    return AppwriteFile(
      $id: fileId,
      bucketId: bucketId,
      $createdAt: DateTime.now().toIso8601String(),
      $updatedAt: DateTime.now().toIso8601String(),
      $permissions: permissions ?? [],
      name: file.filename,
      signature: 'stub_signature',
      mimeType: 'application/octet-stream',
      sizeOriginal: 1024,
      chunksTotal: 1,
      chunksUploaded: 1,
    );
  }
}

class User {
  final String $id;
  final String $createdAt;
  final String $updatedAt;
  final String name;
  final String email;
  final String phone;
  final List<String> labels;
  final Preferences prefs;
  final bool emailVerification;
  
  User({
    required this.$id,
    required this.$createdAt,
    required this.$updatedAt,
    required this.name,
    required this.email,
    required this.phone,
    required this.labels,
    required this.prefs,
    this.emailVerification = true,
  });
}

class Document {
  final String $id;
  final String $collectionId;
  final String $databaseId;
  final String $createdAt;
  final String $updatedAt;
  final List<String> $permissions;
  final Map<String, dynamic> data;
  
  Document({
    required this.$id,
    required this.$collectionId,
    required this.$databaseId,
    required this.$createdAt,
    required this.$updatedAt,
    required this.$permissions,
    required this.data,
  });
}

class DocumentList {
  final int total;
  final List<Document> documents;
  
  DocumentList({
    required this.total,
    required this.documents,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'total': total,
      'documents': documents.map((doc) => doc.data).toList(),
    };
  }
}

class Preferences {
  final Map<String, dynamic> data;
  
  Preferences({required this.data});
}

class AppwriteException implements Exception {
  final String message;
  final String type;
  final int code;
  
  AppwriteException(this.message, {this.type = '', this.code = 0});
  
  @override
  String toString() => 'AppwriteException: $message';
}

enum OAuthProvider {
  google,
  github,
  apple,
}

class Session {
  final String $id;
  final String $createdAt;
  final String userId;
  final String expire;
  final String provider;
  final String providerUid;
  final String providerAccessToken;
  final String providerAccessTokenExpiry;
  final String providerRefreshToken;
  final String ip;
  final String osCode;
  final String osName;
  final String osVersion;
  final String clientType;
  final String clientCode;
  final String clientName;
  final String clientVersion;
  final String clientEngine;
  final String clientEngineVersion;
  final String deviceName;
  final String deviceBrand;
  final String deviceModel;
  final String countryCode;
  final String countryName;
  final bool current;
  
  Session({
    required this.$id,
    required this.$createdAt,
    required this.userId,
    required this.expire,
    required this.provider,
    required this.providerUid,
    required this.providerAccessToken,
    required this.providerAccessTokenExpiry,
    required this.providerRefreshToken,
    required this.ip,
    required this.osCode,
    required this.osName,
    required this.osVersion,
    required this.clientType,
    required this.clientCode,
    required this.clientName,
    required this.clientVersion,
    required this.clientEngine,
    required this.clientEngineVersion,
    required this.deviceName,
    required this.deviceBrand,
    required this.deviceModel,
    required this.countryCode,
    required this.countryName,
    required this.current,
  });
}

class InputFile {
  final String path;
  final String filename;
  final List<int>? bytes;
  
  InputFile({required this.path, required this.filename, this.bytes});
  
  static InputFile fromPath({required String path, String? filename}) {
    return InputFile(path: path, filename: filename ?? '');
  }
  
  static InputFile fromBytes({required List<int> bytes, required String filename}) {
    return InputFile(path: '', filename: filename, bytes: bytes);
  }
}

class ID {
  static String unique() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

class Query {
  static String equal(String attribute, dynamic value) {
    return 'equal("$attribute", $value)';
  }
  
  static String notEqual(String attribute, dynamic value) {
    return 'notEqual("$attribute", $value)';
  }
  
  static String lessThan(String attribute, dynamic value) {
    return 'lessThan("$attribute", $value)';
  }
  
  static String greaterThan(String attribute, dynamic value) {
    return 'greaterThan("$attribute", $value)';
  }
  
  static String search(String attribute, String value) {
    return 'search("$attribute", "$value")';
  }
  
  static String orderAsc(String attribute) {
    return 'orderAsc("$attribute")';
  }
  
  static String orderDesc(String attribute) {
    return 'orderDesc("$attribute")';
  }
  
  static String limit(int limit) {
    return 'limit($limit)';
  }
  
  static String offset(int offset) {
    return 'offset($offset)';
  }
}

class Token {
  final String $id;
  final String $createdAt;
  final String userId;
  final String secret;
  final String expire;
  final String phrase;
  
  Token({
    required this.$id,
    required this.$createdAt,
    required this.userId,
    required this.secret,
    required this.expire,
    required this.phrase,
  });
}

class AppwriteFile {
  final String $id;
  final String bucketId;
  final String $createdAt;
  final String $updatedAt;
  final List<String> $permissions;
  final String name;
  final String signature;
  final String mimeType;
  final int sizeOriginal;
  final int chunksTotal;
  final int chunksUploaded;
  
  AppwriteFile({
    required this.$id,
    required this.bucketId,
    required this.$createdAt,
    required this.$updatedAt,
    required this.$permissions,
    required this.name,
    required this.signature,
    required this.mimeType,
    required this.sizeOriginal,
    required this.chunksTotal,
    required this.chunksUploaded,
  });
}
