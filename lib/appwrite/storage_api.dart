import 'dart:io' as io;
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:skillhub/appwrite/auth_api.dart';
import 'package:skillhub/constants/constants.dart';
import 'package:flutter/material.dart';

class StorageAPI extends ChangeNotifier {
  final AuthAPI auth;
  late final Storage storage;

  StorageAPI({required this.auth}) {
    storage = Storage(auth.client);
  }

  Future<String?> uploadFile(io.File file) async {
    try {
      final fileId = ID.unique();
      
      final response = await storage.createFile(
        bucketId: Constants.bucketId,
        fileId: fileId,
        file: InputFile.fromPath(path: file.path),
      );

      print('File uploaded successfully: ${response.$id}');
      return response.$id;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      await storage.deleteFile(
        bucketId: Constants.bucketId,
        fileId: fileId,
      );
      print('File deleted successfully: $fileId');
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  String getFileUrl(String fileId) {
    return '${Constants.endpoint}/storage/buckets/${Constants.bucketId}/files/$fileId/view?project=${Constants.projectId}';
  }

  Future<io.File?> getFile(String fileId) async {
    try {
      final response = await storage.getFileView(
        bucketId: Constants.bucketId,
        fileId: fileId,
      );
      
      // Save to temporary file
      final tempDir = io.Directory.systemTemp;
      final tempFile = io.File('${tempDir.path}/$fileId');
      await tempFile.writeAsBytes(response);
      
      return tempFile;
    } catch (e) {
      print('Error getting file: $e');
      return null;
    }
  }
}
