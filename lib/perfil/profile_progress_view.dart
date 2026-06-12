import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_goal_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProfileProgressView extends StatefulWidget {
  const ProfileProgressView({super.key});

  @override
  State<ProfileProgressView> createState() => _ProfileProgressViewState();
}

class _ProfileProgressViewState extends State<ProfileProgressView> {
  bool _isLoading = true;
  String? _errorMessage;

  int _totalWorkoutSessions = 0;
  int _totalWorkoutMinutes = 0;
  int _weeklyWorkoutSessions = 0;
  int _weeklyWorkoutMinutes = 0;

  int _totalSleepSessions = 0;
  int _weeklySleepMinutes = 0;
  int _weeklySleepDays = 0;
  int _sleepGoalMinutes = 480;

  int _progressPhotos = 0;

  List<double> _weeklyWorkoutMinutesByDay = List.filled(7, 0);
  List<double> _weeklySleepMinutesByDay = List.filled(7, 0);

  int _touchedWorkoutIndex = -1;
  int _touchedSleepIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final weekStart = today.subtract(Duration(days: today.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 7));

      int totalWorkoutSessions = 0;
      int totalWorkoutMinutes = 0;
      int weeklyWorkoutSessions = 0;
      int weeklyWorkoutMinutes = 0;
      final weeklyWorkoutMinutesByDay = List<double>.filled(7, 0);

      int totalSleepSessions = 0;
      int weeklySleepMinutes = 0;
      final sleepDays = <String>{};
      final weeklySleepMinutesByDay = List<double>.filled(7, 0);

      int progressPhotos = 0;
      int sleepGoalMinutes = 480;

      try {
        final workoutSessions =
            await WorkoutSessionService.getMyWorkoutSessions();

        totalWorkoutSessions = workoutSessions.length;

        for (final item in workoutSessions) {
          if (item is! Map) continue;

          final session = Map<String, dynamic>.from(item);
          final completedAt = _parseDate(session["completed_at"]);
          final duration = _toInt(session["duration_minutes"]) ?? 0;

          totalWorkoutMinutes += duration;

          if (completedAt == null) continue;

          final sessionDay = DateTime(
            completedAt.year,
            completedAt.month,
            completedAt.day,
          );

          if (!sessionDay.isBefore(weekStart) && sessionDay.isBefore(weekEnd)) {
            weeklyWorkoutSessions++;
            weeklyWorkoutMinutes += duration;

            final index = completedAt.weekday - 1;

            if (index >= 0 && index < 7) {
              weeklyWorkoutMinutesByDay[index] += duration.toDouble();
            }
          }
        }
      } catch (_) {}

      try {
        final sleepSessions = await SleepService.getMySleepSessions();

        totalSleepSessions = sleepSessions.length;

        for (final item in sleepSessions) {
          if (item is! Map) continue;

          final sleep = Map<String, dynamic>.from(item);

          final startTime = _parseDate(sleep["start_time"]);
          final endTime = _parseDate(sleep["end_time"]);
          final referenceDate = endTime ?? startTime;
          final duration = _toInt(sleep["duration_minutes"]) ?? 0;

          if (referenceDate == null || duration <= 0) continue;

          final sleepDay = DateTime(
            referenceDate.year,
            referenceDate.month,
            referenceDate.day,
          );

          if (!sleepDay.isBefore(weekStart) && sleepDay.isBefore(weekEnd)) {
            final index = referenceDate.weekday - 1;

            if (index >= 0 && index < 7) {
              weeklySleepMinutesByDay[index] += duration.toDouble();
              weeklySleepMinutes += duration;

              sleepDays.add(
                "${sleepDay.year}-${sleepDay.month}-${sleepDay.day}",
              );
            }
          }
        }
      } catch (_) {}

      try {
        final effectiveGoal =
            await SleepGoalService.getEffectiveSleepGoalToday();
        sleepGoalMinutes = _extractSleepGoalMinutes(effectiveGoal);
      } catch (_) {
        sleepGoalMinutes = 480;
      }

