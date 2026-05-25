import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class WorkoutProgressService {
  static Future<Map<String, dynamic>> getDayProgress({
    int? savedWorkoutId,
    int? scheduledWorkoutId,
    int? dayNumber,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final queryParams = <String, String>{};

    if (savedWorkoutId != null) {
      queryParams["saved_workout_id"] = savedWorkoutId.toString();
    }

    if (scheduledWorkoutId != null) {
      queryParams["scheduled_workout_id"] = scheduledWorkoutId.toString();
    }

    if (dayNumber != null) {
      queryParams["day_number"] = dayNumber.toString();
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-progress/day").replace(
      queryParameters: queryParams,
    );

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

    throw Exception(data["detail"] ?? "No se ha podido cargar el progreso");
  }

  static Future<Map<String, dynamic>> toggleExerciseProgress({
    int? savedWorkoutId,
    int? scheduledWorkoutId,
    int? dayNumber,
    required int exerciseIndex,
    int? exerciseId,
    required String exerciseName,
    required bool completed,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-progress/toggle");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "saved_workout_id": savedWorkoutId,
        "scheduled_workout_id": scheduledWorkoutId,
        "day_number": dayNumber,
        "exercise_index": exerciseIndex,
        "exercise_id": exerciseId,
        "exercise_name": exerciseName,
        "completed": completed,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data["detail"] ?? "No se ha podido actualizar el progreso");
  }

  static Future<void> clearDayProgress({
    int? savedWorkoutId,
    int? scheduledWorkoutId,
    int? dayNumber,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final queryParams = <String, String>{};

    if (savedWorkoutId != null) {
      queryParams["saved_workout_id"] = savedWorkoutId.toString();
    }

    if (scheduledWorkoutId != null) {
      queryParams["scheduled_workout_id"] = scheduledWorkoutId.toString();
    }

    if (dayNumber != null) {
      queryParams["day_number"] = dayNumber.toString();
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-progress/day").replace(
      queryParameters: queryParams,
    );

    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    final data = jsonDecode(response.body);

    throw Exception(data["detail"] ?? "No se ha podido limpiar el progreso");
  }
}