import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class AuthService {
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("${ApiClient.baseUrl}/auth/register");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data["access_token"];
      final user = data["user"];

      await TokenStorage.saveSession(
        token: token,
        email: user["email"],
        userId: user["id"],
      );

      return data;
    }

    throw Exception(data["detail"] ?? "Error al registrar usuario");
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("${ApiClient.baseUrl}/auth/login");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data["access_token"];
      final user = data["user"];

      await TokenStorage.saveSession(
        token: token,
        email: user["email"],
        userId: user["id"],
      );

      return data;
    }

    if (response.statusCode == 401) {
  throw Exception("Correo o contraseña incorrectos");
}

throw Exception(data["detail"] ?? "No se ha podido iniciar sesión");
  }

  static Future<void> logout() async {
    await TokenStorage.clearSession();
  }
}