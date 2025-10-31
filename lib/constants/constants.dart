import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String get endpoint => dotenv.env['APPWRITE_ENDPOINT'] ?? 'https://skillhub.avodahsystems.com/v1';
  static String get projectId => dotenv.env['APPWRITE_PROJECT_ID'] ?? '68fbf8c7000da2a66231';
  static String get apiSecret => dotenv.env['APPWRITE_API_SECRET'] ?? '';
  static String get databaseId => dotenv.env['APPWRITE_DATABASE_ID'] ?? '68fbfa9400035f96086e';
  static String get skillsCollectionId => dotenv.env['APPWRITE_SKILLS_COLLECTION_ID'] ?? '68fbfb01002ca99ab18e';
  static String get usersCollectionId => dotenv.env['APPWRITE_USERS_COLLECTION_ID'] ?? '68fbfac7001c7f6979e3';
  static String get ratingsCollectionId => dotenv.env['APPWRITE_RATINGS_COLLECTION_ID'] ?? 'ratings';
  static String get likesCollectionId => dotenv.env['APPWRITE_LIKES_COLLECTION_ID'] ?? 'likes_collection';
  static String get bucketId => dotenv.env['APPWRITE_BUCKET_ID'] ?? '68fbfb3a000e00303687';
  static String get photosBucketId => dotenv.env['APPWRITE_PHOTOS_BUCKET_ID'] ?? '690467e10027d9964429';
}