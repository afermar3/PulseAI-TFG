import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class ProfileService {
  static Future<Map<String, dynamic>> getProfile() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/profile/me");

    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data["detail"] ?? "No se ha podido cargar el perfil");
  }

  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? surname,
    String? gender,
    int? age,
    double? heightCm,
    double? weightKg,
    String? goal,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/profile/me");

    final Map<String, dynamic> body = {};

    if (name != null) body["name"] = name;
    if (surname != null) body["surname"] = surname;
    if (gender != null) body["gender"] = gender;
    if (age != null) body["age"] = age;
    if (heightCm != null) body["height_cm"] = heightCm;
    if (weightKg != null) body["weight_kg"] = weightKg;
    if (goal != null) body["goal"] = goal;

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data["detail"] ?? "No se ha podido actualizar el perfil");
  }
}