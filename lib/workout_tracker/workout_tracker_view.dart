import 'package:afermar3_tf_ipc/IA/ai_generated_workout_view.dart';
import 'package:afermar3_tf_ipc/IA/saved_workouts_view.dart';
import 'package:afermar3_tf_ipc/services/scheduled_workout_service.dart';
import 'package:afermar3_tf_ipc/services/workout_plan_service.dart';
import 'package:afermar3_tf_ipc/services/workout_progress_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/workout_tracker/active_workout_day_view.dart';
import 'package:afermar3_tf_ipc/workout_tracker/exercise_library_view.dart';
import 'package:afermar3_tf_ipc/workout_tracker/manual_workout_builder_view.dart';
import 'package:afermar3_tf_ipc/workout_tracker/workout_schedule_view.dart';
import 'package:afermar3_tf_ipc/workout_tracker/workout_history_view.dart';
import 'package:afermar3_tf_ipc/workout_tracker/workout_stats_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key});

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  Map<String, dynamic>? activeWorkout;
  bool isLoadingActiveWorkout = true;

  Map<String, dynamic>? workoutSummary;
  bool isLoadingSummary = true;

  Map<String, dynamic>? workoutStreak;
  bool isLoadingStreak = true;

  List<Map<String, dynamic>> upcomingScheduledWorkouts = [];
  Map<String, dynamic>? todayScheduledWorkout;
  bool isLoadingScheduledWorkouts = true;

  Map<int, int> activeDayCompletedExercises = {};
  bool isLoadingActiveDayProgress = false;

  @override
  void initState() {
    super.initState();
    _loadActiveWorkout();
    _loadWorkoutSummary();
    _loadWorkoutStreak();
    _loadUpcomingScheduledWorkouts();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  int _getDayNumberFromDay(Map<String, dynamic> day, int index) {
    return _parseInt(day["day_number"]) ?? index + 1;
  }

  bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _findDayIndexByDayNumber({
    required Map<String, dynamic> workoutContent,
    required int? dayNumber,
  }) {
    final days = workoutContent["days"];

    if (dayNumber == null || days is! List) {
      return 0;
    }

    for (int i = 0; i < days.length; i++) {
      final rawDay = days[i];

      if (rawDay is Map) {
        final day = Map<String, dynamic>.from(rawDay);
        final currentDayNumber = _parseInt(day["day_number"]) ?? i + 1;

        if (currentDayNumber == dayNumber) {
          return i;
        }
      }
    }

    return 0;
  }

  Future<void> _loadActiveWorkout() async {
    try {
      final workout = await WorkoutPlanService.getActiveWorkoutPlan();

      if (!mounted) return;

      setState(() {
        activeWorkout = workout;
        isLoadingActiveWorkout = false;
      });

      await _loadActiveWorkoutDaysProgress(workout: workout);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        activeWorkout = null;
        activeDayCompletedExercises = {};
        isLoadingActiveWorkout = false;
        isLoadingActiveDayProgress = false;
      });
    }
  }

  Future<void> _loadActiveWorkoutDaysProgress({
    Map<String, dynamic>? workout,
  }) async {
    final currentWorkout = workout ?? activeWorkout;

    if (currentWorkout == null) {
      if (!mounted) return;

      setState(() {
        activeDayCompletedExercises = {};
        isLoadingActiveDayProgress = false;
      });

      return;
    }

    final savedWorkoutId = _parseInt(currentWorkout["id"]);
    final content = currentWorkout["content"];

    if (savedWorkoutId == null || content is! Map) {
      if (!mounted) return;

      setState(() {
        activeDayCompletedExercises = {};
        isLoadingActiveDayProgress = false;
      });

      return;
    }

    final daysRaw = content["days"];

    if (daysRaw is! List || daysRaw.isEmpty) {
      if (!mounted) return;

      setState(() {
        activeDayCompletedExercises = {};
        isLoadingActiveDayProgress = false;
      });

      return;
    }

    setState(() {
      isLoadingActiveDayProgress = true;
    });

    final progressByDay = <int, int>{};

    for (int i = 0; i < daysRaw.length; i++) {
      final rawDay = daysRaw[i];

      Map<String, dynamic> day;

      if (rawDay is Map<String, dynamic>) {
        day = rawDay;
      } else if (rawDay is Map) {
        day = Map<String, dynamic>.from(rawDay);
      } else {
        continue;
      }

      final dayNumber = _getDayNumberFromDay(day, i);

      try {
        final progress = await WorkoutProgressService.getDayProgress(
          savedWorkoutId: savedWorkoutId,
          scheduledWorkoutId: null,
          dayNumber: dayNumber,
        );

        final completed = _parseInt(progress["total_completed"]) ?? 0;

        progressByDay[dayNumber] = completed;
      } catch (_) {
        progressByDay[dayNumber] = 0;
      }
    }

    if (!mounted) return;

    setState(() {
      activeDayCompletedExercises = progressByDay;
      isLoadingActiveDayProgress = false;
    });
  }

