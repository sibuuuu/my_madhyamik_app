// lib/services/imgbb_service.dart
//
// Image upload service for Madhyamik Shokha using imgBB API.
// Developer: Sibnath Bairagi

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ImgbbService {
  ImgbbService._();

  // =====================================================================
  // 🔴 REPLACE WITH YOUR REAL API KEY FROM imgbb.com
  // =====================================================================
  static const String _apiKey = '530155b328a82380ece204a9f1a23935';

  static const String _uploadUrl =
      'https://api.imgbb.com/1/upload';

  // =====================================================================
  // UPLOAD FROM BYTES (works on Web + Mobile)
  // =====================================================================
  static Future<String?> uploadBytes(
    Uint8List bytes, {
    String name = 'image',
  }) async {
    try {
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(_uploadUrl),
        body: {
          'key': _apiKey,
          'image': base64Image,
          'name': name,
        },
      );

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body);
      if (json is! Map) return null;

      final data = json['data'];
      if (data is! Map) return null;

      final url = data['url']?.toString();
      return url;
    } catch (_) {
      return null;
    }
  }

  // =====================================================================
  // UPLOAD FROM FILE (mobile only)
  // =====================================================================
  static Future<String?> uploadFile(
    File file, {
    String name = 'image',
  }) async {
    try {
      final bytes = await file.readAsBytes();
      return uploadBytes(bytes, name: name);
    } catch (_) {
      return null;
    }
  }

  // =====================================================================
  // UPLOAD FROM PATH (helper)
  // =====================================================================
  static Future<String?> uploadPath(
    String path, {
    String name = 'image',
  }) async {
    if (kIsWeb) return null;
    return uploadFile(File(path), name: name);
  }
}