      try {
        final photos = await ProgressPhotoService.getMyProgressPhotos();
        progressPhotos = photos.length;
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _totalWorkoutSessions = totalWorkoutSessions;
        _totalWorkoutMinutes = totalWorkoutMinutes;
        _weeklyWorkoutSessions = weeklyWorkoutSessions;
        _weeklyWorkoutMinutes = weeklyWorkoutMinutes;

        _totalSleepSessions = totalSleepSessions;
        _weeklySleepMinutes = weeklySleepMinutes;
        _weeklySleepDays = sleepDays.length;
        _sleepGoalMinutes = sleepGoalMinutes;

        _progressPhotos = progressPhotos;

        _weeklyWorkoutMinutesByDay = weeklyWorkoutMinutesByDay;
        _weeklySleepMinutesByDay = weeklySleepMinutesByDay;

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
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

  int _extractSleepGoalMinutes(Map<String, dynamic>? response) {
    if (response == null) return 480;

    Map<String, dynamic>? goal;

    if (response["goal"] is Map) {
      goal = Map<String, dynamic>.from(response["goal"] as Map);
    } else if (response["sleep_goal"] is Map) {
      goal = Map<String, dynamic>.from(response["sleep_goal"] as Map);
    } else if (response["target_minutes"] != null) {
      goal = response;
    }

    final target = _toInt(goal?["target_minutes"]);

    if (target != null && target > 0) {
      return target;
    }

    return 480;
  }

  int _weeklySleepAverage() {
    if (_weeklySleepDays <= 0) return 0;

    return (_weeklySleepMinutes / _weeklySleepDays).round();
  }

  int _sleepGoalPercentage() {
    if (_sleepGoalMinutes <= 0) return 0;

    final average = _weeklySleepAverage();
    final percentage = ((average / _sleepGoalMinutes) * 100).round();

    return percentage.clamp(0, 100);
  }

  String _formatMinutes(int minutes) {
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

  String _weekdayShort(int index) {
    switch (index) {
      case 0:
        return "Lun";
      case 1:
        return "Mar";
      case 2:
        return "Mié";
      case 3:
        return "Jue";
      case 4:
        return "Vie";
      case 5:
        return "Sáb";
      case 6:
        return "Dom";
      default:
        return "";
    }
  }

  String _weekdayFull(int index) {
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.rojo.withOpacity(0.16),
            TColor.rojo.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.12),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Icon(
              Icons.show_chart_rounded,
              color: TColor.rojo,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tu progreso",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Resumen global de entrenamiento, sueño y evolución física.",
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ProgressStatCard(
                icon: Icons.fitness_center_rounded,
                value: "$_totalWorkoutSessions",
                label: "Entrenos",
                description: "totales",
                color: TColor.rojo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProgressStatCard(
                icon: Icons.timer_rounded,
                value: _formatMinutes(_totalWorkoutMinutes),
                label: "Tiempo",
                description: "entrenado",
                color: TColor.rojo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ProgressStatCard(
                icon: Icons.bedtime_rounded,
                value: "$_totalSleepSessions",
                label: "Sueño",
                description: "registros",
                color: Colors.indigo,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProgressStatCard(
                icon: Icons.photo_library_rounded,
                value: "$_progressPhotos",
                label: "Fotos",
                description: "progreso",
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklySummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Esta semana",
            style: TextStyle(
              color: TColor.negro,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            icon: Icons.fitness_center_rounded,
            title: "Entrenamientos",
            value: "$_weeklyWorkoutSessions sesiones",
            subtitle: "${_weeklyWorkoutMinutes} min entrenados",
            color: TColor.rojo,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.bedtime_rounded,
            title: "Sueño",
            value: _weeklySleepDays > 0
                ? _formatMinutes(_weeklySleepAverage())
                : "Sin registros",
            subtitle:
                "Objetivo ${_formatMinutes(_sleepGoalMinutes)} · ${_sleepGoalPercentage()}%",
            color: Colors.indigo,
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.photo_camera_rounded,
            title: "Fotos de progreso",
            value: "$_progressPhotos fotos",
            subtitle: _progressPhotos >= 2
                ? "Puedes comparar tu evolución"
                : "Añade más fotos para comparar",
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutChart() {
    return _ChartCard(
      title: "Entrenamiento semanal",
      subtitle: "$_weeklyWorkoutMinutes min esta semana",
      icon: Icons.fitness_center_rounded,
      color: TColor.rojo,
      values: _weeklyWorkoutMinutesByDay,
      touchedIndex: _touchedWorkoutIndex,
      valueFormatter: (value) => "${value.round()} min",
      onTouch: (index) {
        setState(() {
          _touchedWorkoutIndex = index;
        });
      },
      weekdayShort: _weekdayShort,
      weekdayFull: _weekdayFull,
    );
  }

  Widget _buildSleepChart() {
    return _ChartCard(
      title: "Sueño semanal",
      subtitle: _weeklySleepDays > 0
          ? "Media ${_formatMinutes(_weeklySleepAverage())}"
          : "Sin registros esta semana",
      icon: Icons.bedtime_rounded,
      color: Colors.indigo,
      values: _weeklySleepMinutesByDay,
      touchedIndex: _touchedSleepIndex,
      valueFormatter: (value) => _formatMinutes(value.round()),
      onTouch: (index) {
        setState(() {
          _touchedSleepIndex = index;
        });
      },
      weekdayShort: _weekdayShort,
      weekdayFull: _weekdayFull,
      minimumMaxY: _sleepGoalMinutes.toDouble(),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? "No se ha podido cargar el progreso.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _loadProgress,
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: TColor.blanco,
      borderRadius: BorderRadius.circular(24),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColor.negro,
          ),
        ),
        title: Text(
          "Progreso",
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
              onTap: _loadProgress,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: TColor.negro,
                  size: 21,
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
                onRefresh: _loadProgress,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        _buildErrorState()
                      else ...[
                        _buildHeaderCard(),
                        const SizedBox(height: 18),
                        _buildMainStats(),
                        const SizedBox(height: 22),
                        _buildWeeklySummary(),
                        const SizedBox(height: 22),
                        _buildWorkoutChart(),
                        const SizedBox(height: 22),
                        _buildSleepChart(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ProgressStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final String description;
  final Color color;

  const _ProgressStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 118,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
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
              fontSize: 9.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _SummaryRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
            size: 23,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
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
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<double> values;
  final int touchedIndex;
  final String Function(double value) valueFormatter;
  final ValueChanged<int> onTouch;
  final String Function(int index) weekdayShort;
  final String Function(int index) weekdayFull;
  final double minimumMaxY;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.values,
    required this.touchedIndex,
    required this.valueFormatter,
    required this.onTouch,
    required this.weekdayShort,
    required this.weekdayFull,
    this.minimumMaxY = 20,
  });

  double _chartMaxY() {
    final maxValue = values.fold<double>(
      0,
      (previous, current) {
        return current > previous ? current : previous;
      },
    );

    final base = maxValue > minimumMaxY ? maxValue : minimumMaxY;

    return base + 30;
  }

  BarChartGroupData _makeGroup(
    int x,
    double y,
    double chartMaxY,
    bool isTouched,
  ) {
    final safeValue = y <= 0 ? 2.0 : y;
    final touchedValue = isTouched ? safeValue + 6 : safeValue;

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
                    color.withOpacity(0.95),
                    color.withOpacity(0.55),
                  ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 21,
          borderRadius: BorderRadius.circular(10),
          borderSide: isTouched
              ? BorderSide(
                  color: color,
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

  Widget _bottomTitle(double value, TitleMeta meta) {
    final style = TextStyle(
      color: TColor.gris,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );

    return SideTitleWidget(
      meta: meta,
      space: 14,
      child: Text(
        weekdayShort(value.toInt()),
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartMaxY = _chartMaxY();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: TextStyle(
                        color: TColor.negro,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
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
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 185,
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
                      final safeIndex = group.x.clamp(
                        0,
                        values.length - 1,
                      );

                      final realValue = values[safeIndex];

                      return BarTooltipItem(
                        "${weekdayFull(group.x)}\n",
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: valueFormatter(realValue),
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
                    if (!event.isInterestedForInteractions ||
                        barTouchResponse == null ||
                        barTouchResponse.spot == null) {
                      onTouch(-1);
                      return;
                    }

                    onTouch(barTouchResponse.spot!.touchedBarGroupIndex);
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
                      getTitlesWidget: _bottomTitle,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: List.generate(values.length, (index) {
                  return _makeGroup(
                    index,
                    values[index],
                    chartMaxY,
                    index == touchedIndex,
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}