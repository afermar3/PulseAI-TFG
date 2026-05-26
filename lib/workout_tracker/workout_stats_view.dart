import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum StatsPeriod {
  week,
  month,
  total,
}

class WorkoutStatsView extends StatefulWidget {
  const WorkoutStatsView({super.key});

  @override
  State<WorkoutStatsView> createState() => _WorkoutStatsViewState();
}

class _WorkoutStatsViewState extends State<WorkoutStatsView> {
  StatsPeriod selectedPeriod = StatsPeriod.week;

  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? weeklySummary;
  Map<String, dynamic>? monthlySummary;
  Map<String, dynamic>? totalSummary;
  Map<String, dynamic>? streak;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  Future<void> _loadStats() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        WorkoutSessionService.getWeeklyWorkoutSummary(),
        WorkoutSessionService.getMonthlyWorkoutSummary(),
        WorkoutSessionService.getWorkoutSummary(),
        WorkoutSessionService.getWorkoutStreak(),
      ]);

      if (!mounted) return;

      setState(() {
        weeklySummary = results[0];
        monthlySummary = results[1];
        totalSummary = results[2];
        streak = results[3];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst("Exception: ", "");
        isLoading = false;
      });
    }
  }

  Map<String, dynamic> get _currentSummary {
    switch (selectedPeriod) {
      case StatsPeriod.week:
        return weeklySummary ?? {};
      case StatsPeriod.month:
        return monthlySummary ?? {};
      case StatsPeriod.total:
        return totalSummary ?? {};
    }
  }

  String get _periodTitle {
    switch (selectedPeriod) {
      case StatsPeriod.week:
        return "Esta semana";
      case StatsPeriod.month:
        return "Este mes";
      case StatsPeriod.total:
        return "Total histórico";
    }
  }

  String get _periodSubtitle {
    switch (selectedPeriod) {
      case StatsPeriod.week:
        final start = weeklySummary?["week_start"]?.toString();
        final end = weeklySummary?["week_end"]?.toString();

        if (start == null || end == null) {
          return "Resumen semanal de entrenamientos";
        }

        return "$start · $end";

      case StatsPeriod.month:
        final start = monthlySummary?["month_start"]?.toString();
        final end = monthlySummary?["month_end"]?.toString();

        if (start == null || end == null) {
          return "Resumen mensual de entrenamientos";
        }

        return "$start · $end";

      case StatsPeriod.total:
        return "Todas tus sesiones registradas";
    }
  }

  List<FlSpot> _buildChartSpots() {
    if (selectedPeriod == StatsPeriod.week) {
      final raw = weeklySummary?["daily_summary"];
      final valuesByDay = <int, int>{};

      if (raw is List) {
        for (final item in raw) {
          final map = item is Map<String, dynamic>
              ? item
              : item is Map
                  ? Map<String, dynamic>.from(item)
                  : null;

          if (map == null) continue;

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

    if (selectedPeriod == StatsPeriod.month) {
      final raw = monthlySummary?["weekly_summary"];
      final spots = <FlSpot>[];

      if (raw is List) {
        for (final item in raw) {
          final map = item is Map<String, dynamic>
              ? item
              : item is Map
                  ? Map<String, dynamic>.from(item)
                  : null;

          if (map == null) continue;

          final weekIndex = _parseInt(map["week_index"]);
          final minutes = _parseInt(map["total_minutes"]);

          if (weekIndex > 0) {
            spots.add(FlSpot(weekIndex.toDouble(), minutes.toDouble()));
          }
        }
      }

      if (spots.isEmpty) {
        return const [
          FlSpot(1, 0),
          FlSpot(2, 0),
          FlSpot(3, 0),
          FlSpot(4, 0),
        ];
      }

      return spots;
    }

    final sessions = _parseInt(totalSummary?["total_sessions"]);
    final minutes = _parseInt(totalSummary?["total_minutes"]);
    final exercises = _parseInt(totalSummary?["total_completed_exercises"]);
    final kcal = _parseInt(totalSummary?["estimated_kcal"]);

    return [
      FlSpot(1, sessions.toDouble()),
      FlSpot(2, minutes.toDouble()),
      FlSpot(3, exercises.toDouble()),
      FlSpot(4, kcal.toDouble()),
    ];
  }

  double _calculateMaxY(List<FlSpot> spots) {
    final maxValue = spots.fold<double>(
      0,
      (currentMax, spot) => spot.y > currentMax ? spot.y : currentMax,
    );

    if (maxValue <= 0) return 10;
    if (maxValue < 30) return 30;

    return maxValue + 15;
  }

  String _bottomLabel(double value) {
    if (selectedPeriod == StatsPeriod.week) {
      switch (value.toInt()) {
        case 1:
          return "L";
        case 2:
          return "M";
        case 3:
          return "X";
        case 4:
          return "J";
        case 5:
          return "V";
        case 6:
          return "S";
        case 7:
          return "D";
        default:
          return "";
      }
    }

    if (selectedPeriod == StatsPeriod.month) {
      return "S${value.toInt()}";
    }

    switch (value.toInt()) {
      case 1:
        return "Ses";
      case 2:
        return "Min";
      case 3:
        return "Ej";
      case 4:
        return "Kcal";
      default:
        return "";
    }
  }

  String _tooltipSuffix() {
    switch (selectedPeriod) {
      case StatsPeriod.week:
      case StatsPeriod.month:
        return "min";
      case StatsPeriod.total:
        return "";
    }
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
          "Estadísticas",
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
            onPressed: _loadStats,
            icon: Icon(
              Icons.refresh_rounded,
              color: TColor.primaryColor1,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? _StatsLoadingView()
            : errorMessage != null
                ? _StatsErrorView(
                    message: errorMessage!,
                    onRetry: _loadStats,
                  )
                : RefreshIndicator(
                    onRefresh: _loadStats,
                    color: TColor.primaryColor1,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
                      children: [
                        _buildPeriodSelector(),
                        const SizedBox(height: 18),
                        _buildHeaderCard(),
                        const SizedBox(height: 18),
                        _buildSummaryCards(),
                        const SizedBox(height: 18),
                        _buildChartCard(),
                        const SizedBox(height: 18),
                        _buildStreakCard(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _PeriodButton(
            text: "Semana",
            selected: selectedPeriod == StatsPeriod.week,
            onTap: () {
              setState(() {
                selectedPeriod = StatsPeriod.week;
              });
            },
          ),
          _PeriodButton(
            text: "Mes",
            selected: selectedPeriod == StatsPeriod.month,
            onTap: () {
              setState(() {
                selectedPeriod = StatsPeriod.month;
              });
            },
          ),
          _PeriodButton(
            text: "Total",
            selected: selectedPeriod == StatsPeriod.total,
            onTap: () {
              setState(() {
                selectedPeriod = StatsPeriod.total;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primaryColor1.withOpacity(0.92),
            TColor.primaryColor2.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.insights_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _periodTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _periodSubtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.78),
                    fontSize: 12,
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

  Widget _buildSummaryCards() {
    final summary = _currentSummary;

    final sessions = _parseInt(summary["total_sessions"]).toString();
    final minutes = _parseInt(summary["total_minutes"]).toString();
    final kcal = _parseInt(summary["estimated_kcal"]).toString();
    final exercises = _parseInt(summary["total_completed_exercises"]).toString();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                icon: Icons.fitness_center_rounded,
                value: sessions,
                label: "Sesiones",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatsCard(
                icon: Icons.timer_outlined,
                value: minutes,
                label: "Minutos",
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatsCard(
                icon: Icons.local_fire_department_rounded,
                value: kcal,
                label: "Kcal",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatsCard(
                icon: Icons.check_circle_outline_rounded,
                value: exercises,
                label: "Ejercicios",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    final spots = _buildChartSpots();
    final maxY = _calculateMaxY(spots);
    final suffix = _tooltipSuffix();

    return Container(
      width: double.infinity,
      height: 270,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: TColor.primaryColor1,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryColor1.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Evolución",
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
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
                        final value = spot.y.toInt();

                        return LineTooltipItem(
                          suffix.isEmpty ? "$value" : "$value $suffix",
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
                    sideTitles: SideTitles(showTitles: false),
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
                      reservedSize: 32,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Text(
                            _bottomLabel(value),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                      color: Colors.white.withOpacity(0.14),
                      strokeWidth: 1.5,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final currentStreak = _parseInt(streak?["current_streak"]);
    final trainedToday = streak?["trained_today"] == true;
    final trainedYesterday = streak?["trained_yesterday"] == true;
    final lastTrainingDate = streak?["last_training_date"]?.toString();

    String title;
    String subtitle;
    IconData icon;
    Color color;

    if (currentStreak <= 0) {
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
}

class _PeriodButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? TColor.primaryColor1 : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? TColor.white : TColor.gray,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatsCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade100,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: TColor.primaryColor1,
            size: 25,
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.black,
              fontSize: 19,
              fontWeight: FontWeight.w900,
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
    );
  }
}

class _StatsLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: TColor.primaryColor1,
      ),
    );
  }
}

class _StatsErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _StatsErrorView({
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
              "No se pudieron cargar las estadísticas",
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