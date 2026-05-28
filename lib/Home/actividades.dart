import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/scheduled_workout_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Objetivosdiarios extends StatefulWidget {
  const Objetivosdiarios({super.key});

  @override
  State<Objetivosdiarios> createState() => _ObjetivosdiariosState();
}

class _ObjetivosdiariosState extends State<Objetivosdiarios> {
  int touchedIndex = -1;
  String selectedPeriod = "Semanal";

  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _scheduledWorkouts = [];
  List<dynamic> _workoutSessions = [];
  List<Map<String, dynamic>> _parsedSessions = [];

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

  List<double> _weeklyMinutesByDay = List.filled(7, 0);
  List<double> _monthlyMinutesByWeek = List.filled(5, 0);

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  Future<void> _loadDailyData() async {
    try {
      final scheduled = await ScheduledWorkoutService.getMyScheduledWorkouts();
      final sessions = await WorkoutSessionService.getMyWorkoutSessions();

      if (!mounted) return;

      setState(() {
        _scheduledWorkouts = scheduled;
        _workoutSessions = sessions;
        _errorMessage = null;
        _processData();
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

  void _processData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 7));

    final monthStart = DateTime(today.year, today.month, 1);
    final monthEnd = DateTime(today.year, today.month + 1, 1);

    _todayScheduledWorkout = null;
    _lastSession = null;
    _parsedSessions = [];

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

      final scheduledMap = Map<String, dynamic>.from(item);
      final scheduledDate = _parseDate(scheduledMap["scheduled_date"]);

      if (scheduledDate == null) continue;

      final scheduledDay = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      if (!scheduledDay.isBefore(weekStart) && scheduledDay.isBefore(weekEnd)) {
        _weeklyScheduledCount++;

        if (scheduledMap["completed"] == true) {
          _weeklyCompletedScheduledCount++;
        }
      }

      if (!scheduledDay.isBefore(monthStart) &&
          scheduledDay.isBefore(monthEnd)) {
        _monthlyScheduledCount++;

        if (scheduledMap["completed"] == true) {
          _monthlyCompletedScheduledCount++;
        }
      }

      if (_isSameDay(scheduledDay, today)) {
        todayScheduled.add(scheduledMap);
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

      final sessionMap = Map<String, dynamic>.from(item);
      final completedAt = _parseDate(sessionMap["completed_at"]);

      if (completedAt == null) continue;

      sessionMap["_completed_at_parsed"] = completedAt;
      parsedSessions.add(sessionMap);

      final sessionDay = DateTime(
        completedAt.year,
        completedAt.month,
        completedAt.day,
      );

      final duration = _toInt(sessionMap["duration_minutes"]) ?? 0;

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

    _parsedSessions = parsedSessions;

    if (parsedSessions.isNotEmpty) {
      _lastSession = parsedSessions.first;
    }
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

  int _goalPercentage() {
    final scheduledCount = selectedPeriod == "Mensual"
        ? _monthlyScheduledCount
        : _weeklyScheduledCount;

    final completedScheduledCount = selectedPeriod == "Mensual"
        ? _monthlyCompletedScheduledCount
        : _weeklyCompletedScheduledCount;

    final sessions = selectedPeriod == "Mensual"
        ? _monthlySessions
        : _weeklySessions;

    if (scheduledCount <= 0) {
      return sessions > 0 ? 100 : 0;
    }

    final percentage = ((completedScheduledCount / scheduledCount) * 100).round();

    return percentage.clamp(0, 100);
  }

  int _periodSessions() {
    return selectedPeriod == "Mensual" ? _monthlySessions : _weeklySessions;
  }

  int _periodMinutes() {
    return selectedPeriod == "Mensual" ? _monthlyMinutes : _weeklyMinutes;
  }

  List<double> _chartValues() {
    return selectedPeriod == "Mensual"
        ? _monthlyMinutesByWeek
        : _weeklyMinutesByDay;
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

  String _formatLastSessionTitle() {
    if (_lastSession == null) {
      return "Aún no has completado entrenamientos";
    }

    return _formatSessionTitle(_lastSession!);
  }

  String _formatSessionTitle(Map<String, dynamic> session) {
    final dayNumber = session["day_number"];
    final dayName = session["day_name"]?.toString();
    final workoutTitle = session["workout_title"]?.toString() ?? "Entrenamiento";

    if (dayNumber != null && dayName != null && dayName.trim().isNotEmpty) {
      return "Día $dayNumber - $dayName";
    }

    return workoutTitle;
  }

  String _formatLastSessionSubtitle() {
    if (_lastSession == null) {
      return "Cuando completes una sesión, aparecerá aquí.";
    }

    return _formatSessionSubtitle(_lastSession!);
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

  String _todayGoalSubtitle() {
    if (_todayScheduledWorkout == null) {
      return "No tienes entrenamiento programado para hoy.";
    }

    final completed = _todayScheduledWorkout!["completed"] == true;
    final duration = _toInt(_todayScheduledWorkout!["duration_minutes"]);

    final durationText = duration == null ? "Duración no definida" : "$duration min";

    if (completed) {
      return "Completado · $durationText";
    }

    return "Pendiente · $durationText";
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();

    return "$day/$month/$year";
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TColor.rojo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showActivityHistorySheet() {
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
                child: _parsedSessions.isEmpty
                    ? Center(
                        child: Text(
                          "Aún no tienes sesiones completadas.",
                          style: TextStyle(
                            color: TColor.gris,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _parsedSessions.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final session = _parsedSessions[index];
                          final completedAt =
                              session["_completed_at_parsed"] as DateTime?;

                          return _HistorySessionCard(
                            title: _formatSessionTitle(session),
                            subtitle: _formatSessionSubtitle(session),
                            dateText: completedAt == null
                                ? "Fecha no disponible"
                                : _formatDate(completedAt),
                            onTap: () {
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
    final workoutTitle = session["workout_title"]?.toString() ?? "Entrenamiento";
    final dateText = completedAt == null ? "Fecha no disponible" : _formatDate(completedAt);

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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColor.negro,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          "Objetivo de hoy",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _loadDailyData,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.negro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
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
                  color: TColor.rojo,
                ),
              )
            : RefreshIndicator(
                color: TColor.rojo,
                onRefresh: _loadDailyData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 115),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        _buildErrorCard(),
                        SizedBox(height: media.width * 0.06),
                      ],
                      _buildTodayGoalCard(),
                      SizedBox(height: media.width * 0.08),
                      _buildQuickStats(),
                      SizedBox(height: media.width * 0.08),
                      _buildSectionHeader(
                        title: selectedPeriod == "Mensual"
                            ? "Progreso mensual"
                            : "Progreso semanal",
                        trailing: _buildPeriodDropdown(),
                      ),
                      SizedBox(height: media.width * 0.05),
                      _buildProgressChart(media),
                      SizedBox(height: media.width * 0.08),
                      _buildSectionHeader(
                        title: "Última actividad",
                        trailing: TextButton(
                          onPressed: _showActivityHistorySheet,
                          child: Text(
                            "Ver más",
                            style: TextStyle(
                              color: TColor.rojo,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildLastActivityCard(),
                    ],
                  ),
                ),
              ),
      ),
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

  Widget _buildTodayGoalCard() {
    final hasWorkoutToday = _todayScheduledWorkout != null;
    final completed = _todayScheduledWorkout?["completed"] == true;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.rojo.withOpacity(0.12),
            TColor.rojo.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.10),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Objetivo de hoy",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  _showComingSoon(
                    "Puedes programar entrenamientos desde el Coach IA o desde tu rutina activa",
                  );
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TColor.rojo.withOpacity(0.85),
                        TColor.rojo,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: TColor.rojo.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: TColor.blanco,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: TColor.rojo.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : hasWorkoutToday
                            ? Icons.fitness_center_rounded
                            : Icons.event_busy_rounded,
                    color: completed ? Colors.green : TColor.rojo,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasWorkoutToday
                            ? _formatWorkoutTitle(_todayScheduledWorkout)
                            : "Sin entrenamiento programado",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.negro,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _todayGoalSubtitle(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.gris,
                          fontSize: 12,
                          height: 1.25,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return SizedBox(
      height: 105,
      child: Row(
        children: [
          Expanded(
            child: _MiniStatCard(
              icon: Icons.check_circle_rounded,
              title: "Sesiones",
              value: "${_periodSessions()}",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              icon: Icons.timer_rounded,
              title: "Minutos",
              value: "${_periodMinutes()} min",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              icon: Icons.flag_rounded,
              title: "Meta",
              value: "${_goalPercentage()}%",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required Widget trailing,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.negro,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _buildPeriodDropdown() {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: TColor.negro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedPeriod,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: TColor.blanco,
            size: 22,
          ),
          selectedItemBuilder: (context) {
            return ["Semanal", "Mensual"].map((name) {
              return Center(
                child: Text(
                  name,
                  style: TextStyle(
                    color: TColor.blanco,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              );
            }).toList();
          },
          items: ["Semanal", "Mensual"].map((name) {
            return DropdownMenuItem<String>(
              value: name,
              child: Text(
                name,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              selectedPeriod = value;
              touchedIndex = -1;
            });
          },
        ),
      ),
    );
  }

  Widget _buildProgressChart(Size media) {
    final values = _chartValues();

    final maxMinutes = values.fold<double>(
      0,
      (previousValue, element) {
        return element > previousValue ? element : previousValue;
      },
    );

    final chartMaxY = maxMinutes <= 0 ? 20.0 : (maxMinutes + 15).toDouble();

    return Container(
      height: media.width * 0.58,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
              tooltipHorizontalAlignment: FLHorizontalAlignment.right,
              tooltipMargin: 10,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final label = selectedPeriod == "Mensual"
                    ? "Semana ${group.x + 1}"
                    : _weekdayName(group.x);

                return BarTooltipItem(
                  '$label\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toStringAsFixed(0)} min',
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
                  touchedIndex = -1;
                  return;
                }

                touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
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
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: getTitles,
                reservedSize: 38,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: showingGroups(chartMaxY),
          gridData: FlGridData(show: false),
        ),
      ),
    );
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

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: TColor.negro,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );

    Widget text;

    if (selectedPeriod == "Mensual") {
      switch (value.toInt()) {
        case 0:
          text = Text('S1', style: style);
          break;
        case 1:
          text = Text('S2', style: style);
          break;
        case 2:
          text = Text('S3', style: style);
          break;
        case 3:
          text = Text('S4', style: style);
          break;
        case 4:
          text = Text('S5', style: style);
          break;
        default:
          text = Text('', style: style);
          break;
      }
    } else {
      switch (value.toInt()) {
        case 0:
          text = Text('Lun', style: style);
          break;
        case 1:
          text = Text('Mar', style: style);
          break;
        case 2:
          text = Text('Mié', style: style);
          break;
        case 3:
          text = Text('Jue', style: style);
          break;
        case 4:
          text = Text('Vie', style: style);
          break;
        case 5:
          text = Text('Sáb', style: style);
          break;
        case 6:
          text = Text('Dom', style: style);
          break;
        default:
          text = Text('', style: style);
          break;
      }
    }

    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups(double chartMaxY) {
    final values = _chartValues();

    return List.generate(values.length, (i) {
      final value = values[i];

      return makeGroupData(
        i,
        value,
        chartMaxY: chartMaxY,
        isTouched: i == touchedIndex,
      );
    });
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    required double chartMaxY,
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
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
          width: width,
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
      showingTooltipIndicators: showTooltips,
    );
  }

  Widget _buildLastActivityCard() {
    final hasSession = _lastSession != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(22),
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
                  _formatLastSessionTitle(),
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
                  _formatLastSessionSubtitle(),
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
            InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                _showSessionDetails(_lastSession!);
              },
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.more_vert_rounded,
                  color: TColor.gris.withOpacity(0.7),
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MiniStatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 105,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
            size: 23,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.negro,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
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