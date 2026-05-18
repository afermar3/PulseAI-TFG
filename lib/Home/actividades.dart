import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
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

  final List<Map<String, String>> latestArr = [
    {
      "imagen": "assets/img/pic_4.png",
      "titulo": "Beber 300 ml de agua",
      "tiempo": "Hace 1 minuto",
    },
    {
      "imagen": "assets/img/pic_5.png",
      "titulo": "Comer aperitivo",
      "tiempo": "Hace 3 horas",
    },
  ];

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
          "Actividades",
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
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.negro,
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTodayGoalCard(),
              SizedBox(height: media.width * 0.08),
              _buildQuickStats(),
              SizedBox(height: media.width * 0.08),
              _buildSectionHeader(
                title: "Progreso",
                trailing: _buildPeriodDropdown(),
              ),
              SizedBox(height: media.width * 0.05),
              _buildProgressChart(media),
              SizedBox(height: media.width * 0.08),
              _buildSectionHeader(
                title: "Última actividad",
                trailing: TextButton(
                  onPressed: () {},
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
              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: latestArr.length,
                itemBuilder: (context, index) {
                  final item = latestArr[index];

                  return _ActivityLogCard(
                    image: item["imagen"] ?? "",
                    title: item["titulo"] ?? "",
                    time: item["tiempo"] ?? "",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayGoalCard() {
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
                onTap: () {},
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
          const Row(
            children: [
              Expanded(
                child: TodayTargetCell(
                  icon: "assets/img/water.png",
                  value: "8L",
                  titulo: "Agua diaria",
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: TodayTargetCell(
                  icon: "assets/img/foot.png",
                  value: "2400",
                  titulo: "Pasos",
                ),
              ),
            ],
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
              icon: Icons.local_fire_department_rounded,
              title: "Calorías",
              value: "760 kcal",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              icon: Icons.timer_rounded,
              title: "Actividad",
              value: "42 min",
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MiniStatCard(
              icon: Icons.check_circle_rounded,
              title: "Meta",
              value: "68%",
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
            });
          },
        ),
      ),
    );
  }

  Widget _buildProgressChart(Size media) {
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
          maxY: 20,
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
                String weekDay;

                switch (group.x) {
                  case 0:
                    weekDay = 'Lunes';
                    break;
                  case 1:
                    weekDay = 'Martes';
                    break;
                  case 2:
                    weekDay = 'Miércoles';
                    break;
                  case 3:
                    weekDay = 'Jueves';
                    break;
                  case 4:
                    weekDay = 'Viernes';
                    break;
                  case 5:
                    weekDay = 'Sábado';
                    break;
                  case 6:
                    weekDay = 'Domingo';
                    break;
                  default:
                    weekDay = '';
                    break;
                }

                return BarTooltipItem(
                  '$weekDay\n',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  children: [
                    TextSpan(
                      text: '${rod.toY.toStringAsFixed(1)} puntos',
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
          barGroups: showingGroups(),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final style = TextStyle(
      color: TColor.negro,
      fontWeight: FontWeight.w700,
      fontSize: 12,
    );

    Widget text;

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

    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups() {
    return List.generate(7, (i) {
      switch (i) {
        case 0:
          return makeGroupData(
            0,
            5,
            isTouched: i == touchedIndex,
          );
        case 1:
          return makeGroupData(
            1,
            10.5,
            isTouched: i == touchedIndex,
          );
        case 2:
          return makeGroupData(
            2,
            5,
            isTouched: i == touchedIndex,
          );
        case 3:
          return makeGroupData(
            3,
            7.5,
            isTouched: i == touchedIndex,
          );
        case 4:
          return makeGroupData(
            4,
            15,
            isTouched: i == touchedIndex,
          );
        case 5:
          return makeGroupData(
            5,
            5.5,
            isTouched: i == touchedIndex,
          );
        case 6:
          return makeGroupData(
            6,
            8.5,
            isTouched: i == touchedIndex,
          );
        default:
          throw Error();
      }
    });
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          gradient: LinearGradient(
            colors: [
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
            toY: 20,
            color: Colors.grey.shade100,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }
}

class TodayTargetCell extends StatelessWidget {
  final String icon;
  final String value;
  final String titulo;

  const TodayTargetCell({
    super.key,
    required this.icon,
    required this.value,
    required this.titulo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(18),
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
          Image.asset(
            icon,
            width: 42,
            height: 42,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: TColor.rojo,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  titulo,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 12,
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

class _ActivityLogCard extends StatelessWidget {
  final String image;
  final String title;
  final String time;

  const _ActivityLogCard({
    required this.image,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
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
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              image,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
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
                    color: TColor.negro,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.more_vert_rounded,
            color: TColor.gris.withOpacity(0.7),
            size: 22,
          ),
        ],
      ),
    );
  }
}
