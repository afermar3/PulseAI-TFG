import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class WorkoutPlanService {
  static Future<Map<String, dynamic>> saveWorkoutPlan({
    required Map<String, dynamic> workout,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-plans");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "title": workout["title"] ?? "Rutina personalizada",
        "summary": workout["summary"],
        "goal": workout["goal"],
        "level": workout["level"],
        "days_per_week": workout["days_per_week"],
        "duration_minutes": workout["duration_minutes"],
        "content": workout,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data["detail"] ?? "No se ha podido guardar la rutina");
  }

  static Future<Map<String, dynamic>> updateWorkoutPlan({
    required int workoutId,
    required Map<String, dynamic> workout,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-plans/$workoutId");

    final response = await http.patch(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "title": workout["title"] ?? "Rutina personalizada",
        "summary": workout["summary"],
        "goal": workout["goal"],
        "level": workout["level"],
        "days_per_week": workout["days_per_week"],
        "duration_minutes": workout["duration_minutes"],
        "content": workout,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data["detail"] ?? "No se ha podido actualizar la rutina");
  }

  static Future<List<dynamic>> getMyWorkoutPlans() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-plans/me");

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

    throw Exception(data["detail"] ?? "No se han podido cargar las rutinas");
  }

  static Future<Map<String, dynamic>?> getActiveWorkoutPlan() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-plans/active");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 404) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data["detail"] ?? "No se ha podido cargar la rutina activa");
  }

  static Future<Map<String, dynamic>> activateWorkoutPlan(int workoutId) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse(
      "${ApiClient.baseUrl}/workout-plans/$workoutId/activate",
    );

    final response = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data["detail"] ?? "No se ha podido activar la rutina");
  }

  static Future<void> deleteWorkoutPlan(int workoutId) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/workout-plans/$workoutId");

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

    throw Exception(data["detail"] ?? "No se ha podido eliminar la rutina");
  }
}