import 'package:afermar3_tf_ipc/Home/actividad_acabada.dart';
import 'package:afermar3_tf_ipc/Home/actividades.dart';
import 'package:afermar3_tf_ipc/Home/notif.dart';
import 'package:afermar3_tf_ipc/Home/widget_ejercicio.dart';
import 'package:afermar3_tf_ipc/funcionalidad/pantallas/ejercicios.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:dotted_dashed_line/dotted_dashed_line.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _Homepantalla();
}

class _Homepantalla extends State<Home> {
  final List<Map<String, dynamic>> ultimaAct = [
    {
      "nombre": "Ejercicios Full Body",
      "imagen": "assets/img/act1.png",
      "kcal": "180",
      "tiempo": "20",
      "progreso": 0.4,
    },
    {
      "nombre": "Ejercicios tren inferior",
      "imagen": "assets/img/act2.png",
      "kcal": "200",
      "tiempo": "30",
      "progreso": 0.6,
    },
    {
      "nombre": "Ejercicios abs",
      "imagen": "assets/img/act3.png",
      "kcal": "300",
      "tiempo": "40",
      "progreso": 0.8,
    },
  ];

  final List<Map<String, String>> agua = [
    {"titulo": "6:00 - 8:00", "subtitulo": "600 ml"},
    {"titulo": "9:00 - 11:00", "subtitulo": "500 ml"},
    {"titulo": "11:00 - 14:00", "subtitulo": "1000 ml"},
    {"titulo": "14:00 - 16:00", "subtitulo": "700 ml"},
    {"titulo": "16:00 - Ahora", "subtitulo": "900 ml"},
  ];

  List<int> showingTooltipOnSpots = [21];

  List<FlSpot> get allSpots => const [
        FlSpot(0, 20),
        FlSpot(1, 25),
        FlSpot(2, 40),
        FlSpot(3, 50),
        FlSpot(4, 35),
        FlSpot(5, 40),
        FlSpot(6, 30),
        FlSpot(7, 20),
        FlSpot(8, 25),
        FlSpot(9, 40),
        FlSpot(10, 50),
        FlSpot(11, 35),
        FlSpot(12, 50),
        FlSpot(13, 60),
        FlSpot(14, 40),
        FlSpot(15, 50),
        FlSpot(16, 20),
        FlSpot(17, 25),
        FlSpot(18, 40),
        FlSpot(19, 50),
        FlSpot(20, 35),
        FlSpot(21, 80),
        FlSpot(22, 30),
        FlSpot(23, 20),
        FlSpot(24, 25),
        FlSpot(25, 40),
        FlSpot(26, 50),
        FlSpot(27, 35),
        FlSpot(28, 50),
        FlSpot(29, 60),
        FlSpot(30, 40),
      ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    final lineasbarradatos = [
      LineChartBarData(
        showingIndicators: showingTooltipOnSpots,
        spots: allSpots,
        isCurved: true,
        barWidth: 3,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              TColor.primerColor1.withOpacity(0.30),
              TColor.primerColor2.withOpacity(0.03),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        dotData: FlDotData(show: false),
        gradient: LinearGradient(colors: TColor.primerG),
      ),
    ];

    final infotools = lineasbarradatos[0];

    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 22),

              _buildBmiCard(media),

              const SizedBox(height: 18),

              _buildTodayGoalCard(),

              const SizedBox(height: 24),

              _sectionTitle("Actividad"),

              const SizedBox(height: 12),

              _buildHeartCard(
                media: media,
                lineasbarradatos: lineasbarradatos,
                infotools: infotools,
              ),

              const SizedBox(height: 22),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildWaterCard(media)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _buildSleepCard(media),
                        const SizedBox(height: 16),
                        _buildCaloriesCard(media),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              _buildProgressHeader(),

              const SizedBox(height: 16),

