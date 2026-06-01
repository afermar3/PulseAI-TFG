import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_client.dart';
import 'token_storage.dart';

class ProgressPhotoService {
  static String _extractErrorMessage(dynamic data, String fallback) {
    if (data is Map && data["detail"] != null) {
      final detail = data["detail"];

      if (detail is String) {
        return detail;
      }

      if (detail is List && detail.isNotEmpty) {
        final firstError = detail.first;

        if (firstError is Map && firstError["msg"] != null) {
          return firstError["msg"].toString();
        }

        return detail.toString();
      }

      return detail.toString();
    }

    return fallback;
  }

  static MediaType _getImageMediaType(String fileName) {
    final lowerName = fileName.toLowerCase();

    if (lowerName.endsWith(".jpg") || lowerName.endsWith(".jpeg")) {
      return MediaType("image", "jpeg");
    }

    if (lowerName.endsWith(".png")) {
      return MediaType("image", "png");
    }

    if (lowerName.endsWith(".webp")) {
      return MediaType("image", "webp");
    }

    return MediaType("image", "jpeg");
  }

  static Future<List<Map<String, dynamic>>> getMyProgressPhotos({
    String? photoType,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/progress-photos/me").replace(
      queryParameters: photoType != null && photoType.isNotEmpty
          ? {
              "photo_type": photoType,
            }
          : null,
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final list = data as List<dynamic>;

      return list
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se han podido cargar las fotos de progreso",
      ),
    );
  }

  static Future<Map<String, dynamic>> getProgressPhotoDetail(
    int photoId,
  ) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/progress-photos/$photoId");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido cargar la foto de progreso",
      ),
    );
  }

  static Future<Map<String, dynamic>> uploadProgressPhoto({
    required String photoType,
    required String filePath,
    Uint8List? webBytes,
    String? fileName,
    double? weightKg,
    String? note,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/progress-photos");

    final request = http.MultipartRequest("POST", url);

    request.headers["Authorization"] = "Bearer $token";
    request.fields["photo_type"] = photoType;

    if (weightKg != null) {
      request.fields["weight_kg"] = weightKg.toString();
    }

    if (note != null && note.trim().isNotEmpty) {
      request.fields["note"] = note.trim();
    }

    if (kIsWeb) {
      if (webBytes == null || fileName == null || fileName.trim().isEmpty) {
        throw Exception("No se ha podido leer la imagen seleccionada");
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          "file",
          webBytes,
          filename: fileName,
          contentType: _getImageMediaType(fileName),
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          "file",
          filePath,
          contentType: _getImageMediaType(filePath),
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = null;
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido subir la foto de progreso",
      ),
    );
  }

  static Future<Map<String, dynamic>> updateProgressPhoto({
    required int photoId,
    String? photoType,
    double? weightKg,
    String? note,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/progress-photos/$photoId");

    final body = <String, dynamic>{};

    if (photoType != null) {
      body["photo_type"] = photoType;
    }

    if (weightKg != null) {
      body["weight_kg"] = weightKg;
    }

    if (note != null) {
      body["note"] = note;
    }

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido actualizar la foto de progreso",
      ),
    );
  }

  static Future<void> deleteProgressPhoto(int photoId) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/progress-photos/$photoId");

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = null;
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido eliminar la foto de progreso",
      ),
    );
  }

  static String buildImageUrl(String imageUrl) {
    if (imageUrl.startsWith("http")) {
      return imageUrl;
    }

    return "${ApiClient.baseUrl}$imageUrl";
  }
}