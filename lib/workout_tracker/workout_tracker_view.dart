import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/workout_tracker/workout_detail_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WorkoutTrackerView extends StatefulWidget {
  const WorkoutTrackerView({super.key});

  @override
  State<WorkoutTrackerView> createState() => _WorkoutTrackerViewState();
}

class _WorkoutTrackerViewState extends State<WorkoutTrackerView> {
  final List<Map<String, dynamic>> scheduledWorkouts = [
    {
      "id": 1,
      "image": "assets/img/Workout1.png",
      "title": "Full Body",
      "subtitle": "Fuerza y resistencia",
      "time": "Hoy, 15:00",
      "duration": "32 min",
      "exercises": "11 ejercicios",
      "kcal": "280 kcal",
      "enabled": true,
    },
    {
      "id": 2,
      "image": "assets/img/Workout2.png",
      "title": "Tren superior",
      "subtitle": "Espalda, pecho y brazos",
      "time": "Mañana, 18:30",
      "duration": "40 min",
      "exercises": "12 ejercicios",
      "kcal": "330 kcal",
      "enabled": true,
    },
  ];

  final List<Map<String, dynamic>> workoutPlans = [
    {
      "id": 101,
      "image": "assets/img/what_1.png",
      "title": "Full Body",
      "subtitle": "Entrenamiento completo",
      "exercises": "11 ejercicios",
      "time": "32 min",
      "level": "Medio",
      "kcal": "280 kcal",
      "progress": 0.68,
    },
    {
      "id": 102,
      "image": "assets/img/what_2.png",
      "title": "Tren inferior",
      "subtitle": "Piernas y glúteos",
      "exercises": "12 ejercicios",
      "time": "40 min",
      "level": "Intenso",
      "kcal": "360 kcal",
      "progress": 0.45,
    },
    {
      "id": 103,
      "image": "assets/img/what_3.png",
      "title": "Abdominales",
      "subtitle": "Core y estabilidad",
      "exercises": "14 ejercicios",
      "time": "20 min",
      "level": "Básico",
      "kcal": "180 kcal",
      "progress": 0.82,
    },
  ];

  int selectedFilter = 0;

  final List<String> filters = [
    "Todos",
    "Fuerza",
    "Cardio",
    "Core",
  ];

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
                  onTap: () {
                    // TODO: abrir filtros, calendario o ajustes cuando conectemos backend
                  },
                  child: Container(
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.more_horiz_rounded,
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
                          "4 entrenamientos completados · 1.150 kcal",
                          style: TextStyle(
                            color: TColor.white.withOpacity(0.78),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: _WeeklyChart(),
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
                    const SizedBox(height: 22),
                    _buildDailyScheduleCard(),
                    const SizedBox(height: 26),
                    _buildSectionHeader(
                      title: "Próximos entrenamientos",
                      actionText: "Ver todos",
                      onTap: () {
                        // TODO: pantalla calendario / lista completa desde backend
                      },
                    ),
                    const SizedBox(height: 12),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: scheduledWorkouts.length,
                      itemBuilder: (context, index) {
                        final workout = scheduledWorkouts[index];

                        return _ScheduledWorkoutCard(
                          workout: workout,
                          onChanged: (value) {
                            setState(() {
                              workout["enabled"] = value;
                            });

                            // TODO backend:
                            // PATCH /scheduled-workouts/{id}
                            // body: { enabled: value }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(
                      title: "¿Qué quieres entrenar?",
                      actionText: "IA",
                      onTap: () {
                        // TODO: abrir Coach IA con contexto de entrenamiento
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                    const SizedBox(height: 16),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: workoutPlans.length,
                      itemBuilder: (context, index) {
                        final workout = workoutPlans[index];

                        return _WorkoutPlanCard(
                          workout: workout,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutDetailView(
                                  dObj: workout,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
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
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.fitness_center_rounded,
            value: "4",
            label: "Sesiones",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.local_fire_department_rounded,
            value: "1150",
            label: "Kcal",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            icon: Icons.timer_outlined,
            value: "132",
            label: "Min",
          ),
        ),
      ],
    );
  }

  Widget _buildDailyScheduleCard() {
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
              Icons.calendar_month_rounded,
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
                  "Plan de hoy",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Tienes 1 entrenamiento programado",
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
              onPressed: () {
                // TODO: abrir calendario / detalle del plan diario
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                "Ver",
                style: TextStyle(
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

  Widget _buildFilterChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedFilter == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  selectedFilter = index;
                });

                // TODO backend:
                // GET /workouts?category=filters[index]
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? TColor.primaryColor1 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? TColor.white : TColor.gray,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 100,
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => Colors.black.withOpacity(0.75),
            tooltipBorderRadius: BorderRadius.circular(14),
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  "${spot.y.toInt()}%",
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
          horizontalInterval: 25,
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
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: TColor.white.withOpacity(0.12),
            ),
            spots: const [
              FlSpot(1, 30),
              FlSpot(2, 55),
              FlSpot(3, 42),
              FlSpot(4, 70),
              FlSpot(5, 58),
              FlSpot(6, 85),
              FlSpot(7, 72),
            ],
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

class _ScheduledWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final Function(bool value) onChanged;

  const _ScheduledWorkoutCard({
    required this.workout,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = workout["enabled"] as bool? ?? false;

    return Container(
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
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              workout["image"].toString(),
              width: 58,
              height: 58,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 58,
                  height: 58,
                  color: Colors.grey.shade100,
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: TColor.primaryColor1,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout["title"].toString(),
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
          Switch(
            value: enabled,
            activeColor: TColor.primaryColor1,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _WorkoutPlanCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onTap;

  const _WorkoutPlanCard({
    required this.workout,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = workout["progress"] as double? ?? 0.0;

    return InkWell(
      borderRadius: BorderRadius.circular(26),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(26),
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                workout["image"].toString(),
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 82,
                    height: 82,
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: TColor.primaryColor1,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout["title"].toString(),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout["subtitle"].toString(),
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _MiniTag(text: workout["exercises"].toString()),
                      _MiniTag(text: workout["time"].toString()),
                      _MiniTag(text: workout["level"].toString()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        TColor.primaryColor1,
                      ),
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

class _MiniTag extends StatelessWidget {
  final String text;

  const _MiniTag({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: TColor.primaryColor1,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