              _buildProgressChart(
                media: media,
                lineasbarradatos: lineasbarradatos,
                infotools: infotools,
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionTitle("Último ejercicio"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseLista(),
                        ),
                      );
                    },
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
              ),

              ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: ultimaAct.length,
                itemBuilder: (context, index) {
                  final wObj = ultimaAct[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EjercicioAcabado(),
                        ),
                      );
                    },
                    child: Info_Ejercicio(wObj: wObj),
                  );
                },
              ),
            ],
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationView(),
              ),
            );
          },
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

  Widget _buildBmiCard(Size media) {
  return Container(
    height: media.width * 0.42,
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
            vertical: 20,
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
                      "Índice de masa corporal",
                      style: TextStyle(
                        color: TColor.blanco.withOpacity(0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "Tienes un peso normal",
                      style: TextStyle(
                        color: TColor.blanco.withOpacity(0.72),
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: 110,
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () {},
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
                    sections: Secciones(),
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

  Widget _buildTodayGoalCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: TColor.primerColor2.withOpacity(0.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TColor.primerColor2.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.flag_rounded,
              color: TColor.rojo,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Objetivo de hoy",
              style: TextStyle(
                color: TColor.negro,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            height: 32,
            child: botonredondo(
              title: "Ir",
              type: RoundButtonType.bgGradient,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Objetivosdiarios(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeartCard({
    required Size media,
    required List<LineChartBarData> lineasbarradatos,
    required LineChartBarData infotools,
  }) {
    return Container(
      height: media.width * 0.43,
      width: double.infinity,
      decoration: BoxDecoration(
        color: TColor.primerColor2.withOpacity(0.12),
        borderRadius: BorderRadius.circular(26),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pulsaciones",
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "78 LPM",
                    style: TextStyle(
                      color: TColor.rojo,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            LineChart(
              LineChartData(
                showingTooltipIndicators: showingTooltipOnSpots.map((index) {
                  return ShowingTooltipIndicators([
                    LineBarSpot(
                      infotools,
                      lineasbarradatos.indexOf(infotools),
                      infotools.spots[index],
                    ),
                  ]);
                }).toList(),
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: false,
                  touchCallback:
                      (FlTouchEvent event, LineTouchResponse? response) {
                    if (response == null || response.lineBarSpots == null) {
                      return;
                    }

                    if (event is FlTapUpEvent) {
                      final spotIndex = response.lineBarSpots!.first.spotIndex;
                      setState(() {
                        showingTooltipOnSpots = [spotIndex];
                      });
                    }
                  },
                  mouseCursorResolver:
                      (FlTouchEvent event, LineTouchResponse? response) {
                    if (response == null || response.lineBarSpots == null) {
                      return SystemMouseCursors.basic;
                    }
                    return SystemMouseCursors.click;
                  },
                  getTouchedSpotIndicator:
                      (LineChartBarData barData, List<int> spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(color: TColor.rojo),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 3,
                              strokeColor: TColor.segundoColor2,
                            );
                          },
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) =>
                        TColor.segundoColor1.withOpacity(0.85),
                    tooltipBorderRadius: BorderRadius.circular(16),
                    getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                      return lineBarsSpot.map((lineBarSpot) {
                        return LineTooltipItem(
                          "hace ${lineBarSpot.x.toInt()} min",
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: lineasbarradatos,
                minY: 0,
                maxY: 130,
                titlesData: FlTitlesData(show: false),
                gridData: FlGridData(show: false),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.transparent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard(Size media) {
    return Container(
      height: media.width * 0.95,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          SimpleAnimationProgressBar(
            height: media.width * 0.82,
            width: media.width * 0.065,
            backgroundColor: Colors.grey.shade100,
            foregroundColor: Colors.purple,
            ratio: 0.5,
            direction: Axis.vertical,
            curve: Curves.fastLinearToSlowEaseIn,
            duration: const Duration(seconds: 3),
            borderRadius: BorderRadius.circular(15),
            gradientColor: LinearGradient(
              colors: TColor.primerG,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Agua",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "4 litros",
                  style: TextStyle(
                    color: TColor.rojo,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Actualizaciones",
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Column(
                  children: agua.map((wObj) {
                    final isLast = wObj == agua.last;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: TColor.segundoColor1.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            if (!isLast)
                              DottedDashedLine(
                                height: media.width * 0.078,
                                width: 0,
                                dashColor:
                                    TColor.segundoColor1.withOpacity(0.5),
                                axis: Axis.vertical,
                              ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                wObj["titulo"] ?? "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TColor.negro,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                wObj["subtitulo"] ?? "",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: TColor.segundoColor1,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard(Size media) {
  return Container(
    width: double.infinity,
    height: media.width * 0.48,
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Sueño",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "8h 20m",
          style: TextStyle(
            color: TColor.rojo,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: Center(
            child: Image.asset(
              "assets/img/sleep_grap.png",
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildCaloriesCard(Size media) {
    return Container(
      width: double.infinity,
      height: media.width * 0.45,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Calorías",
            style: TextStyle(
              color: TColor.negro,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "760 kcal",
            style: TextStyle(
              color: TColor.rojo,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          Center(
            child: SizedBox(
              width: media.width * 0.21,
              height: media.width * 0.21,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: media.width * 0.15,
                    height: media.width * 0.15,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: TColor.primerG),
                      borderRadius: BorderRadius.circular(media.width * 0.075),
                    ),
                    child: Text(
                      "230\nrestan",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.blanco,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SimpleCircularProgressBar(
                    progressStrokeWidth: 10,
                    backStrokeWidth: 10,
                    progressColors: TColor.primerG,
                    backColor: Colors.grey.shade100,
                    valueNotifier: ValueNotifier(50),
                    startAngle: -180,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _sectionTitle("Progreso"),
        Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.primerG),
            borderRadius: BorderRadius.circular(18),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              items: ["Semanal", "Mensual"]
                  .map(
                    (name) => DropdownMenuItem<String>(
                      value: name,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: TColor.negro,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {},
              icon: Icon(Icons.expand_more, color: TColor.blanco),
              hint: Text(
                "Semanal",
                style: TextStyle(
                  color: TColor.blanco,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressChart({
    required Size media,
    required List<LineChartBarData> lineasbarradatos,
    required LineChartBarData infotools,
  }) {
    return Container(
      height: media.width * 0.55,
      width: double.infinity,
      padding: const EdgeInsets.only(left: 8, right: 8, top: 10, bottom: 4),
      decoration: _cardDecoration(),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: false,
            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
              if (response == null || response.lineBarSpots == null) {
                return;
              }

              if (event is FlTapUpEvent) {
                final spotIndex = response.lineBarSpots!.first.spotIndex;
                setState(() {
                  showingTooltipOnSpots = [spotIndex];
                });
              }
            },
            mouseCursorResolver:
                (FlTouchEvent event, LineTouchResponse? response) {
              if (response == null || response.lineBarSpots == null) {
                return SystemMouseCursors.basic;
              }
              return SystemMouseCursors.click;
            },
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (touchedSpot) =>
                  TColor.segundoColor1.withOpacity(0.85),
              tooltipBorderRadius: BorderRadius.circular(16),
              getTooltipItems: (List<LineBarSpot> lineBarsSpot) {
                return lineBarsSpot.map((lineBarSpot) {
                  return LineTooltipItem(
                    "${lineBarSpot.x.toInt()} min",
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: lineBarsData1,
          minY: -0.5,
          maxY: 110,
          titlesData: FlTitlesData(
            show: true,
            leftTitles: AxisTitles(),
            topTitles: AxisTitles(),
            bottomTitles: AxisTitles(sideTitles: bottomTitles),
            rightTitles: AxisTitles(sideTitles: rightTitles),
          ),
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            horizontalInterval: 25,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: TColor.negro.withOpacity(0.07),
                strokeWidth: 1.5,
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.transparent),
          ),
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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  List<PieChartSectionData> Secciones() {
    return List.generate(
      2,
      (i) {
        switch (i) {
          case 0:
            return PieChartSectionData(
              color: TColor.segundoColor1,
              value: 33,
              title: '',
              radius: 55,
              titlePositionPercentageOffset: 0.55,
              badgeWidget: const Text(
                "20,1",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          case 1:
            return PieChartSectionData(
              color: Colors.white,
              value: 75,
              title: '',
              radius: 45,
              titlePositionPercentageOffset: 0.55,
            );
          default:
            throw Error();
        }
      },
    );
  }

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(
          colors: [
            TColor.primerColor2.withOpacity(0.5),
            TColor.primerColor1.withOpacity(0.5),
          ],
        ),
        barWidth: 4,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 35),
          FlSpot(2, 70),
          FlSpot(3, 40),
          FlSpot(4, 80),
          FlSpot(5, 25),
          FlSpot(6, 70),
          FlSpot(7, 35),
        ],
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(
          colors: [
            TColor.segundoColor2.withOpacity(0.5),
            TColor.segundoColor1.withOpacity(0.5),
          ],
        ),
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: const [
          FlSpot(1, 80),
          FlSpot(2, 50),
          FlSpot(3, 90),
          FlSpot(4, 40),
          FlSpot(5, 80),
          FlSpot(6, 35),
          FlSpot(7, 60),
        ],
      );

  SideTitles get rightTitles => SideTitles(
        getTitlesWidget: rightTitleWidgets,
        showTitles: true,
        interval: 20,
        reservedSize: 40,
      );

  Widget rightTitleWidgets(double value, TitleMeta meta) {
    String text;

    switch (value.toInt()) {
      case 0:
        text = '0%';
        break;
      case 20:
        text = '20%';
        break;
      case 40:
        text = '40%';
        break;
      case 60:
        text = '60%';
        break;
      case 80:
        text = '80%';
        break;
      case 100:
        text = '100%';
        break;
      default:
        return Container();
    }

    return Text(
      text,
      style: TextStyle(
        color: TColor.gris,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final style = TextStyle(
      color: TColor.gris,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    Widget text;

    switch (value.toInt()) {
      case 1:
        text = Text('Lun', style: style);
        break;
      case 2:
        text = Text('Mar', style: style);
        break;
      case 3:
        text = Text('Mié', style: style);
        break;
      case 4:
        text = Text('Jue', style: style);
        break;
      case 5:
        text = Text('Vie', style: style);
        break;
      case 6:
        text = Text('Sáb', style: style);
        break;
      case 7:
        text = Text('Dom', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      meta: meta,
      space: 16,
      child: text,
    );
  }
}