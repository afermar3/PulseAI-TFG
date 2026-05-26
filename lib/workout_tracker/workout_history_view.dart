import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:flutter/material.dart';

class WorkoutHistoryView extends StatefulWidget {
  const WorkoutHistoryView({super.key});

  @override
  State<WorkoutHistoryView> createState() => _WorkoutHistoryViewState();
}

class _WorkoutHistoryViewState extends State<WorkoutHistoryView> {
  late Future<List<dynamic>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = WorkoutSessionService.getMyWorkoutSessions();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadSessions();
    });
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  String _formatDateHeader(DateTime? date) {
    if (date == null) return "Sin fecha";

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDay = DateTime(date.year, date.month, date.day);

    if (sessionDay == today) {
      return "Hoy";
    }

    if (sessionDay == yesterday) {
      return "Ayer";
    }

    return "${date.day.toString().padLeft(2, "0")}/${date.month.toString().padLeft(2, "0")}/${date.year}";
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "--:--";

    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    return "$hour:$minute";
  }

  Map<String, List<Map<String, dynamic>>> _groupSessionsByDate(
    List<dynamic> sessions,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in sessions) {
      final session = Map<String, dynamic>.from(item as Map);
      final date = _parseDate(session["completed_at"]);
      final header = _formatDateHeader(date);

      grouped.putIfAbsent(header, () => []);
      grouped[header]!.add(session);
    }

    return grouped;
  }

  int _calculateEstimatedKcal(Map<String, dynamic> session) {
    final minutes = _parseInt(session["duration_minutes"]);
    return minutes * 6;
  }

  double _calculateCompletionPercent(Map<String, dynamic> session) {
    final total = _parseInt(session["total_exercises"]);
    final completed = _parseInt(session["completed_exercises"]);

    if (total <= 0) return 0;

    return (completed / total).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Historial",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColor.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: Icon(
              Icons.refresh_rounded,
              color: TColor.primaryColor1,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingHistoryView();
            }

            if (snapshot.hasError) {
              return _HistoryErrorView(
                message: snapshot.error.toString().replaceFirst(
                      "Exception: ",
                      "",
                    ),
                onRetry: _refresh,
              );
            }

            final sessions = snapshot.data ?? [];

            if (sessions.isEmpty) {
              return _EmptyHistoryView(
                onRefresh: _refresh,
              );
            }

            final groupedSessions = _groupSessionsByDate(sessions);
            final groups = groupedSessions.entries.toList();

            return RefreshIndicator(
              onRefresh: _refresh,
              color: TColor.primaryColor1,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
                itemCount: groups.length,
                itemBuilder: (context, groupIndex) {
                  final group = groups[groupIndex];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (groupIndex > 0) const SizedBox(height: 18),
                      Text(
                        group.key,
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...group.value.map((session) {
                        final completedAt = _parseDate(session["completed_at"]);
                        final totalExercises =
                            _parseInt(session["total_exercises"]);
                        final completedExercises =
                            _parseInt(session["completed_exercises"]);
                        final durationMinutes =
                            _parseInt(session["duration_minutes"]);
                        final kcal = _calculateEstimatedKcal(session);
                        final percent = _calculateCompletionPercent(session);

                        return _WorkoutHistoryCard(
                          title: session["workout_title"]?.toString() ??
                              "Entrenamiento",
                          subtitle: session["day_name"]?.toString() ??
                              "Sesión completada",
                          time: _formatTime(completedAt),
                          durationMinutes: durationMinutes,
                          kcal: kcal,
                          completedExercises: completedExercises,
                          totalExercises: totalExercises,
                          percent: percent,
                        );
                      }),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String time;
  final int durationMinutes;
  final int kcal;
  final int completedExercises;
  final int totalExercises;
  final double percent;

  const _WorkoutHistoryCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.durationMinutes,
    required this.kcal,
    required this.completedExercises,
    required this.totalExercises,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = totalExercises > 0 && completedExercises >= totalExercises;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.white,
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.12)
                      : TColor.primaryColor1.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.fitness_center_rounded,
                  color: isCompleted ? Colors.green : TColor.primaryColor1,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                    const SizedBox(height: 6),
                    Text(
                      "$time · $durationMinutes min · $kcal kcal",
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: percent,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.green : TColor.primaryColor1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "$completedExercises/$totalExercises",
                style: TextStyle(
                  color: isCompleted ? Colors.green : TColor.primaryColor1,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingHistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: TColor.primaryColor1,
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyHistoryView({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: TColor.primaryColor1,
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 130),
          Icon(
            Icons.history_rounded,
            color: TColor.primaryColor1,
            size: 60,
          ),
          const SizedBox(height: 18),
          Text(
            "Aún no hay sesiones completadas",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Cuando completes entrenamientos, aparecerán aquí ordenados por fecha.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _HistoryErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: TColor.rojo,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              "No se pudo cargar el historial",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.rojo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}