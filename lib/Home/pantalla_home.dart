import 'package:afermar3_tf_ipc/Home/notif.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/profile_service.dart';
import 'package:afermar3_tf_ipc/services/scheduled_workout_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_goal_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_service.dart';
import 'package:afermar3_tf_ipc/services/workout_plan_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:afermar3_tf_ipc/workout_tracker/exercise_library_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Homepantalla();
}

class _Homepantalla extends State<Home> {
  Map<String, dynamic>? _profile;
  Map<String, dynamic>? _activeWorkoutPlan;

  bool _isLoading = true;
  String? _errorMessage;

  double? _bmi;
  String _bmiStatus = "Completa tu perfil";
  String _bmiDescription = "Añade peso y altura para calcular tu IMC.";

  List<dynamic> _scheduledWorkouts = [];
  List<dynamic> _workoutSessions = [];

  Map<String, dynamic>? _todayScheduledWorkout;
  Map<String, dynamic>? _lastSession;

  int _todayMinutes = 0;

  int _weeklySessions = 0;
  int _weeklyMinutes = 0;
  int _weeklyScheduledCount = 0;
  int _weeklyCompletedScheduledCount = 0;

  int _monthlySessions = 0;
  int _monthlyMinutes = 0;
  int _monthlyScheduledCount = 0;
  int _monthlyCompletedScheduledCount = 0;

  int _streakDays = 0;

  String _selectedPeriod = "Semanal";

  List<double> _weeklyMinutesByDay = List.filled(7, 0);
  List<double> _monthlyMinutesByWeek = List.filled(5, 0);

  int _touchedChartIndex = -1;

  List<dynamic> _sleepSessions = [];
  Map<String, dynamic>? _effectiveSleepGoal;
  Map<String, dynamic>? _latestSleepSession;

  List<double> _weeklySleepMinutesByDay = List.filled(7, 0);

  int _weeklySleepMinutes = 0;
  int _weeklySleepDays = 0;
  int _sleepGoalMinutes = 480;

  int _touchedSleepChartIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final profileData = await ProfileService.getProfile();
      final scheduled = await ScheduledWorkoutService.getMyScheduledWorkouts();
      final sessions = await WorkoutSessionService.getMyWorkoutSessions();
      final activePlan = await WorkoutPlanService.getActiveWorkoutPlan();

      List<dynamic> sleepSessions = [];
      Map<String, dynamic>? effectiveSleepGoal;

      try {
        sleepSessions = await SleepService.getMySleepSessions();
      } catch (_) {
        sleepSessions = [];
      }

      try {
        effectiveSleepGoal = await SleepGoalService.getEffectiveSleepGoalToday();
      } catch (_) {
        effectiveSleepGoal = null;
      }

      int streakDays = 0;

      try {
        final streak = await WorkoutSessionService.getWorkoutStreak();
        streakDays = _extractStreakDays(streak);
      } catch (_) {
        streakDays = 0;
      }

      if (!mounted) return;

      setState(() {
        _profile = profileData;
        _activeWorkoutPlan = activePlan;
        _scheduledWorkouts = scheduled;
        _workoutSessions = sessions;
        _sleepSessions = sleepSessions;
        _effectiveSleepGoal = effectiveSleepGoal;
        _streakDays = streakDays;
        _errorMessage = null;

        _calculateBmi();
        _processActivityData();
        _processSleepData();

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  int _extractStreakDays(Map<String, dynamic> streak) {
    final candidates = [
      streak["current_streak"],
      streak["current_streak_days"],
      streak["streak"],
      streak["days"],
    ];

    for (final value in candidates) {
      final parsed = _toInt(value);

      if (parsed != null) {
        return parsed;
      }
    }

    return 0;
  }

  void _processActivityData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 1);

    _todayScheduledWorkout = null;
    _lastSession = null;

    _todayMinutes = 0;

    _weeklySessions = 0;
    _weeklyMinutes = 0;
    _weeklyScheduledCount = 0;
    _weeklyCompletedScheduledCount = 0;

    _monthlySessions = 0;
    _monthlyMinutes = 0;
    _monthlyScheduledCount = 0;
    _monthlyCompletedScheduledCount = 0;

    _weeklyMinutesByDay = List.filled(7, 0);
    _monthlyMinutesByWeek = List.filled(5, 0);

    final todayScheduled = <Map<String, dynamic>>[];

    for (final item in _scheduledWorkouts) {
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
        _weeklyScheduledCount++;

        if (scheduled["completed"] == true) {
          _weeklyCompletedScheduledCount++;
        }
      }

      if (!scheduledDay.isBefore(monthStart) &&
          scheduledDay.isBefore(monthEnd)) {
        _monthlyScheduledCount++;

        if (scheduled["completed"] == true) {
          _monthlyCompletedScheduledCount++;
        }
      }

      if (_isSameDay(scheduledDay, today)) {
        todayScheduled.add(scheduled);
      }
    }

