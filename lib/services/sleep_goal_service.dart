import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_client.dart';
import 'token_storage.dart';

class SleepGoalService {
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

  static Future<Map<String, dynamic>?> getMySleepGoal() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep-goal/me");

    final response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (data == null) {
        return null;
      }

      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido cargar el objetivo de sueño",
      ),
    );
  }

  static Future<Map<String, dynamic>> saveSleepGoal({
    required String bedTime,
    required String wakeTime,
    required int targetMinutes,
    required String repeat,
    required bool enabled,
  }) async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep-goal/me");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "bed_time": bedTime,
        "wake_time": wakeTime,
        "target_minutes": targetMinutes,
        "repeat": repeat,
        "enabled": enabled,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido guardar el objetivo de sueño",
      ),
    );
  }

  static Future<Map<String, dynamic>> toggleSleepGoal() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep-goal/me/toggle");

    final response = await http.patch(
      url,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(data as Map);
    }

    throw Exception(
      _extractErrorMessage(
        data,
        "No se ha podido cambiar el estado del objetivo de sueño",
      ),
    );
  }

  static Future<void> deleteSleepGoal() async {
    final token = await TokenStorage.getToken();

    if (token == null) {
      throw Exception("No hay sesión iniciada");
    }

    final url = Uri.parse("${ApiClient.baseUrl}/sleep-goal/me");

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
      _extractErrorMessage(
        data,
        "No se ha podido eliminar el objetivo de sueño",
      ),
    );
  }
}