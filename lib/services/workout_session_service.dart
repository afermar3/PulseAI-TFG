import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class WorkoutSessionService {
  static Future<Map<String, dynamic>> createWorkoutSession({
    required int? savedWorkoutId,
    required String workoutTitle,
    required int? dayNumber,
    required String? dayName,
    required int totalExercises,
    required int completedExercises,
    required int? durationMinutes,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-sessions");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "saved_workout_id": savedWorkoutId,
        "workout_title": workoutTitle,
        "day_number": dayNumber,
        "day_name": dayName,
        "total_exercises": totalExercises,
        "completed_exercises": completedExercises,
        "duration_minutes": durationMinutes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data["detail"] ?? "No se ha podido guardar la sesión");
  }

  static Future<List<dynamic>> getMyWorkoutSessions() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-sessions/me");

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

    throw Exception(data["detail"] ?? "No se han podido cargar las sesiones");
  }

  static Future<Map<String, dynamic>> getWorkoutSummary() async {
  final token = await TokenStorage.getToken();

  if (token == null) {
    throw Exception("No hay sesión iniciada");
  }

  final url = Uri.parse("${ApiClient.baseUrl}/workout-sessions/summary");

  final response = await http.get(
    url,
    headers: {
      "Authorization": "Bearer $token",
    },
  );

  final data = jsonDecode(response.body);

  if (response.statusCode == 200) {
    return data as Map<String, dynamic>;
  }

  throw Exception(data["detail"] ?? "No se ha podido cargar el resumen");
}
}