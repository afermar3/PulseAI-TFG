import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class AiChatService {
  static Future<String> sendMessage(String message) async {
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
      return data["answer"]?.toString() ?? "";
    }

    throw Exception(
      data["detail"] ?? "No se ha podido obtener respuesta de la IA",
    );
  }
}