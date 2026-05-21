import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class AiWorkoutService {
  static Future<Map<String, dynamic>> generateWorkout({
    int daysPerWeek = 4,
    int durationMinutes = 60,
    String? focus,
    String? level,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/ai-workouts/generate");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "days_per_week": daysPerWeek,
        "duration_minutes": durationMinutes,
        "focus": focus,
        "level": level,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data["detail"] ?? "No se ha podido generar la rutina",
    );
  }
}