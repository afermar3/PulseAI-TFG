import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

class ExercisesStepDetails extends StatefulWidget {
  final Map eObj;

  const ExercisesStepDetails({
    super.key,
    required this.eObj,
  });

  @override
  State<ExercisesStepDetails> createState() => _ExercisesStepDetailsState();
}

class _ExercisesStepDetailsState extends State<ExercisesStepDetails> {
  int selectedRepetitions = 12;

  final List<Map<String, dynamic>> stepArr = [
    {
      "no": "01",
      "title": "Coloca bien la postura",
      "detail":
          "Mantén la espalda recta, activa el abdomen y separa ligeramente los pies para tener estabilidad durante el movimiento.",
    },
    {
      "no": "02",
      "title": "Controla el movimiento",
      "detail":
          "Realiza el ejercicio de forma progresiva, sin tirones bruscos. Prioriza siempre la técnica antes que la velocidad.",
    },
    {
      "no": "03",
      "title": "Mantén la respiración",
      "detail":
          "Inhala antes de iniciar el esfuerzo y exhala durante la fase principal del movimiento para mantener el control.",
    },
    {
      "no": "04",
      "title": "Vuelve a la posición inicial",
      "detail":
          "Regresa lentamente a la posición inicial, evitando perder la postura. Descansa unos segundos si lo necesitas.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    final String title = widget.eObj["title"]?.toString() ?? "Ejercicio";
    final String value = widget.eObj["value"]?.toString() ?? "12x";
    final String type = widget.eObj["type"]?.toString() ?? "reps";
    final String image =
        widget.eObj["image"]?.toString() ?? "assets/img/video_temp.png";

    final String description = widget.eObj["description"]?.toString() ??
        "Este ejercicio ayuda a mejorar la resistencia, la coordinación y el control corporal. Realízalo manteniendo una técnica correcta y adaptando la intensidad a tu nivel físico.";

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
          "Detalle del ejercicio",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                // TODO: opciones del ejercicio: editar, eliminar, añadir a favoritos...
              },
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: TColor.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVideoCard(media, image),
                const SizedBox(height: 22),
                _buildTitleSection(
                  title: title,
                  value: value,
                  type: type,
                ),
                const SizedBox(height: 20),
                _buildStatsRow(
                  type: type,
                  value: value,
                ),
                const SizedBox(height: 26),
                _buildSectionHeader(
                  title: "Descripción",
                  actionText: "",
                ),
                const SizedBox(height: 8),
                ReadMoreText(
                  description,
                  trimLines: 4,
                  colorClickableText: TColor.rojo,
                  trimMode: TrimMode.Line,
                  trimCollapsedText: ' Leer más',
                  trimExpandedText: ' Leer menos',
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                  moreStyle: TextStyle(
                    color: TColor.rojo,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  lessStyle: TextStyle(
                    color: TColor.rojo,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 26),
                _buildSectionHeader(
                  title: "Cómo hacerlo",
                  actionText: "${stepArr.length} pasos",
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: stepArr.length,
                  itemBuilder: (context, index) {
                    final step = stepArr[index];

                    return _StepCard(
                      step: step,
                      isLast: index == stepArr.length - 1,
                    );
                  },
                ),
                const SizedBox(height: 26),
                _buildSectionHeader(
                  title: type == "time"
                      ? "Duración personalizada"
                      : "Repeticiones personalizadas",
                  actionText: "",
                ),
                const SizedBox(height: 12),
                _buildPicker(type),
                const SizedBox(height: 20),
                _buildAdviceCard(),
              ],
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: RoundButton(
                title: "Guardar configuración",
                elevation: 0,
                onPressed: () {
                  // TODO backend:
                  // PATCH /exercise-settings/{exerciseId}
                  // body: { repetitions: selectedRepetitions }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        type == "time"
                            ? "Duración guardada correctamente"
                            : "Repeticiones guardadas correctamente",
                      ),
                      backgroundColor: TColor.rojo,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(Size media, String image) {
    return Container(
      width: double.infinity,
      height: media.width * 0.48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: TColor.primaryG,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: TColor.primaryColor1.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Image.asset(
              image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/img/video_temp.png",
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.18),
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(35),
            onTap: () {
              // TODO: reproducir vídeo real del ejercicio
            },
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: TColor.rojo,
                size: 38,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection({
    required String title,
    required String value,
    required String type,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                type == "time"
                    ? "Ejercicio por tiempo · $value"
                    : type == "rest"
                        ? "Descanso recomendado · $value"
                        : "Ejercicio por repeticiones · $value",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TColor.rojo.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            "Básico",
            style: TextStyle(
              color: TColor.rojo,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow({
    required String type,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: type == "time" ? Icons.timer_outlined : Icons.repeat_rounded,
            value: value,
            label: type == "time" ? "Duración" : "Reps",
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department_rounded,
            value: "45",
            label: "Kcal",
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _StatCard(
            icon: Icons.speed_rounded,
            value: "Fácil",
            label: "Nivel",
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (actionText.isNotEmpty)
          Text(
            actionText,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  Widget _buildPicker(String type) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: CupertinoPicker.builder(
        itemExtent: 42,
        selectionOverlay: Container(
          width: double.infinity,
          height: 42,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: TColor.gray.withOpacity(0.18),
                width: 1,
              ),
              bottom: BorderSide(
                color: TColor.gray.withOpacity(0.18),
                width: 1,
              ),
            ),
          ),
        ),
        onSelectedItemChanged: (index) {
          setState(() {
            selectedRepetitions = index + 1;
          });
        },
        childCount: type == "time" ? 30 : 60,
        itemBuilder: (context, index) {
          final value = index + 1;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                type == "time" ? Icons.timer_outlined : Icons.repeat_rounded,
                color: TColor.rojo,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                type == "time" ? "$value min" : "$value repeticiones",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "· ${(value * 4).clamp(5, 240)} kcal aprox.",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAdviceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: TColor.rojo,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Prioriza la técnica antes que la velocidad. Si sientes dolor o mareo, detén el ejercicio y descansa.",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              color: TColor.rojo,
              size: 24,
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                color: TColor.black,
                fontSize: 15,
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
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final Map<String, dynamic> step;
  final bool isLast;

  const _StepCard({
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                step["no"].toString(),
                style: TextStyle(
                  color: TColor.rojo,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 54,
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: TColor.rojo.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
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
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step["title"].toString(),
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  step["detail"].toString(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
