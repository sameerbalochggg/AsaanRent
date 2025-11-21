import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
class ImageCompressor {
  static Future<File> compressImage(XFile xfile) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = "${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";

    final XFile? result = await FlutterImageCompress.compressAndGetFile(
      xfile.path,
      targetPath,
      minWidth: 1920,
      minHeight: 1080,
      quality: 80,
    );

    if (result == null) {
      throw Exception('Failed to compress image');
    }
    debugPrint('Original size: ${await xfile.length()} bytes');
    debugPrint('Compressed size: ${await result.length()} bytes');
    return File(result.path);
  }
}