import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/widgets/common.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class ResultView extends StatefulWidget {
  final DateTime date1;
  final DateTime date2;

  const ResultView({
    super.key,
    required this.date1,
    required this.date2,
  });

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  int selectButton = 0;

  final List<Map<String, String>> imaArr = [
    {
      "title": "Frontal",
      "month_1_image": "assets/img/pp_1.png",
      "month_2_image": "assets/img/pp_2.png",
    },
    {
      "title": "Espalda",
      "month_1_image": "assets/img/pp_3.png",
      "month_2_image": "assets/img/pp_4.png",
    },
    {
      "title": "Lateral izquierdo",
      "month_1_image": "assets/img/pp_5.png",
      "month_2_image": "assets/img/pp_6.png",
    },
    {
      "title": "Lateral derecho",
      "month_1_image": "assets/img/pp_7.png",
      "month_2_image": "assets/img/pp_8.png",
    },
  ];

  final List<Map<String, String>> statArr = [
    {
      "title": "Pérdida de peso",
      "diff_per": "33",
      "month_1_per": "33%",
      "month_2_per": "67%",
    },
    {
      "title": "Mejora física general",
      "diff_per": "62",
      "month_1_per": "38%",
      "month_2_per": "62%",
    },
    {
      "title": "Masa muscular",
      "diff_per": "57",
      "month_1_per": "57%",
      "month_2_per": "43%",
    },
    {
      "title": "Definición abdominal",
      "diff_per": "89",
      "month_1_per": "89%",
      "month_2_per": "11%",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

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
          "Resultado",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
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
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.ios_share_rounded,
                  color: TColor.black,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 22),
              _buildSegmentedControl(media),
              const SizedBox(height: 24),
              if (selectButton == 0) _buildPhotoTab(media),
              if (selectButton == 1) _buildStatisticTab(media),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primaryColor2.withOpacity(0.24),
            TColor.primaryColor1.withOpacity(0.12),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.compare_rounded,
              color: TColor.primaryColor1,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Comparación de evolución",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${dateToString(widget.date1, formatStr: "MMMM yyyy")}  →  ${dateToString(widget.date2, formatStr: "MMMM yyyy")}",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 13,
                    height: 1.35,
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

  Widget _buildSegmentedControl(Size media) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedAlign(
            alignment: selectButton == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: Container(
              width: (media.width - 56) / 2,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: TColor.primaryG),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    setState(() {
                      selectButton = 0;
                    });
                  },
                  child: Center(
                    child: Text(
                      "Fotos",
                      style: TextStyle(
                        color: selectButton == 0 ? TColor.white : TColor.gray,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () {
                    setState(() {
                      selectButton = 1;
                    });
                  },
                  child: Center(
                    child: Text(
                      "Estadísticas",
                      style: TextStyle(
                        color: selectButton == 1 ? TColor.white : TColor.gray,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildPhotoTab(Size media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAverageProgress(),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateToString(widget.date1, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              dateToString(widget.date2, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: imaArr.length,
          itemBuilder: (context, index) {
            final iObj = imaArr[index];

            return _PhotoComparisonCard(
              title: iObj["title"] ?? "",
              image1: iObj["month_1_image"] ?? "",
              image2: iObj["month_2_image"] ?? "",
            );
          },
        ),
        const SizedBox(height: 18),
        RoundButton(
          title: "Volver",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildAverageProgress() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(24),
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
        children: [
          Row(
            children: [
              Text(
                "Progreso medio",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF6DD570).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Bueno",
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SimpleAnimationProgressBar(
                    height: 22,
                    width: constraints.maxWidth,
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.purple,
                    ratio: 0.62,
                    direction: Axis.horizontal,
                    curve: Curves.fastLinearToSlowEaseIn,
                    duration: const Duration(seconds: 3),
                    borderRadius: BorderRadius.circular(12),
                    gradientColor: LinearGradient(
                      colors: TColor.primaryG,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  Text(
                    "62%",
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticTab(Size media) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: media.width * 0.55,
          width: double.infinity,
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            top: 16,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(24),
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
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: false,
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(color: Colors.transparent),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 3,
                            color: Colors.white,
                            strokeWidth: 3,
                            strokeColor: TColor.secondaryColor1,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => TColor.secondaryColor1,
                  tooltipBorderRadius: BorderRadius.circular(20),
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
                bottomTitles: AxisTitles(
                  sideTitles: bottomTitles,
                ),
                rightTitles: AxisTitles(
                  sideTitles: rightTitles,
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                horizontalInterval: 25,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: TColor.lightGray,
                    strokeWidth: 2,
                  );
                },
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateToString(widget.date1, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              dateToString(widget.date2, formatStr: "MMMM"),
              style: TextStyle(
                color: TColor.gray,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: statArr.length,
          itemBuilder: (context, index) {
            final iObj = statArr[index];

            return _StatisticRow(
              title: iObj["title"] ?? "",
              month1: iObj["month_1_per"] ?? "",
              month2: iObj["month_2_per"] ?? "",
              ratio: (double.tryParse(iObj["diff_per"] ?? "0") ?? 0) / 100,
            );
          },
        ),
        const SizedBox(height: 18),
        RoundButton(
          title: "Volver",
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        gradient: LinearGradient(colors: TColor.primaryG),
        barWidth: 3,
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
            TColor.secondaryColor2.withOpacity(0.5),
            TColor.secondaryColor1.withOpacity(0.5),
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
        color: TColor.gray,
        fontSize: 12,
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
      color: TColor.gray,
      fontSize: 12,
    );

    Widget text;

    switch (value.toInt()) {
      case 1:
        text = Text('Ene', style: style);
        break;
      case 2:
        text = Text('Feb', style: style);
        break;
      case 3:
        text = Text('Mar', style: style);
        break;
      case 4:
        text = Text('Abr', style: style);
        break;
      case 5:
        text = Text('May', style: style);
        break;
      case 6:
        text = Text('Jun', style: style);
        break;
      case 7:
        text = Text('Jul', style: style);
        break;
      default:
        text = const Text('');
        break;
    }

    return SideTitleWidget(
      meta: meta,
      space: 10,
      child: text,
    );
  }
}

class _PhotoComparisonCard extends StatelessWidget {
  final String title;
  final String image1;
  final String image2;

  const _PhotoComparisonCard({
    required this.title,
    required this.image1,
    required this.image2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ImageBox(image: image1),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _ImageBox(image: image2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageBox extends StatelessWidget {
  final String image;

  const _ImageBox({
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: TColor.lightGray,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            image,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.image_not_supported_rounded,
                color: TColor.gray,
                size: 32,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatisticRow extends StatelessWidget {
  final String title;
  final String month1;
  final String month2;
  final double ratio;

  const _StatisticRow({
    required this.title,
    required this.month1,
    required this.month2,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final safeRatio = ratio.clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.white,
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
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColor.black,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 38,
                child: Text(
                  month1,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SimpleAnimationProgressBar(
                      height: 10,
                      width: constraints.maxWidth,
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: TColor.primaryColor1,
                      ratio: safeRatio,
                      direction: Axis.horizontal,
                      curve: Curves.fastLinearToSlowEaseIn,
                      duration: const Duration(seconds: 2),
                      borderRadius: BorderRadius.circular(5),
                      gradientColor: LinearGradient(
                        colors: TColor.primaryG,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 38,
                child: Text(
                  month2,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
