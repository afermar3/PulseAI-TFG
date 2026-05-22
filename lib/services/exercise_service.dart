import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';

class ExerciseService {
  static Future<List<dynamic>> getExercises({
    String? muscleGroup,
    String? difficulty,
    String? category,
  }) async {
    final queryParams = <String, String>{};

    if (muscleGroup != null && muscleGroup.trim().isNotEmpty) {
      queryParams["muscle_group"] = muscleGroup.trim();
    }

    if (difficulty != null && difficulty.trim().isNotEmpty) {
      queryParams["difficulty"] = difficulty.trim();
    }

    if (category != null && category.trim().isNotEmpty) {
      queryParams["category"] = category.trim();
    }

    final url = Uri.parse("${ApiClient.baseUrl}/exercises").replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as List<dynamic>;
    }

    throw Exception(data["detail"] ?? "No se han podido cargar los ejercicios");
  }

  static Future<Map<String, dynamic>> getExerciseById(int exerciseId) async {
    final url = Uri.parse("${ApiClient.baseUrl}/exercises/$exerciseId");

    final response = await http.get(url);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data as Map<String, dynamic>;
    }

    throw Exception(data["detail"] ?? "No se ha podido cargar el ejercicio");
  }
}