Future<void> _loadWorkoutSummary() async {
  try {
    final summary = await WorkoutSessionService.getWeeklyWorkoutSummary();

    if (!mounted) return;

    setState(() {
      workoutSummary = summary;
      isLoadingSummary = false;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      workoutSummary = {
        "week_start": null,
        "week_end": null,
        "total_sessions": 0,
        "total_minutes": 0,
        "estimated_kcal": 0,
        "total_completed_exercises": 0,
        "daily_summary": [],
      };
      isLoadingSummary = false;
    });
  }
}


Future<void> _loadWorkoutStreak() async {
  try {
    final streak = await WorkoutSessionService.getWorkoutStreak();

    if (!mounted) return;

    setState(() {
      workoutStreak = streak;
      isLoadingStreak = false;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      workoutStreak = {
        "current_streak": 0,
        "last_training_date": null,
        "trained_today": false,
        "trained_yesterday": false,
      };
      isLoadingStreak = false;
    });
  }
}



Future<void> _loadUpcomingScheduledWorkouts() async {
  try {
    final result = await ScheduledWorkoutService.getMyScheduledWorkouts();

    final now = DateTime.now();

    final allWorkouts = result.map((item) {
      final map = Map<String, dynamic>.from(item as Map);

      DateTime scheduledDate;

      try {
        scheduledDate = DateTime.parse(map["scheduled_date"].toString());
      } catch (_) {
        scheduledDate = now;
      }

      final durationMinutes = _parseInt(map["duration_minutes"]) ?? 45;
      final estimatedKcal = durationMinutes * 6;

      return {
        "id": map["id"],
        "saved_workout_id": map["saved_workout_id"],
        "completed_session_id": map["completed_session_id"],
        "title": map["workout_title"]?.toString() ?? "Entrenamiento",
        "subtitle": map["day_name"]?.toString() ?? "Rutina",
        "day_number": map["day_number"],
        "day_name": map["day_name"],
        "time": _formatUpcomingDate(scheduledDate),
        "scheduled_date": scheduledDate,
        "duration_minutes": durationMinutes,
        "duration": "$durationMinutes min",
        "kcal": "$estimatedKcal kcal",
        "completed": map["completed"] == true,
      };
    }).toList();

    final pendingWorkouts = allWorkouts.where((item) {
      final completed = item["completed"] as bool? ?? false;
      return !completed;
    }).toList();

    pendingWorkouts.sort((a, b) {
      final dateA = a["scheduled_date"] as DateTime;
      final dateB = b["scheduled_date"] as DateTime;
      return dateA.compareTo(dateB);
    });

    final todayWorkouts = pendingWorkouts.where((item) {
      final date = item["scheduled_date"] as DateTime;
      return _isSameDay(date, now);
    }).toList();

    final upcomingWorkouts = pendingWorkouts.where((item) {
      final date = item["scheduled_date"] as DateTime;

      return date.isAfter(now.subtract(const Duration(minutes: 1)));
    }).toList();

    if (!mounted) return;

    setState(() {
      todayScheduledWorkout =
          todayWorkouts.isNotEmpty ? todayWorkouts.first : null;
      upcomingScheduledWorkouts = upcomingWorkouts.take(3).toList();
      isLoadingScheduledWorkouts = false;
    });
  } catch (_) {
    if (!mounted) return;

    setState(() {
      todayScheduledWorkout = null;
      upcomingScheduledWorkouts = [];
      isLoadingScheduledWorkouts = false;
    });
  }
}

  Future<void> _refreshWorkoutData() async {
    await Future.wait([
      _loadActiveWorkout(),
      _loadWorkoutSummary(),
      _loadWorkoutStreak(),
      _loadUpcomingScheduledWorkouts(),
    ]);
  }

  Future<void> _openSavedWorkouts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedWorkoutsView(),
      ),
    );

    _refreshWorkoutData();
  }

  Future<void> _openActiveWorkout() async {
    final workout = activeWorkout;

    if (workout == null) {
      _openSavedWorkouts();
      return;
    }

    final content = workout["content"] as Map<String, dynamic>?;

    if (content == null) {
      _openSavedWorkouts();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutDayView(
          workout: content,
          savedWorkoutId: workout["id"] as int?,
          dayIndex: 0,
        ),
      ),
    );

    await _refreshWorkoutData();
  }


  Future<void> _openTodayScheduledWorkout() async {
  final todayWorkout = todayScheduledWorkout;

  if (todayWorkout == null) {
    await _openActiveWorkout();
    return;
  }

  final workout = activeWorkout;

  if (workout == null) {
    await _openSchedule();
    return;
  }

  final activeWorkoutId = _parseInt(workout["id"]);
  final scheduledSavedWorkoutId = _parseInt(todayWorkout["saved_workout_id"]);

  if (activeWorkoutId == null ||
      scheduledSavedWorkoutId == null ||
      activeWorkoutId != scheduledSavedWorkoutId) {
    await _openSchedule();
    return;
  }

  final content = workout["content"];

  if (content is! Map) {
    await _openSchedule();
    return;
  }

  final workoutContent = Map<String, dynamic>.from(content);
  final dayNumber = _parseInt(todayWorkout["day_number"]);

  final dayIndex = _findDayIndexByDayNumber(
    workoutContent: workoutContent,
    dayNumber: dayNumber,
  );

  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ActiveWorkoutDayView(
        workout: workoutContent,
        savedWorkoutId: activeWorkoutId,
        scheduledWorkoutId: _parseInt(todayWorkout["id"]),
        dayIndex: dayIndex,
      ),
    ),
  );

  await _refreshWorkoutData();
}

  List<Map<String, dynamic>> _getActiveWorkoutDays() {
    final content = activeWorkout?["content"];

    if (content is! Map) return [];

    final days = content["days"];

    if (days is! List) return [];

    return days
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }

          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }

          return <String, dynamic>{};
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  Future<void> _openActiveWorkoutDay(int dayIndex) async {
    final workout = activeWorkout;

    if (workout == null) {
      _openSavedWorkouts();
      return;
    }

    final content = workout["content"] as Map<String, dynamic>?;

    if (content == null) {
      _openSavedWorkouts();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveWorkoutDayView(
          workout: content,
          savedWorkoutId: workout["id"] as int?,
          dayIndex: dayIndex,
        ),
      ),
    );

    await _refreshWorkoutData();
  }

  Future<void> _openManualWorkoutBuilder() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualWorkoutBuilderView(),
      ),
    );

    if (result == true) {
      _refreshWorkoutData();
    }
  }

  void _openExerciseLibrary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ExerciseLibraryView(),
      ),
    );
  }

  Future<void> _openSchedule() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WorkoutScheduleView(),
      ),
    );

    _refreshWorkoutData();
  }

  void _openWorkoutStats() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const WorkoutStatsView(),
    ),
  );
}

  void _openWorkoutHistory() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const WorkoutHistoryView(),
    ),
  );
}

  String _formatUpcomingDate(DateTime date) {
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final eventDay = DateTime(date.year, date.month, date.day);

    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    if (eventDay == today) {
      return "Hoy, $hour:$minute";
    }

    if (eventDay == tomorrow) {
      return "Mañana, $hour:$minute";
    }

    return "${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}, $hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: TColor.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: media.width * 0.72,
            pinned: true,
            elevation: 0,
            backgroundColor: TColor.primaryColor1,
            leading: canPop
                ? Padding(
                    padding: const EdgeInsets.all(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  )
                : null,
            title: const Text(
              "Entrenamientos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _openSavedWorkouts,
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.bookmark_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 70, 22, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Text(
                          "Tu progreso semanal",
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLoadingSummary
                              ? "Cargando progreso..."
                              : "${workoutSummary?["total_sessions"] ?? 0} entrenamientos completados · ${workoutSummary?["estimated_kcal"] ?? 0} kcal",
                          style: TextStyle(
                            color: TColor.white.withOpacity(0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: _WeeklyChart(
                            dailySummary: workoutSummary?["daily_summary"] as List? ?? [],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 4,
                        decoration: BoxDecoration(
                          color: TColor.gray.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildSummaryCards(),
                    const SizedBox(height: 14),
                    _buildStreakCard(),
                    const SizedBox(height: 14),
                    _buildHistoryShortcutCard(),
                    const SizedBox(height: 14),
                    _buildStatsShortcutCard(),
                    const SizedBox(height: 22),
                    _buildDailyScheduleCard(),
                    const SizedBox(height: 26),
                    _buildSectionHeader(
                      title: "Próximos entrenamientos",
                      actionText: "Agenda",
                      onTap: _openSchedule,
                    ),
                    const SizedBox(height: 12),
                    _buildUpcomingScheduledWorkouts(),
                    const SizedBox(height: 24),
                    _buildTrainingOptionsSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final totalSessions = workoutSummary?["total_sessions"]?.toString() ?? "0";
    final estimatedKcal = workoutSummary?["estimated_kcal"]?.toString() ?? "0";
    final totalMinutes = workoutSummary?["total_minutes"]?.toString() ?? "0";

    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.fitness_center_rounded,
            value: isLoadingSummary ? "..." : totalSessions,
            label: "Sesiones",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.local_fire_department_rounded,
            value: isLoadingSummary ? "..." : estimatedKcal,
            label: "Kcal",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.timer_outlined,
            value: isLoadingSummary ? "..." : totalMinutes,
            label: "Min",
          ),
        ),
      ],
    );
  }

Widget _buildStreakCard() {
  final currentStreak = _parseInt(workoutStreak?["current_streak"]) ?? 0;
  final trainedToday = workoutStreak?["trained_today"] == true;
  final trainedYesterday = workoutStreak?["trained_yesterday"] == true;
  final lastTrainingDate = workoutStreak?["last_training_date"]?.toString();

  String title;
  String subtitle;
  IconData icon;
  Color color;

  if (isLoadingStreak) {
    title = "Cargando racha...";
    subtitle = "Estamos calculando tu constancia reciente";
    icon = Icons.local_fire_department_rounded;
    color = TColor.primaryColor1;
  } else if (currentStreak <= 0) {
    title = "Sin racha activa";
    subtitle = lastTrainingDate == null
        ? "Completa un entrenamiento para empezar tu racha"
        : "Último entrenamiento: $lastTrainingDate";
    icon = Icons.local_fire_department_outlined;
    color = TColor.gray;
  } else {
    title = "$currentStreak ${currentStreak == 1 ? "día" : "días"} de racha";

    if (trainedToday) {
      subtitle = "Has entrenado hoy. Sigue manteniendo el ritmo.";
    } else if (trainedYesterday) {
      subtitle = "Entrenaste ayer. Entrena hoy para no perder la racha.";
    } else {
      subtitle = "Sigue completando entrenamientos para mejorar tu racha.";
    }

    icon = Icons.local_fire_department_rounded;
    color = Colors.orangeAccent;
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: color.withOpacity(0.14),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildHistoryShortcutCard() {
  return InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: _openWorkoutHistory,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.history_rounded,
              color: TColor.primaryColor1,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Historial de entrenamientos",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Consulta tus sesiones completadas y tu progreso reciente",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: TColor.gray,
            size: 16,
          ),
        ],
      ),
    ),
  );
}

