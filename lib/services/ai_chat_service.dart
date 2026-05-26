import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class AiChatService {
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

  static Future<Map<String, dynamic>> sendMessage(String message) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/ai-chat/message");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "message": message,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido obtener respuesta de la IA",
      ),
    );
  }

  static Future<Map<String, dynamic>> applyPendingAction({
    required Map<String, dynamic> pendingAction,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/ai-chat/apply-action");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "pending_action": pendingAction,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido aplicar la acción del Coach IA",
      ),
    );
  }
}