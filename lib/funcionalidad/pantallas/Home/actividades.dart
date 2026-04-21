import 'package:afermar3_tf_ipc/funcionalidad/pantallas/Home/ultima_actividad_.dart';
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

  List latestArr = [
    {
      "imagen": "assets/img/pic_4.png",
      "titulo": "Beber 300ml de agua",
      "tiempo": "Hace 1 minuto"
    },
    {
      "imagen": "assets/img/pic_5.png",
      "titulo": "Comer aperitivo",
      "tiempo": "Hace 3 horas"
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.gris, borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/flecha.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "ACTIVIDADES",
          style: TextStyle(
              color: TColor.negro, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.negro, borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/dospuntos.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.blanco,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    TColor.primerColor2.withOpacity(0.3),
                    TColor.primerColor1.withOpacity(0.3)
                  ]),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Objetivo hoy",
                          style: TextStyle(
                              color: TColor.negro,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: TColor.primerG,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: MaterialButton(
                                onPressed: () {},
                                padding: EdgeInsets.zero,
                                height: 30,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                textColor: TColor.primerColor1,
                                minWidth: double.maxFinite,
                                elevation: 0,
                                color: Colors.transparent,
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15,
                                )),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Row(
                      children: [
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/water.png",
                            value: "8L",
                            titulo: "Consumo agua",
                          ),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: TodayTargetCell(
                            icon: "assets/img/foot.png",
                            value: "2400",
                            titulo: "Pasos",
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progreso",
                    style: TextStyle(
                        color: TColor.negro,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: TColor.segundoG),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          items: ["Semanal", "Mensual"]
                              .map((name) => DropdownMenuItem(
                                    value: name,
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                          color: TColor.negro, fontSize: 14),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {},
                          icon: Icon(Icons.expand_more, color: TColor.blanco),
                          hint: Text(
                            "Semanal",
                            textAlign: TextAlign.center,
                            style:
                                TextStyle(color: TColor.blanco, fontSize: 12),
                          ),
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.5,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                decoration: BoxDecoration(
                    color: TColor.blanco,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 3)
                    ]),
                child: BarChart(BarChartData(
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
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
                            weekDay = 'Miercoles';
                            break;
                          case 3:
                            weekDay = 'Jueves';
                            break;
                          case 4:
                            weekDay = 'Viernes';
                            break;
                          case 5:
                            weekDay = 'Sabado';
                            break;
                          case 6:
                            weekDay = 'Domingo';
                            break;
                          default:
                            throw Error();
                        }
                        return BarTooltipItem(
                          '$weekDay\n',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: (rod.toY - 1).toString(),
                              style: TextStyle(
                                color: TColor.blanco,
                                fontSize: 16,
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
                        touchedIndex =
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
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: getTitles,
                        reservedSize: 38,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: false,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  barGroups: showingGroups(),
                  gridData: FlGridData(show: false),
                )),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ultima actividad",
                    style: TextStyle(
                        color: TColor.negro,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Ver mas",
                      style: TextStyle(
                          color: TColor.negro,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: latestArr.length,
                  itemBuilder: (context, index) {
                    var wObj = latestArr[index] as Map? ?? {};
                    return UltimaActividad(obj: wObj);
                  }),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    var style = TextStyle(
      color: TColor.negro,
      fontWeight: FontWeight.w500,
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
        text = Text('Mie', style: style);
        break;
      case 3:
        text = Text('Jue', style: style);
        break;
      case 4:
        text = Text('Vie', style: style);
        break;
      case 5:
        text = Text('Sab', style: style);
        break;
      case 6:
        text = Text('Dom', style: style);
        break;
      default:
        text = Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        switch (i) {
          case 0:
            return makeGroupData(0, 5, TColor.primerG,
                isTouched: i == touchedIndex);
          case 1:
            return makeGroupData(1, 10.5, TColor.segundoG,
                isTouched: i == touchedIndex);
          case 2:
            return makeGroupData(2, 5, TColor.primerG,
                isTouched: i == touchedIndex);
          case 3:
            return makeGroupData(3, 7.5, TColor.segundoG,
                isTouched: i == touchedIndex);
          case 4:
            return makeGroupData(4, 15, TColor.primerG,
                isTouched: i == touchedIndex);
          case 5:
            return makeGroupData(5, 5.5, TColor.segundoG,
                isTouched: i == touchedIndex);
          case 6:
            return makeGroupData(6, 8.5, TColor.primerG,
                isTouched: i == touchedIndex);
          default:
            return throw Error();
        }
      });

  BarChartGroupData makeGroupData(
    int x,
    double y,
    List<Color> barColor, {
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
              colors: barColor,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          width: width,
          borderSide: isTouched
              ? const BorderSide(color: Colors.green)
              : const BorderSide(color: Colors.white, width: 0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 20,
            color: TColor.negro,
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
  const TodayTargetCell(
      {super.key,
      required this.icon,
      required this.value,
      required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 40,
            height: 40,
            fit: BoxFit.contain,
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                          colors: TColor.primerG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)
                      .createShader(
                          Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                },
                child: Text(
                  value,
                  style: TextStyle(
                      color: TColor.blanco.withOpacity(0.7),
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
              Text(
                titulo,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 12,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