Widget _buildStatsShortcutCard() {
  return InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: _openWorkoutStats,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.insights_rounded,
              color: TColor.primaryColor1,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Estadísticas completas",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Consulta tu progreso semanal, mensual e histórico",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: TColor.gray,
            size: 16,
          ),
        ],
      ),
    ),
  );
}

  Widget _buildDailyScheduleCard() {
  final hasTodayScheduledWorkout = todayScheduledWorkout != null;
  final hasActiveWorkout = activeWorkout != null;

  final title = hasTodayScheduledWorkout
      ? "Entrenamiento de hoy"
      : hasActiveWorkout
          ? "Rutina activa"
          : "Plan de hoy";

  final mainText = hasTodayScheduledWorkout
      ? todayScheduledWorkout!["title"]?.toString() ?? "Entrenamiento"
      : hasActiveWorkout
          ? activeWorkout!["title"]?.toString() ?? "Rutina activa"
          : "No tienes ninguna rutina activa";

  final subtitle = isLoadingActiveWorkout || isLoadingScheduledWorkouts
      ? "Cargando plan de entrenamiento..."
      : hasTodayScheduledWorkout
          ? "${todayScheduledWorkout!["subtitle"] ?? "Rutina"} · ${todayScheduledWorkout!["time"] ?? "Hoy"} · ${todayScheduledWorkout!["duration"] ?? "-"}"
          : hasActiveWorkout
              ? "${activeWorkout!["days_per_week"] ?? "-"} días/semana · ${activeWorkout!["duration_minutes"] ?? "-"} min"
              : "Elige o crea una rutina para empezar";

  final icon = hasTodayScheduledWorkout
      ? Icons.today_rounded
      : hasActiveWorkout
          ? Icons.check_circle_rounded
          : Icons.calendar_month_rounded;

  final iconColor = hasTodayScheduledWorkout
      ? TColor.primaryColor1
      : hasActiveWorkout
          ? Colors.green
          : TColor.primaryColor1;

  final buttonText = hasTodayScheduledWorkout
      ? "Empezar"
      : hasActiveWorkout
          ? "Ver"
          : "Elegir";

  final VoidCallback? buttonAction =
      isLoadingActiveWorkout || isLoadingScheduledWorkouts
          ? null
          : hasTodayScheduledWorkout
              ? _openTodayScheduledWorkout
              : hasActiveWorkout
                  ? _openActiveWorkout
                  : _openSavedWorkouts;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          TColor.primaryColor2.withOpacity(0.22),
          TColor.primaryColor1.withOpacity(0.10),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: TColor.primaryColor1.withOpacity(0.10),
      ),
    ),
    child: Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                mainText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 36,
          child: ElevatedButton(
            onPressed: buttonAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.primaryColor1,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildUpcomingScheduledWorkouts() {
    if (isLoadingScheduledWorkouts) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TColor.primaryColor1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Cargando próximos entrenamientos...",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (upcomingScheduledWorkouts.isEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: _openSchedule,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: TColor.primaryColor1.withOpacity(0.07),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: TColor.primaryColor1.withOpacity(0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.event_available_rounded,
                  color: TColor.primaryColor1,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No tienes entrenamientos programados",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Entra en la agenda y programa los días de tu rutina.",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: TColor.gray,
                size: 16,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: upcomingScheduledWorkouts.length,
      itemBuilder: (context, index) {
        final workout = upcomingScheduledWorkouts[index];

        return _UpcomingScheduledWorkoutCard(
          workout: workout,
          onTap: _openSchedule,
        );
      },
    );
  }

  Widget _buildTrainingOptionsSection() {
    final activeDays = _getActiveWorkoutDays();
    final hasActiveDays = activeDays.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: hasActiveDays
              ? "Días de tu rutina activa"
              : "¿Qué quieres entrenar?",
          actionText: "IA",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AiGeneratedWorkoutView(),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        if (hasActiveDays) ...[
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: activeDays.length,
            itemBuilder: (context, index) {
              final day = activeDays[index];
              final dayNumber = _getDayNumberFromDay(day, index);
              final totalExercises = (day["exercises"] as List? ?? []).length;
              final completedExercises =
                  activeDayCompletedExercises[dayNumber] ?? 0;

              return _ActiveWorkoutDayCard(
                day: day,
                index: index,
                completedExercises: completedExercises,
                totalExercises: totalExercises,
                isLoadingProgress: isLoadingActiveDayProgress,
                onTap: () => _openActiveWorkoutDay(index),
              );
            },
          ),
          const SizedBox(height: 8),
        ] else ...[
          _NoActiveWorkoutCard(
            onCreateWithAI: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiGeneratedWorkoutView(),
                ),
              );
            },
            onCreateManual: _openManualWorkoutBuilder,
            onExploreExercises: _openExerciseLibrary,
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Expanded(
              child: _TrainingActionCard(
                icon: Icons.edit_note_rounded,
                title: "Crear rutina manual",
                subtitle: "Elige ejercicios y organiza tus días",
                onTap: _openManualWorkoutBuilder,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TrainingActionCard(
                icon: Icons.search_rounded,
                title: "Explorar ejercicios",
                subtitle: "Consulta ejercicios disponibles",
                onTap: _openExerciseLibrary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
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
        TextButton(
          onPressed: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              color: TColor.primaryColor1,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<dynamic> dailySummary;

  const _WeeklyChart({
    required this.dailySummary,
  });

  int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(value.toString()) ?? 0;
  }

  List<FlSpot> _buildSpots() {
    final valuesByDay = <int, int>{};

    for (final item in dailySummary) {
      if (item is Map<String, dynamic>) {
        final dayIndex = _parseInt(item["day_index"]);
        final minutes = _parseInt(item["total_minutes"]);

        if (dayIndex >= 1 && dayIndex <= 7) {
          valuesByDay[dayIndex] = minutes;
        }
      } else if (item is Map) {
        final map = Map<String, dynamic>.from(item);
        final dayIndex = _parseInt(map["day_index"]);
        final minutes = _parseInt(map["total_minutes"]);

        if (dayIndex >= 1 && dayIndex <= 7) {
          valuesByDay[dayIndex] = minutes;
        }
      }
    }

    return List.generate(7, (index) {
      final dayIndex = index + 1;
      final minutes = valuesByDay[dayIndex] ?? 0;

      return FlSpot(dayIndex.toDouble(), minutes.toDouble());
    });
  }

  double _calculateMaxY(List<FlSpot> spots) {
    final maxValue = spots.fold<double>(
      0,
      (currentMax, spot) => spot.y > currentMax ? spot.y : currentMax,
    );

    if (maxValue <= 0) {
      return 10;
    }

    if (maxValue < 30) {
      return 30;
    }

    return maxValue + 15;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _buildSpots();
    final maxY = _calculateMaxY(spots);

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.black.withOpacity(0.75),
            tooltipBorderRadius: BorderRadius.circular(14),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  "${spot.y.toInt()} min",
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final style = TextStyle(
                  color: TColor.white.withOpacity(0.85),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                );

                String text = "";

                switch (value.toInt()) {
                  case 1:
                    text = "L";
                    break;
                  case 2:
                    text = "M";
                    break;
                  case 3:
                    text = "X";
                    break;
                  case 4:
                    text = "J";
                    break;
                  case 5:
                    text = "V";
                    break;
                  case 6:
                    text = "S";
                    break;
                  case 7:
                    text = "D";
                    break;
                }

                return SideTitleWidget(
                  meta: meta,
                  space: 8,
                  child: Text(text, style: style),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY <= 30 ? 10 : 30,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: TColor.white.withOpacity(0.14),
              strokeWidth: 1.5,
            );
          },
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: TColor.white,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: TColor.white.withOpacity(0.12),
            ),
            spots: spots,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: TColor.primaryColor1,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: TColor.black,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: TColor.gray,
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

class _UpcomingScheduledWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onTap;

  const _UpcomingScheduledWorkoutCard({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: TColor.primaryColor1,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout["title"].toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout["time"].toString(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${workout["duration"]} · ${workout["kcal"]}",
                    style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveWorkoutDayCard extends StatelessWidget {
  final Map<String, dynamic> day;
  final int index;
  final int completedExercises;
  final int totalExercises;
  final bool isLoadingProgress;
  final VoidCallback onTap;

  const _ActiveWorkoutDayCard({
    required this.day,
    required this.index,
    required this.completedExercises,
    required this.totalExercises,
    required this.isLoadingProgress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dayNumber = day["day_number"]?.toString() ?? "${index + 1}";
    final dayName = day["name"]?.toString() ?? "Entrenamiento";
    final focus = day["focus"]?.toString() ?? "Rutina activa";

    final isCompleted =
        totalExercises > 0 && completedExercises >= totalExercises && !isLoadingProgress;

    final progressText = isLoadingProgress
        ? "Cargando progreso..."
        : totalExercises == 0
            ? "Sin ejercicios"
            : "$completedExercises/$totalExercises ejercicios completados";

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.green.withOpacity(0.06) : TColor.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted ? Colors.green : Colors.grey.shade100,
            width: isCompleted ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green.withOpacity(0.12)
                    : TColor.primaryColor1.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 28,
                    )
                  : Text(
                      dayNumber,
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    focus,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    progressText,
                    style: TextStyle(
                      color: isCompleted ? Colors.green : TColor.primaryColor1,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _TrainingActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _TrainingActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 116,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: TColor.primaryColor1,
              size: 26,
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TColor.black,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 10.5,
                height: 1.25,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActiveWorkoutCard extends StatelessWidget {
  final VoidCallback onCreateWithAI;
  final VoidCallback onCreateManual;
  final VoidCallback onExploreExercises;

  const _NoActiveWorkoutCard({
    required this.onCreateWithAI,
    required this.onCreateManual,
    required this.onExploreExercises,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: TColor.primaryColor1,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "No tienes una rutina activa",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Crea una rutina con IA o manualmente para empezar.",
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCreateWithAI,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primaryColor1,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Crear con IA",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: onCreateManual,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TColor.primaryColor1,
                    side: BorderSide(
                      color: TColor.primaryColor1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Manual",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}