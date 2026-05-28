import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class SleepService {
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

  static Future<Map<String, dynamic>> startSleepSession() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep/start");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido iniciar el sueño",
      ),
    );
  }

  static Future<Map<String, dynamic>?> getActiveSleepSession() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep/active");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido cargar el sueño activo",
      ),
    );
  }

  static Future<Map<String, dynamic>?> getLatestSleepSession() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep/latest");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido cargar el último sueño",
      ),
    );
  }

  static Future<List<dynamic>> getMySleepSessions() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep/me");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as List<dynamic>;
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se han podido cargar las sesiones de sueño",
      ),
    );
  }

  static Future<Map<String, dynamic>> finishSleepSession({
    required int sleepSessionId,
    String? quality,
    String? notes,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse(
      "${ApiClient.baseUrl}/sleep/$sleepSessionId/finish",
    );

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "quality": quality,
        "notes": notes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido finalizar el sueño",
      ),
    );
  }
}