import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:afermar3_tf_ipc/services/scheduled_workout_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_goal_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:flutter/material.dart';

import '../../widgets/color_extension.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final scheduled = await ScheduledWorkoutService.getMyScheduledWorkouts();
      final sessions = await WorkoutSessionService.getMyWorkoutSessions();

      Map<String, dynamic>? activeSleep;
      Map<String, dynamic>? latestSleep;
      Map<String, dynamic>? effectiveSleepGoal;
      List<Map<String, dynamic>> progressPhotos = [];

      try {
        activeSleep = await SleepService.getActiveSleepSession();
      } catch (_) {}

      try {
        latestSleep = await SleepService.getLatestSleepSession();
      } catch (_) {}

      try {
        effectiveSleepGoal =
            await SleepGoalService.getEffectiveSleepGoalToday();
      } catch (_) {}

      try {
        progressPhotos = await ProgressPhotoService.getMyProgressPhotos();
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _notifications = _buildDynamicNotifications(
          scheduledWorkouts: scheduled,
          workoutSessions: sessions,
          activeSleepSession: activeSleep,
          latestSleepSession: latestSleep,
          effectiveSleepGoal: effectiveSleepGoal,
          progressPhotos: progressPhotos,
        );
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildDynamicNotifications({
    required List<dynamic> scheduledWorkouts,
    required List<dynamic> workoutSessions,
    required Map<String, dynamic>? activeSleepSession,
    required Map<String, dynamic>? latestSleepSession,
    required Map<String, dynamic>? effectiveSleepGoal,
    required List<Map<String, dynamic>> progressPhotos,
  }) {
    final notifications = <Map<String, dynamic>>[];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    _addWorkoutNotifications(
      notifications: notifications,
      scheduledWorkouts: scheduledWorkouts,
      workoutSessions: workoutSessions,
      today: today,
      weekStart: weekStart,
      weekEnd: weekEnd,
    );

    _addSleepNotifications(
      notifications: notifications,
      activeSleepSession: activeSleepSession,
      latestSleepSession: latestSleepSession,
      effectiveSleepGoal: effectiveSleepGoal,
      today: today,
    );

    _addProgressPhotoNotifications(
      notifications: notifications,
      progressPhotos: progressPhotos,
    );

    return notifications;
  }

  void _addWorkoutNotifications({
    required List<Map<String, dynamic>> notifications,
    required List<dynamic> scheduledWorkouts,
    required List<dynamic> workoutSessions,
    required DateTime today,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) {
    final todayScheduled = <Map<String, dynamic>>[];
    int weeklyScheduled = 0;
    int weeklyCompletedScheduled = 0;

    for (final item in scheduledWorkouts) {
      if (item is! Map) continue;

      final scheduled = Map<String, dynamic>.from(item);
      final scheduledDate = _parseDate(scheduled["scheduled_date"]);

      if (scheduledDate == null) continue;

      final scheduledDay = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      if (!scheduledDay.isBefore(weekStart) && scheduledDay.isBefore(weekEnd)) {
        weeklyScheduled++;

        if (scheduled["completed"] == true) {
          weeklyCompletedScheduled++;
        }
      }

      if (_isSameDay(scheduledDay, today)) {
        todayScheduled.add(scheduled);
      }
    }

    todayScheduled.sort((a, b) {
      final aCompleted = a["completed"] == true;
      final bCompleted = b["completed"] == true;

      if (aCompleted == bCompleted) return 0;
      return aCompleted ? 1 : -1;
    });

    if (todayScheduled.isNotEmpty) {
      final firstToday = todayScheduled.first;
      final completed = firstToday["completed"] == true;

      notifications.add({
        "type": completed ? "today_completed" : "today_pending",
        "title": completed
            ? "Entrenamiento de hoy completado"
            : "Tienes entrenamiento hoy",
        "message": completed
            ? "${_formatWorkoutTitle(firstToday)} ya está completado."
            : "${_formatWorkoutTitle(firstToday)} · ${_formatDuration(firstToday["duration_minutes"])} pendiente.",
        "time": "Hoy",
        "icon": completed
            ? Icons.check_circle_rounded
            : Icons.fitness_center_rounded,
        "color": completed ? Colors.green : const Color(0xffC00000),
        "payload": firstToday,
      });
    } else {
      notifications.add({
        "type": "no_today_workout",
        "title": "Sin entrenamiento programado",
        "message":
            "No tienes una actividad programada para hoy. Puedes crearla desde el Coach IA.",
        "time": "Hoy",
        "icon": Icons.event_busy_rounded,
        "color": const Color(0xffC00000),
        "payload": null,
      });
    }

    final parsedSessions = <Map<String, dynamic>>[];
    int weeklySessions = 0;
    int weeklyMinutes = 0;
    int todaySessions = 0;

    for (final item in workoutSessions) {
      if (item is! Map) continue;

      final session = Map<String, dynamic>.from(item);
      final completedAt = _parseDate(session["completed_at"]);

      if (completedAt == null) continue;

      session["_completed_at_parsed"] = completedAt;
      parsedSessions.add(session);

      final sessionDay = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );

      final duration = _toInt(session["duration_minutes"]) ?? 0;

      if (_isSameDay(sessionDay, today)) {
        todaySessions++;
      }

      if (!sessionDay.isBefore(weekStart) && sessionDay.isBefore(weekEnd)) {
        weeklySessions++;
        weeklyMinutes += duration;
      }
    }

    parsedSessions.sort((a, b) {
      final aDate = a["_completed_at_parsed"] as DateTime;
      final bDate = b["_completed_at_parsed"] as DateTime;

      return bDate.compareTo(aDate);
    });

    if (todaySessions > 0) {
      notifications.add({
        "type": "today_sessions",
        "title": "Actividad registrada hoy",
        "message": todaySessions == 1
            ? "Has completado 1 sesión hoy."
            : "Has completado $todaySessions sesiones hoy.",
        "time": "Hoy",
        "icon": Icons.local_fire_department_rounded,
        "color": const Color(0xffC00000),
        "payload": null,
      });
    }

    notifications.add({
      "type": "weekly_summary",
      "title": "Resumen semanal",
      "message":
          "$weeklySessions sesiones completadas · $weeklyMinutes minutos entrenados.",
      "time": "Esta semana",
      "icon": Icons.show_chart_rounded,
      "color": const Color(0xffC00000),
      "payload": null,
    });

    if (weeklyScheduled > 0) {
      notifications.add({
        "type": "weekly_goal",
        "title": "Progreso de agenda",
        "message":
            "$weeklyCompletedScheduled de $weeklyScheduled entrenamientos programados completados esta semana.",
        "time": "Esta semana",
        "icon": Icons.flag_rounded,
        "color": const Color(0xffC00000),
        "payload": null,
      });
    }

    if (parsedSessions.isNotEmpty) {
      final lastSession = parsedSessions.first;

      notifications.add({
        "type": "last_session",
        "title": "Último entrenamiento",
        "message":
            "${_formatSessionTitle(lastSession)} · ${_formatSessionSubtitle(lastSession)}.",
        "time": _formatRelativeTime(
          lastSession["_completed_at_parsed"] as DateTime,
        ),
        "icon": Icons.history_rounded,
        "color": const Color(0xffC00000),
        "payload": lastSession,
      });
    } else {
      notifications.add({
        "type": "start_training",
        "title": "Empieza tu progreso",
        "message":
            "Completa tu primer entrenamiento para ver estadísticas reales.",
        "time": "Hoy",
        "icon": Icons.play_circle_outline_rounded,
        "color": const Color(0xffC00000),
        "payload": null,
      });
    }
  }

  void _addSleepNotifications({
    required List<Map<String, dynamic>> notifications,
    required Map<String, dynamic>? activeSleepSession,
    required Map<String, dynamic>? latestSleepSession,
    required Map<String, dynamic>? effectiveSleepGoal,
    required DateTime today,
  }) {
    if (activeSleepSession != null) {
      final startTime = _parseDate(activeSleepSession["start_time"]);

      notifications.add({
        "type": "sleep_active",
        "title": "Sueño en curso",
        "message": startTime == null
            ? "Tienes una sesión de sueño activa."
            : "Empezaste a dormir ${_formatRelativeTime(startTime).toLowerCase()}.",
        "time": "Ahora",
        "icon": Icons.bedtime_rounded,
        "color": Colors.indigo,
        "payload": activeSleepSession,
      });

      return;
    }

    if (latestSleepSession != null) {
      final endTime = _parseDate(latestSleepSession["end_time"]);
      final startTime = _parseDate(latestSleepSession["start_time"]);
      final duration = _toInt(latestSleepSession["duration_minutes"]);

      final referenceDate = endTime ?? startTime;

      if (referenceDate != null) {
        final sleepDay = DateTime(
          referenceDate.year,
          referenceDate.month,
          referenceDate.day,
        );

        if (_isSameDay(sleepDay, today)) {
          notifications.add({
            "type": "sleep_today",
            "title": "Sueño registrado hoy",
            "message": duration != null && duration > 0
                ? "Has dormido ${_formatMinutesAsHours(duration)}."
                : "Has registrado una sesión de sueño hoy.",
            "time": "Hoy",
            "icon": Icons.hotel_rounded,
            "color": Colors.indigo,
            "payload": latestSleepSession,
          });
        } else {
          notifications.add({
            "type": "sleep_latest",
            "title": "Último sueño registrado",
            "message": duration != null && duration > 0
                ? "Tu último sueño fue de ${_formatMinutesAsHours(duration)}."
                : "Tienes una sesión de sueño registrada anteriormente.",
            "time": _formatRelativeTime(referenceDate),
            "icon": Icons.nights_stay_rounded,
            "color": Colors.indigo,
            "payload": latestSleepSession,
          });
        }
      }
    } else {
      notifications.add({
        "type": "sleep_empty",
        "title": "Sin registros de sueño",
        "message":
            "Cuando te vayas a dormir, pulsa iniciar sueño para registrar tu descanso.",
        "time": "Hoy",
        "icon": Icons.bedtime_outlined,
        "color": Colors.indigo,
        "payload": null,
      });
    }

    final goal = _extractEffectiveGoal(effectiveSleepGoal);

    if (goal != null) {
      final bedTime = goal["bed_time"]?.toString() ?? "--:--";
      final wakeTime = goal["wake_time"]?.toString() ?? "--:--";
      final targetMinutes = _toInt(goal["target_minutes"]);
      final goalType = goal["goal_type"]?.toString() ?? "";

      notifications.add({
        "type": "sleep_goal_today",
        "title": "Objetivo de sueño de hoy",
        "message":
            "${SleepGoalService.goalTypeLabel(goalType)} · $bedTime - $wakeTime · ${_formatMinutesAsHours(targetMinutes ?? 0)}.",
        "time": "Hoy",
        "icon": Icons.alarm_rounded,
        "color": Colors.indigo,
        "payload": goal,
      });
    }
  }

  void _addProgressPhotoNotifications({
    required List<Map<String, dynamic>> notifications,
    required List<Map<String, dynamic>> progressPhotos,
  }) {
    if (progressPhotos.isEmpty) {
      notifications.add({
        "type": "progress_photo_empty",
        "title": "Añade tu primera foto",
        "message":
            "Registra una foto de progreso para comparar tu evolución física.",
        "time": "Evolución",
        "icon": Icons.photo_camera_rounded,
        "color": Colors.purple,
        "payload": null,
      });

      return;
    }

    final parsedPhotos = progressPhotos.map((photo) {
      final copy = Map<String, dynamic>.from(photo);
      copy["_created_at_parsed"] = _parseDate(copy["created_at"]);
      return copy;
    }).toList();

    parsedPhotos.sort((a, b) {
      final aDate = a["_created_at_parsed"] as DateTime?;
      final bDate = b["_created_at_parsed"] as DateTime?;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });

    final latestPhoto = parsedPhotos.first;
    final latestDate = latestPhoto["_created_at_parsed"] as DateTime?;
    final totalPhotos = progressPhotos.length;

    notifications.add({
      "type": "progress_photo_summary",
      "title": "Fotos de progreso",
      "message": totalPhotos == 1
          ? "Tienes 1 foto registrada. Añade otra para comparar tu evolución."
          : "Tienes $totalPhotos fotos registradas para comparar tu evolución.",
      "time": "Evolución",
      "icon": Icons.photo_library_rounded,
      "color": Colors.purple,
      "payload": null,
    });

    if (latestDate != null) {
      final daysSince = DateTime.now().difference(latestDate).inDays;

      if (daysSince >= 14) {
        notifications.add({
          "type": "progress_photo_reminder",
          "title": "Actualiza tu foto de progreso",
          "message":
              "Hace $daysSince días que no subes una foto. Añade una nueva para ver tu evolución.",
          "time": _formatRelativeTime(latestDate),
          "icon": Icons.add_a_photo_rounded,
          "color": Colors.purple,
          "payload": latestPhoto,
        });
      } else {
        notifications.add({
          "type": "progress_photo_latest",
          "title": "Última foto de progreso",
          "message":
              "${_photoTypeLabel(latestPhoto["photo_type"]?.toString())} registrada ${_formatRelativeTime(latestDate).toLowerCase()}.",
          "time": _formatRelativeTime(latestDate),
          "icon": Icons.image_rounded,
          "color": Colors.purple,
          "payload": latestPhoto,
        });
      }
    }
  }

  Map<String, dynamic>? _extractEffectiveGoal(Map<String, dynamic>? response) {
    if (response == null) return null;

    if (response["goal"] is Map) {
      return Map<String, dynamic>.from(response["goal"] as Map);
    }

    if (response["sleep_goal"] is Map) {
      return Map<String, dynamic>.from(response["sleep_goal"] as Map);
    }

    if (response["bed_time"] != null && response["wake_time"] != null) {
      return response;
    }

    return null;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDuration(dynamic value) {
    final duration = _toInt(value);

    if (duration == null || duration <= 0) {
      return "Duración no definida";
    }

    return "$duration min";
  }

  String _formatMinutesAsHours(int minutes) {
    if (minutes <= 0) {
      return "duración no definida";
    }

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours <= 0) {
      return "${mins}min";
    }

    if (mins == 0) {
      return "${hours}h";
    }

    return "${hours}h ${mins}min";
  }

  String _formatWorkoutTitle(Map<String, dynamic> item) {
    final workoutTitle = item["workout_title"]?.toString() ?? "Entrenamiento";
    final dayNumber = item["day_number"];
    final dayName = item["day_name"]?.toString();

    if (dayNumber != null && dayName != null && dayName.trim().isNotEmpty) {
      return "Día $dayNumber - $dayName";
    }

    return workoutTitle;
  }

  String _formatSessionTitle(Map<String, dynamic> session) {
    final workoutTitle = session["workout_title"]?.toString() ?? "Entrenamiento";
    final dayNumber = session["day_number"];
    final dayName = session["day_name"]?.toString();

    if (dayNumber != null && dayName != null && dayName.trim().isNotEmpty) {
      return "Día $dayNumber - $dayName";
    }

    return workoutTitle;
  }

  String _formatSessionSubtitle(Map<String, dynamic> session) {
    final completedExercises = _toInt(session["completed_exercises"]) ?? 0;
    final totalExercises = _toInt(session["total_exercises"]) ?? 0;
    final duration = _toInt(session["duration_minutes"]) ?? 0;

    final exercisesText = totalExercises > 0
        ? "$completedExercises/$totalExercises ejercicios"
        : "$completedExercises ejercicios";

    return "$exercisesText · $duration min";
  }

  String _photoTypeLabel(String? value) {
    switch (value) {
      case "FRONT":
        return "frontal";
      case "SIDE":
        return "lateral";
      case "BACK":
        return "de espalda";
      case "OTHER":
        return "personal";
      default:
        return "de progreso";
    }
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "Ahora";
    }

    if (difference.inMinutes < 60) {
      return "Hace ${difference.inMinutes} min";
    }

    if (difference.inHours < 24) {
      return "Hace ${difference.inHours} h";
    }

    if (difference.inDays == 1) {
      return "Ayer";
    }

    if (difference.inDays < 7) {
      return "Hace ${difference.inDays} días";
    }

    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");

    return "$day/$month";
  }

  void _openNotificationDetail(Map<String, dynamic> notification) {
    final title = notification["title"]?.toString() ?? "Notificación";
    final message = notification["message"]?.toString() ?? "";
    final time = notification["time"]?.toString() ?? "";
    final icon = notification["icon"] as IconData? ?? Icons.notifications_rounded;
    final color = notification["color"] as Color? ?? const Color(0xffC00000);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                message,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                time,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Entendido",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationOptions(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.visibility_rounded),
                title: const Text("Ver detalle"),
                onTap: () {
                  Navigator.pop(context);
                  _openNotificationDetail(notification);
                },
              ),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text("Actualizar notificaciones"),
                onTap: () {
                  Navigator.pop(context);
                  _loadNotifications();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGeneralOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 26),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text("Actualizar"),
                onTap: () {
                  Navigator.pop(context);
                  _loadNotifications();
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text("Información"),
                subtitle: const Text(
                  "Estas notificaciones se generan con tu agenda, entrenamientos, sueño y fotos de progreso.",
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColor.black,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          "Notificaciones",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _showGeneralOptions,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: TColor.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: const Color(0xffC00000),
                ),
              )
            : RefreshIndicator(
                color: const Color(0xffC00000),
                onRefresh: _loadNotifications,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  children: [
                    Text(
                      "Hoy",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _errorMessage != null
                          ? "No se han podido cargar las notificaciones"
                          : "Tienes ${_notifications.length} notificaciones recientes",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    if (_errorMessage != null)
                      _ErrorNotificationCard(
                        message: _errorMessage!,
                        onRetry: _loadNotifications,
                      )
                    else if (_notifications.isEmpty)
                      _EmptyNotificationCard(
                        onRefresh: _loadNotifications,
                      )
                    else
                      ListView.separated(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];

                          return _DynamicNotificationCard(
                            notification: notification,
                            onTap: () {
                              _openNotificationDetail(notification);
                            },
                            onMoreTap: () {
                              _showNotificationOptions(notification);
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _DynamicNotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final VoidCallback onMoreTap;

  const _DynamicNotificationCard({
    required this.notification,
    required this.onTap,
    required this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = notification["title"]?.toString() ?? "Notificación";
    final message = notification["message"]?.toString() ?? "";
    final time = notification["time"]?.toString() ?? "";
    final icon = notification["icon"] as IconData? ?? Icons.notifications_rounded;
    final color = notification["color"] as Color? ?? const Color(0xffC00000);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onMoreTap,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: TColor.gray,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorNotificationCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorNotificationCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotificationCard extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyNotificationCard({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            color: TColor.gray,
            size: 34,
          ),
          const SizedBox(height: 10),
          Text(
            "No tienes notificaciones",
            style: TextStyle(
              color: TColor.black,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Cuando tengas entrenamientos, sueño, fotos o avisos importantes aparecerán aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 12,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffC00000),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("Actualizar"),
          ),
        ],
      ),
    );
  }
}