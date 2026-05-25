import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class ScheduledWorkoutService {
  static Future<Map<String, dynamic>> createScheduledWorkout({
    required int? savedWorkoutId,
    required String workoutTitle,
    required int? dayNumber,
    required String? dayName,
    required DateTime scheduledDate,
    required int? durationMinutes,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/scheduled-workouts");

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
        "scheduled_date": scheduledDate.toIso8601String(),
        "duration_minutes": durationMinutes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data["detail"] ?? "No se ha podido programar el entrenamiento",
    );
  }

  static Future<List<dynamic>> getMyScheduledWorkouts() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/scheduled-workouts/me");

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
      data["detail"] ?? "No se han podido cargar los entrenamientos programados",
    );
  }

  static Future<Map<String, dynamic>> completeScheduledWorkout(
    int scheduledWorkoutId, {
    int? totalExercises,
    int? completedExercises,
    int? durationMinutes,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse(
      "${ApiClient.baseUrl}/scheduled-workouts/$scheduledWorkoutId/complete",
    );

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "total_exercises": totalExercises,
        "completed_exercises": completedExercises,
        "duration_minutes": durationMinutes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(
      data["detail"] ?? "No se ha podido completar el entrenamiento",
    );
  }

  static Future<void> deleteScheduledWorkout(int scheduledWorkoutId) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse(
      "${ApiClient.baseUrl}/scheduled-workouts/$scheduledWorkoutId",
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

    throw Exception(
      data["detail"] ?? "No se ha podido eliminar el entrenamiento programado",
    );
  }
}