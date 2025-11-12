import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

final _supabase = Supabase.instance.client;

class StorageRepository {
  /// Uploads a file to Supabase Storage and returns the public URL.
  Future<String> uploadFile(File file, String bucketName) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      await _supabase.storage.from(bucketName).upload(
            fileName,
            file,
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: false),
          );

      return _supabase.storage.from(bucketName).getPublicUrl(fileName);
    } catch (e) {
      rethrow;
    }
  }
}