    if (todayScheduled.isNotEmpty) {
      todayScheduled.sort((a, b) {
        final aCompleted = a["completed"] == true;
        final bCompleted = b["completed"] == true;

        if (aCompleted == bCompleted) return 0;
        return aCompleted ? 1 : -1;
      });

      _todayScheduledWorkout = todayScheduled.first;
    }

    final parsedSessions = <Map<String, dynamic>>[];

    for (final item in _workoutSessions) {
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
        _todayMinutes += duration;
      }

      if (!sessionDay.isBefore(weekStart) && sessionDay.isBefore(weekEnd)) {
        _weeklySessions++;
        _weeklyMinutes += duration;

        final index = completedAt.weekday - 1;

        if (index >= 0 && index < 7) {
          _weeklyMinutesByDay[index] += duration.toDouble();
        }
      }

      if (!sessionDay.isBefore(monthStart) && sessionDay.isBefore(monthEnd)) {
        _monthlySessions++;
        _monthlyMinutes += duration;

        final weekIndex = ((completedAt.day - 1) ~/ 7).clamp(0, 4);
        _monthlyMinutesByWeek[weekIndex] += duration.toDouble();
      }
    }

    parsedSessions.sort((a, b) {
      final aDate = a["_completed_at_parsed"] as DateTime;
      final bDate = b["_completed_at_parsed"] as DateTime;

      return bDate.compareTo(aDate);
    });

    if (parsedSessions.isNotEmpty) {
      _lastSession = parsedSessions.first;
    }
  }

  void _processSleepData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    _weeklySleepMinutesByDay = List.filled(7, 0);
    _weeklySleepMinutes = 0;
    _weeklySleepDays = 0;
    _latestSleepSession = null;
    _sleepGoalMinutes = _extractSleepGoalMinutes();

    final parsedSessions = <Map<String, dynamic>>[];
    final sleepDays = <String>{};

    for (final item in _sleepSessions) {
      if (item is! Map) continue;

      final session = Map<String, dynamic>.from(item);

      final startTime = _parseDate(session["start_time"]);
      final endTime = _parseDate(session["end_time"]);

      final referenceDate = endTime ?? startTime;

      if (referenceDate == null) continue;

      session["_sleep_reference_date"] = referenceDate;
      parsedSessions.add(session);

      final sessionDay = DateTime(
        referenceDate.year,
        referenceDate.month,
        referenceDate.day,
      );

      final duration = _toInt(session["duration_minutes"]) ?? 0;

      if (!sessionDay.isBefore(weekStart) && sessionDay.isBefore(weekEnd)) {
        final index = referenceDate.weekday - 1;

        if (index >= 0 && index < 7 && duration > 0) {
          _weeklySleepMinutesByDay[index] += duration.toDouble();
          _weeklySleepMinutes += duration;

          sleepDays.add(
            "${sessionDay.year}-${sessionDay.month}-${sessionDay.day}",
          );
        }
      }
    }

    _weeklySleepDays = sleepDays.length;

    parsedSessions.sort((a, b) {
      final aDate = a["_sleep_reference_date"] as DateTime;
      final bDate = b["_sleep_reference_date"] as DateTime;

      return bDate.compareTo(aDate);
    });

    if (parsedSessions.isNotEmpty) {
      _latestSleepSession = parsedSessions.first;
    }
  }

  Map<String, dynamic>? _extractEffectiveSleepGoal() {
    final response = _effectiveSleepGoal;

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

  int _extractSleepGoalMinutes() {
    final goal = _extractEffectiveSleepGoal();

    final target = _toInt(goal?["target_minutes"]);

    if (target != null && target > 0) {
      return target;
    }

    return 480;
  }

  int _averageSleepMinutes() {
    if (_weeklySleepDays <= 0) return 0;

    return (_weeklySleepMinutes / _weeklySleepDays).round();
  }

  int _sleepGoalPercentage() {
    if (_sleepGoalMinutes <= 0) return 0;

    final average = _averageSleepMinutes();

    final percentage = ((average / _sleepGoalMinutes) * 100).round();

    return percentage.clamp(0, 100);
  }

  String _formatSleepDuration(int minutes) {
    if (minutes <= 0) {
      return "0min";
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

  String _sleepGoalScheduleText() {
    final goal = _extractEffectiveSleepGoal();

    if (goal == null) {
      return "Objetivo recomendado · 8h";
    }

    final bedTime = goal["bed_time"]?.toString() ?? "--:--";
    final wakeTime = goal["wake_time"]?.toString() ?? "--:--";
    final goalType = goal["goal_type"]?.toString() ?? "";

    return "${SleepGoalService.goalTypeLabel(goalType)} · $bedTime - $wakeTime";
  }

  String _sleepSubtitleText() {
    if (_weeklySleepDays <= 0) {
      return "Aún no hay registros de sueño esta semana.";
    }

    return "Media semanal: ${_formatSleepDuration(_averageSleepMinutes())} · Objetivo: ${_formatSleepDuration(_sleepGoalMinutes)}";
  }

  String _latestSleepText() {
    if (_latestSleepSession == null) {
      return "Sin sueño registrado";
    }

    final duration = _toInt(_latestSleepSession?["duration_minutes"]) ?? 0;
    final referenceDate = _latestSleepSession?["_sleep_reference_date"];

    if (duration <= 0) {
      return "Último registro pendiente de duración";
    }

    if (referenceDate is DateTime) {
      return "${_formatSleepDuration(duration)} · ${_formatDate(referenceDate)}";
    }

    return _formatSleepDuration(duration);
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

  double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().replaceAll(",", "."));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _calculateBmi() {
    final weightKg = _toDouble(_profile?["weight_kg"]);
    final heightCm = _toDouble(_profile?["height_cm"]);

    if (weightKg == null || heightCm == null || weightKg <= 0 || heightCm <= 0) {
      _bmi = null;
      _bmiStatus = "Completa tu perfil";
      _bmiDescription = "Añade peso y altura para calcular tu IMC.";
      return;
    }

    final heightM = heightCm / 100;
    final calculatedBmi = weightKg / (heightM * heightM);

    _bmi = calculatedBmi;

    if (calculatedBmi < 18.5) {
      _bmiStatus = "Bajo peso";
      _bmiDescription = "Por debajo del rango normal.";
    } else if (calculatedBmi < 25) {
      _bmiStatus = "Peso normal";
      _bmiDescription = "Tienes un peso normal.";
    } else if (calculatedBmi < 30) {
      _bmiStatus = "Sobrepeso";
      _bmiDescription = "Por encima del rango normal.";
    } else {
      _bmiStatus = "Obesidad";
      _bmiDescription = "IMC elevado. Consulta profesional recomendada.";
    }
  }

  String _formatBmiValue() {
    if (_isLoading) return "...";
    if (_bmi == null) return "--";

    return _bmi!.toStringAsFixed(1).replaceAll(".", ",");
  }

  double _bmiChartValue() {
    if (_bmi == null) return 0;

    return _bmi!.clamp(0, 40).toDouble();
  }

  String _formatWorkoutTitle(Map<String, dynamic>? item) {
    if (item == null) return "Sin entrenamiento";

    final workoutTitle = item["workout_title"]?.toString() ?? "Entrenamiento";
    final dayNumber = item["day_number"];
    final dayName = item["day_name"]?.toString();

    if (dayNumber != null && dayName != null && dayName.trim().isNotEmpty) {
      return "Día $dayNumber - $dayName";
    }

    return workoutTitle;
  }

  String _formatSessionTitle(Map<String, dynamic>? session) {
    if (session == null) {
      return "Sin sesiones completadas";
    }

    final workoutTitle = session["workout_title"]?.toString() ?? "Entrenamiento";
    final dayNumber = session["day_number"];
    final dayName = session["day_name"]?.toString();

    if (dayNumber != null && dayName != null && dayName.trim().isNotEmpty) {
      return "Día $dayNumber - $dayName";
    }

    return workoutTitle;
  }

  String _formatSessionSubtitle(Map<String, dynamic>? session) {
    if (session == null) {
      return "Completa tu primer entrenamiento para ver progreso.";
    }

    final completedExercises = _toInt(session["completed_exercises"]) ?? 0;
    final totalExercises = _toInt(session["total_exercises"]) ?? 0;
    final duration = _toInt(session["duration_minutes"]) ?? 0;

    final exercisesText = totalExercises > 0
        ? "$completedExercises/$totalExercises ejercicios"
        : "$completedExercises ejercicios";

    return "$exercisesText · $duration min";
  }

  String _todayWorkoutSubtitle() {
    if (_todayScheduledWorkout == null) {
      return "No tienes entrenamiento programado para hoy.";
    }

    final completed = _todayScheduledWorkout!["completed"] == true;
    final duration = _toInt(_todayScheduledWorkout!["duration_minutes"]);

    final durationText =
        duration == null ? "Duración no definida" : "$duration min";

    if (completed) {
      return "Completado · $durationText";
    }

    return "Pendiente · $durationText";
  }

  int _activePlanDaysPerWeek() {
    if (_activeWorkoutPlan == null) return 0;

    final directDays = _toInt(_activeWorkoutPlan?["days_per_week"]);

    if (directDays != null && directDays > 0) {
      return directDays;
    }

    final content = _activeWorkoutPlan?["content"];

    if (content is Map && content["days"] is List) {
      final days = content["days"] as List;

      if (days.isNotEmpty) {
        return days.length;
      }
    }

    return 0;
  }

  String _activePlanTitle() {
    if (_activeWorkoutPlan == null) {
      return "Sin rutina activa";
    }

    return _activeWorkoutPlan?["title"]?.toString() ?? "Rutina activa";
  }

  int _goalTargetWorkouts() {
    final activeDaysPerWeek = _activePlanDaysPerWeek();

    if (activeDaysPerWeek > 0) {
      if (_selectedPeriod == "Mensual") {
        return activeDaysPerWeek * 4;
      }

      return activeDaysPerWeek;
    }

    return _selectedPeriod == "Mensual"
        ? _monthlyScheduledCount
        : _weeklyScheduledCount;
  }

  int _goalCompletedWorkouts() {
    final activeDaysPerWeek = _activePlanDaysPerWeek();

    if (activeDaysPerWeek > 0) {
      return _selectedPeriod == "Mensual" ? _monthlySessions : _weeklySessions;
    }

    return _selectedPeriod == "Mensual"
        ? _monthlyCompletedScheduledCount
        : _weeklyCompletedScheduledCount;
  }

  int _goalPercentage() {
    final target = _goalTargetWorkouts();
    final completed = _goalCompletedWorkouts();

    if (target <= 0) return 0;

    final percentage = ((completed / target) * 100).round();

    return percentage.clamp(0, 100);
  }

  String _goalSourceLabel() {
    final activeDaysPerWeek = _activePlanDaysPerWeek();

    if (activeDaysPerWeek > 0) {
      return "rutina activa";
    }

    final scheduledCount = _selectedPeriod == "Mensual"
        ? _monthlyScheduledCount
        : _weeklyScheduledCount;

    if (scheduledCount > 0) {
      return "agenda";
    }

    return "sin objetivo";
  }

  String _goalShortDescription() {
    final target = _goalTargetWorkouts();
    final completed = _goalCompletedWorkouts();

    if (target <= 0) {
      return "0/0";
    }

    final cappedCompleted = completed > target ? target : completed;

    return "$cappedCompleted/$target";
  }

  int _periodSessions() {
    return _selectedPeriod == "Mensual" ? _monthlySessions : _weeklySessions;
  }

  int _periodMinutes() {
    return _selectedPeriod == "Mensual" ? _monthlyMinutes : _weeklyMinutes;
  }

  List<double> _chartValues() {
    return _selectedPeriod == "Mensual"
        ? _monthlyMinutesByWeek
        : _weeklyMinutesByDay;
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();

    return "$day/$month/$year";
  }

  List<Map<String, dynamic>> _getParsedSessions() {
    final parsedSessions = <Map<String, dynamic>>[];

    for (final item in _workoutSessions) {
      if (item is! Map) continue;

      final session = Map<String, dynamic>.from(item);
      final completedAt = _parseDate(session["completed_at"]);

      if (completedAt == null) continue;

      session["_completed_at_parsed"] = completedAt;
      parsedSessions.add(session);
    }

    parsedSessions.sort((a, b) {
      final aDate = a["_completed_at_parsed"] as DateTime;
      final bDate = b["_completed_at_parsed"] as DateTime;

      return bDate.compareTo(aDate);
    });

    return parsedSessions;
  }

  void _showBmiInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Índice de masa corporal",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "IMC actual: ${_formatBmiValue()}",
                style: TextStyle(
                  color: TColor.rojo,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _bmiStatus,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _bmiDescription,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "El IMC se calcula usando tu peso y altura del perfil. Es una referencia general y no sustituye una valoración profesional.",
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTodayWorkoutDetails() {
    final hasWorkoutToday = _todayScheduledWorkout != null;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Objetivo de hoy",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: hasWorkoutToday
                    ? Icons.fitness_center_rounded
                    : Icons.event_busy_rounded,
                title: hasWorkoutToday ? "Entrenamiento" : "Estado",
                value: hasWorkoutToday
                    ? _formatWorkoutTitle(_todayScheduledWorkout)
                    : "Sin entrenamiento programado",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.info_outline_rounded,
                title: "Detalle",
                value: _todayWorkoutSubtitle(),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.timer_rounded,
                title: "Minutos entrenados hoy",
                value: "$_todayMinutes min",
              ),
              const SizedBox(height: 18),
              Text(
                hasWorkoutToday
                    ? "Puedes consultar o completar el entrenamiento desde la sección de actividad."
                    : "Puedes programar un entrenamiento desde el Coach IA o desde tu rutina activa.",
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSleepDetails() {
    final goal = _extractEffectiveSleepGoal();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Seguimiento del sueño",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.bedtime_rounded,
                title: "Media semanal",
                value: _weeklySleepDays > 0
                    ? _formatSleepDuration(_averageSleepMinutes())
                    : "Sin registros esta semana",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.flag_rounded,
                title: "Objetivo",
                value: _formatSleepDuration(_sleepGoalMinutes),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.alarm_rounded,
                title: "Horario",
                value: _sleepGoalScheduleText(),
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.history_rounded,
                title: "Último sueño",
                value: _latestSleepText(),
              ),
              const SizedBox(height: 18),
              Text(
                goal == null
                    ? "No tienes un objetivo personalizado activo para hoy. Se usa una referencia recomendada de 8 horas."
                    : "Estos datos se calculan a partir de tus sesiones de sueño registradas y tu objetivo efectivo de hoy.",
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGoalInfo() {
    final activeDaysPerWeek = _activePlanDaysPerWeek();
    final target = _goalTargetWorkouts();
    final completed = _goalCompletedWorkouts();
    final percentage = _goalPercentage();
    final missing = target - completed;
    final periodText =
        _selectedPeriod == "Mensual" ? "este mes" : "esta semana";

    String title;
    String explanation;
    String objectiveText;

    if (activeDaysPerWeek > 0) {
      title = "Meta de rutina activa";

      final activeTitle = _activePlanTitle();

      if (missing > 0) {
        explanation =
            "Has completado $completed de $target entrenamientos $periodText. Te faltan $missing para completar tu objetivo.";
      } else {
        explanation =
            "Has completado $completed entrenamientos $periodText. Has alcanzado o superado tu objetivo.";
      }

      objectiveText = "$activeTitle · $activeDaysPerWeek días/semana";
    } else {
      final scheduledCount = _selectedPeriod == "Mensual"
          ? _monthlyScheduledCount
          : _weeklyScheduledCount;

      final completedScheduledCount = _selectedPeriod == "Mensual"
          ? _monthlyCompletedScheduledCount
          : _weeklyCompletedScheduledCount;

      title = "Meta de agenda";

      if (scheduledCount > 0) {
        explanation =
            "Has completado $completedScheduledCount de $scheduledCount entrenamientos programados $periodText.";
        objectiveText = "$scheduledCount entrenamientos programados";
      } else {
        explanation =
            "Todavía no tienes una rutina activa ni entrenamientos programados $periodText.";
        objectiveText = "Sin objetivo definido";
      }
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.flag_rounded,
                title: "Progreso",
                value: "$percentage%",
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.fitness_center_rounded,
                title: activeDaysPerWeek > 0 ? "Rutina activa" : "Objetivo",
                value: objectiveText,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.check_circle_rounded,
                title: "Completados",
                value: target > 0 ? "$completed/$target" : "0/0",
              ),
              const SizedBox(height: 18),
              Text(
                explanation,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLastSessionDetails() {
    if (_lastSession == null) return;

    _showSessionDetails(_lastSession!);
  }

  void _showActivityHistorySheet() {
    final sessions = _getParsedSessions();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Historial de actividad",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Entrenamientos completados recientemente",
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(
                          "Aún no tienes sesiones completadas.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.gris,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final session = sessions[index];
                          final completedAt =
                              session["_completed_at_parsed"] as DateTime?;

                          return _HistorySessionCard(
                            title: _formatSessionTitle(session),
                            subtitle: _formatSessionSubtitle(session),
                            dateText: completedAt == null
                                ? "Fecha no disponible"
                                : _formatDate(completedAt),
                            onTap: () {
                              Navigator.pop(context);
                              _showSessionDetails(session);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSessionDetails(Map<String, dynamic> session) {
    final completedAt = session["_completed_at_parsed"] as DateTime?;
    final title = _formatSessionTitle(session);
    final subtitle = _formatSessionSubtitle(session);
    final workoutTitle =
        session["workout_title"]?.toString() ?? "Entrenamiento";
    final dateText =
        completedAt == null ? "Fecha no disponible" : _formatDate(completedAt);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Detalle de actividad",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.fitness_center_rounded,
                title: "Entrenamiento",
                value: title,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.bookmark_rounded,
                title: "Rutina",
                value: workoutTitle,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.check_circle_rounded,
                title: "Progreso",
                value: subtitle,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.calendar_month_rounded,
                title: "Fecha",
                value: dateText,
              ),
            ],
          ),
        );
      },
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationView(),
      ),
    ).then((_) {
      _loadHomeData();
    });
  }

  void _openExercises() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseLibraryView(),
      ),
    ).then((_) {
      _loadHomeData();
    });
  }

  String _weekdayName(int index) {
    switch (index) {
      case 0:
        return "Lunes";
      case 1:
        return "Martes";
      case 2:
        return "Miércoles";
      case 3:
        return "Jueves";
      case 4:
        return "Viernes";
      case 5:
        return "Sábado";
      case 6:
        return "Domingo";
      default:
        return "";
    }
  }

  String _chartTitle() {
    return _selectedPeriod == "Mensual"
        ? "Actividad mensual"
        : "Actividad semanal";
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: TColor.rojo,
                ),
              )
            : RefreshIndicator(
                color: TColor.rojo,
                onRefresh: _loadHomeData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 115),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 22),
                      if (_errorMessage != null) ...[
                        _buildErrorCard(),
                        const SizedBox(height: 18),
                      ],
                      _buildBmiCard(media),
                      const SizedBox(height: 18),
                      _buildTodayWorkoutCard(),
                      const SizedBox(height: 18),
                      _buildExercisesShortcut(),
                      const SizedBox(height: 22),
                      _sectionTitle("Resumen"),
                      const SizedBox(height: 12),
                      _buildPeriodSelector(),
                      const SizedBox(height: 12),
                      _buildStats(),
                      const SizedBox(height: 24),
                      _buildProgressHeader(),
                      const SizedBox(height: 14),
                      _buildProgressChart(media),
                      const SizedBox(height: 24),
                      _buildSleepChart(media),
                      const SizedBox(height: 24),
                      _buildLastSessionHeader(),
                      const SizedBox(height: 12),
                      _buildLastSessionCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resumen diario",
              style: TextStyle(
                color: TColor.negro,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Sigue avanzando hacia tu objetivo",
              style: TextStyle(
                color: TColor.gris,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _openNotifications,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                "assets/img/notification_active.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? "No se han podido cargar los datos.",
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiCard(Size media) {
    return Container(
      height: media.width * 0.48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: TColor.primerG,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: TColor.rojo.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset(
              "assets/img/bg_dots.png",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 22,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "IMC",
                        style: TextStyle(
                          color: TColor.blanco,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bmiStatus,
                        style: TextStyle(
                          color: TColor.blanco.withOpacity(0.85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _bmiDescription,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.blanco.withOpacity(0.72),
                          fontSize: 11,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 108,
                        height: 32,
                        child: ElevatedButton(
                          onPressed: _showBmiInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text(
                            "Ver más",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: media.width * 0.27,
                  height: media.width * 0.27,
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: 250,
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 1,
                      centerSpaceRadius: 0,
                      sections: _buildBmiSections(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildBmiSections() {
    final bmiValue = _bmiChartValue();
    final remainingValue = (40 - bmiValue).clamp(0, 40).toDouble();

    return [
      PieChartSectionData(
        color: _bmi == null ? Colors.grey.shade300 : TColor.segundoColor1,
        value: bmiValue <= 0 ? 1 : bmiValue,
        title: '',
        radius: 55,
        titlePositionPercentageOffset: 0.55,
        badgeWidget: Text(
          _formatBmiValue(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      PieChartSectionData(
        color: Colors.white,
        value: remainingValue <= 0 ? 1 : remainingValue,
        title: '',
        radius: 45,
        titlePositionPercentageOffset: 0.55,
      ),
    ];
  }

  Widget _buildTodayWorkoutCard() {
    final hasWorkoutToday = _todayScheduledWorkout != null;
    final completed = _todayScheduledWorkout?["completed"] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _showTodayWorkoutDetails,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColor.primerColor2.withOpacity(0.13),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: TColor.primerColor2.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : hasWorkoutToday
                        ? Icons.fitness_center_rounded
                        : Icons.event_busy_rounded,
                color: completed ? Colors.green : TColor.rojo,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Objetivo de hoy",
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hasWorkoutToday
                        ? _formatWorkoutTitle(_todayScheduledWorkout)
                        : "Sin entrenamiento para hoy",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _todayWorkoutSubtitle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gris,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesShortcut() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _openExercises,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                Icons.list_alt_rounded,
                color: TColor.rojo,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Biblioteca de ejercicios",
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Consulta todos los ejercicios reales disponibles en la app.",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gris,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PeriodButton(
              title: "Semanal",
              selected: _selectedPeriod == "Semanal",
              onTap: () {
                setState(() {
                  _selectedPeriod = "Semanal";
                  _touchedChartIndex = -1;
                });
              },
            ),
          ),
          Expanded(
            child: _PeriodButton(
              title: "Mensual",
              selected: _selectedPeriod == "Mensual",
              onTap: () {
                setState(() {
                  _selectedPeriod = "Mensual";
                  _touchedChartIndex = -1;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _DashboardStatCard(
            icon: Icons.check_circle_rounded,
            label: "Sesiones",
            value: "${_periodSessions()}",
            description: _selectedPeriod == "Mensual" ? "mes" : "semana",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DashboardStatCard(
            icon: Icons.timer_rounded,
            label: "Minutos",
            value: "${_periodMinutes()}",
            description: "entrenados",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _DashboardStatCard(
            icon: Icons.flag_rounded,
            label: "Meta",
            value: "${_goalPercentage()}%",
            description: _goalSourceLabel(),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle(_chartTitle()),
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: _showGoalInfo,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primerG),
              borderRadius: BorderRadius.circular(18),
            ),
            alignment: Alignment.center,
            child: Text(
              "${_goalPercentage()}% meta",
              style: TextStyle(
                color: TColor.blanco,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart(Size media) {
    final values = _chartValues();

    final maxMinutes = values.fold<double>(
      0,
      (previous, current) {
        return current > previous ? current : previous;
      },
    );

    final chartMaxY = maxMinutes <= 0 ? 20.0 : maxMinutes + 15;

    return Container(
      height: media.width * 0.55,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: _cardDecoration(),
      child: BarChart(
        BarChartData(
          maxY: chartMaxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBorderRadius: BorderRadius.circular(12),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = _selectedPeriod == "Mensual"
                    ? "Semana ${group.x + 1}"
                    : _weekdayName(group.x);

                return BarTooltipItem(
                  "$label\n",
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: "${rod.toY.toStringAsFixed(0)} min",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    barTouchResponse == null ||
                    barTouchResponse.spot == null) {
                  _touchedChartIndex = -1;
                  return;
                }

                _touchedChartIndex =
                    barTouchResponse.spot!.touchedBarGroupIndex;
              });
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: _bottomTitleWidgets,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
          barGroups: List.generate(values.length, (index) {
            final value = values[index];

            return _makeChartGroup(
              index,
              value,
              chartMaxY: chartMaxY,
              isTouched: index == _touchedChartIndex,
            );
          }),
        ),
      ),
    );
  }

  BarChartGroupData _makeChartGroup(
    int x,
    double y, {
    required double chartMaxY,
    bool isTouched = false,
  }) {
    final safeValue = y <= 0 ? 1.5 : y;
    final touchedValue = isTouched ? safeValue + 2 : safeValue;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: touchedValue.clamp(0, chartMaxY).toDouble(),
          gradient: LinearGradient(
            colors: y <= 0
                ? [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                  ]
                : [
                    TColor.rojo.withOpacity(0.95),
                    TColor.negro,
                  ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderRadius: BorderRadius.circular(10),
          borderSide: isTouched
              ? BorderSide(
                  color: TColor.rojo,
                  width: 1.5,
                )
              : BorderSide.none,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: chartMaxY,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: TColor.gris,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );

    Widget text;

    if (_selectedPeriod == "Mensual") {
      switch (value.toInt()) {
        case 0:
          text = Text("S1", style: style);
          break;
        case 1:
          text = Text("S2", style: style);
          break;
        case 2:
          text = Text("S3", style: style);
          break;
        case 3:
          text = Text("S4", style: style);
          break;
        case 4:
          text = Text("S5", style: style);
          break;
        default:
          text = const Text("");
          break;
      }
    } else {
      switch (value.toInt()) {
        case 0:
          text = Text("Lun", style: style);
          break;
        case 1:
          text = Text("Mar", style: style);
          break;
        case 2:
          text = Text("Mié", style: style);
          break;
        case 3:
          text = Text("Jue", style: style);
          break;
        case 4:
          text = Text("Vie", style: style);
          break;
        case 5:
          text = Text("Sáb", style: style);
          break;
        case 6:
          text = Text("Dom", style: style);
          break;
        default:
          text = const Text("");
          break;
      }
    }

    return SideTitleWidget(
      meta: meta,
      space: 14,
      child: text,
    );
  }

  Widget _buildSleepChart(Size media) {
    final values = _weeklySleepMinutesByDay;

    final maxMinutes = values.fold<double>(
      0,
      (previous, current) {
        return current > previous ? current : previous;
      },
    );

    final goalAsDouble = _sleepGoalMinutes.toDouble();

    final chartMaxY = [
          maxMinutes,
          goalAsDouble,
          480.0,
        ].reduce((a, b) => a > b ? a : b) +
        60;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _showSleepDetails,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.bedtime_rounded,
                    color: Colors.indigo,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sueño semanal",
                        style: TextStyle(
                          color: TColor.negro,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _sleepSubtitleText(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.gris,
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "${_sleepGoalPercentage()}%",
                    style: const TextStyle(
                      color: Colors.indigo,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SleepMiniStat(
                    icon: Icons.nights_stay_rounded,
                    label: "Media",
                    value: _weeklySleepDays > 0
                        ? _formatSleepDuration(_averageSleepMinutes())
                        : "--",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SleepMiniStat(
                    icon: Icons.flag_rounded,
                    label: "Objetivo",
                    value: _formatSleepDuration(_sleepGoalMinutes),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SleepMiniStat(
                    icon: Icons.calendar_month_rounded,
                    label: "Días",
                    value: "$_weeklySleepDays/7",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: media.width * 0.42,
              child: BarChart(
                BarChartData(
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBorderRadius: BorderRadius.circular(12),
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final label = _weekdayName(group.x);
                        final safeIndex = group.x.clamp(
                          0,
                          values.length - 1,
                        );
                        final realValue = values[safeIndex].round();

                        return BarTooltipItem(
                          "$label\n",
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: _formatSleepDuration(realValue),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            barTouchResponse == null ||
                            barTouchResponse.spot == null) {
                          _touchedSleepChartIndex = -1;
                          return;
                        }

                        _touchedSleepChartIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 34,
                        getTitlesWidget: _sleepBottomTitleWidgets,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: false),
                  barGroups: List.generate(values.length, (index) {
                    final value = values[index];

                    return _makeSleepChartGroup(
                      index,
                      value,
                      chartMaxY: chartMaxY,
                      isTouched: index == _touchedSleepChartIndex,
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _sleepGoalScheduleText(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TColor.gris,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _makeSleepChartGroup(
    int x,
    double y, {
    required double chartMaxY,
    bool isTouched = false,
  }) {
    final safeValue = y <= 0 ? 10.0 : y;
    final touchedValue = isTouched ? safeValue + 15 : safeValue;

    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: touchedValue.clamp(0, chartMaxY).toDouble(),
          gradient: LinearGradient(
            colors: y <= 0
                ? [
                    Colors.grey.shade200,
                    Colors.grey.shade100,
                  ]
                : [
                    Colors.indigo.withOpacity(0.95),
                    Colors.indigo.shade900,
                  ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 22,
          borderRadius: BorderRadius.circular(10),
          borderSide: isTouched
              ? const BorderSide(
                  color: Colors.indigo,
                  width: 1.5,
                )
              : BorderSide.none,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: chartMaxY,
            color: Colors.grey.shade100,
          ),
        ),
      ],
    );
  }

  Widget _sleepBottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: TColor.gris,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );

    Widget text;

    switch (value.toInt()) {
      case 0:
        text = Text("Lun", style: style);
        break;
      case 1:
        text = Text("Mar", style: style);
        break;
      case 2:
        text = Text("Mié", style: style);
        break;
      case 3:
        text = Text("Jue", style: style);
        break;
      case 4:
        text = Text("Vie", style: style);
        break;
      case 5:
        text = Text("Sáb", style: style);
        break;
      case 6:
        text = Text("Dom", style: style);
        break;
      default:
        text = const Text("");
        break;
    }

    return SideTitleWidget(
      meta: meta,
      space: 14,
      child: text,
    );
  }

  Widget _buildLastSessionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle("Última sesión"),
        TextButton(
          onPressed: _showActivityHistorySheet,
          child: Text(
            "Ver más",
            style: TextStyle(
              color: TColor.rojo,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastSessionCard() {
    final hasSession = _lastSession != null;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: hasSession ? _showLastSessionDetails : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                hasSession
                    ? Icons.fitness_center_rounded
                    : Icons.info_outline_rounded,
                color: TColor.rojo,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatSessionTitle(_lastSession),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatSessionSubtitle(_lastSession),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (hasSession)
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: TColor.gris,
                size: 15,
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: TColor.negro,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: Colors.grey.shade100,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _PeriodButton extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: selected ? LinearGradient(colors: TColor.primerG) : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: selected ? TColor.blanco : TColor.gris,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String description;

  const _DashboardStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: TColor.rojo,
            size: 22,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: TColor.negro,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.negro,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.gris,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepMiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SleepMiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.indigo.withOpacity(0.08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.indigo,
            size: 19,
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: TColor.negro,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.gris,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySessionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateText;
  final VoidCallback onTap;

  const _HistorySessionCard({
    required this.title,
    required this.subtitle,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColor.blanco,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: TColor.rojo,
                size: 22,
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
                      color: TColor.negro,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              dateText,
              style: TextStyle(
                color: TColor.gris,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: TColor.rojo.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: TColor.rojo,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}