import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/services/exercise_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/workout_tracker/exercise_video_helper.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Map<String, dynamic>? exerciseDetails;
  bool isLoadingDetails = false;

  final List<Map<String, dynamic>> fallbackSteps = [
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
  void initState() {
    super.initState();

    selectedRepetitions = _extractFirstNumber(
      widget.eObj["value"]?.toString() ?? "12",
    );

    _loadExerciseDetailsIfNeeded();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  int _extractFirstNumber(String text) {
    final match = RegExp(r'\d+').firstMatch(text);

    return int.tryParse(match?.group(0) ?? "") ?? 12;
  }

  String _getValue(String key, String fallback) {
    final fromDetails = exerciseDetails?[key]?.toString();

    if (fromDetails != null && fromDetails.trim().isNotEmpty) {
      return fromDetails;
    }

    final fromObj = widget.eObj[key]?.toString();

    if (fromObj != null && fromObj.trim().isNotEmpty) {
      return fromObj;
    }

    return fallback;
  }

  Future<void> _loadExerciseDetailsIfNeeded() async {
    final exerciseId = _parseInt(
      widget.eObj["exercise_id"] ?? widget.eObj["id"],
    );

    if (exerciseId == null) return;

    setState(() {
      isLoadingDetails = true;
    });

    try {
      final details = await ExerciseService.getExerciseById(exerciseId);

      if (!mounted) return;

      setState(() {
        exerciseDetails = Map<String, dynamic>.from(details);
        isLoadingDetails = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoadingDetails = false;
      });
    }
  }

  List<Map<String, dynamic>> _buildStepsFromInstructions(String instructions) {
    final cleaned = instructions.trim();

    if (cleaned.isEmpty) {
      return fallbackSteps;
    }

    final parts = cleaned
        .split(RegExp(r'[\n\r]+|(?<=\.)\s+|;'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return fallbackSteps;
    }

    return List.generate(parts.length, (index) {
      final number = (index + 1).toString().padLeft(2, "0");

      return {
        "no": number,
        "title": "Paso ${index + 1}",
        "detail": parts[index],
      };
    });
  }

  bool _isNetworkImage(String image) {
    return image.startsWith("http://") || image.startsWith("https://");
  }

  String? _getVideoUrl({
    required String title,
    required String muscleGroup,
    required String category,
  }) {
    final explicitVideoUrl = _getValue("video_url", "");

    return ExerciseVideoHelper.getVideoUrl(
      exerciseName: title,
      muscleGroup: muscleGroup,
      category: category,
      explicitVideoUrl: explicitVideoUrl,
    );
  }

  Future<void> _openExerciseVideo({
    required String title,
    required String muscleGroup,
    required String category,
  }) async {
    final videoUrl = _getVideoUrl(
      title: title,
      muscleGroup: muscleGroup,
      category: category,
    );

    if (videoUrl == null || videoUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No hay vídeo disponible para este ejercicio"),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final uri = Uri.parse(videoUrl);

    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No se ha podido abrir el vídeo"),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    final String title = _getValue("name", "").isNotEmpty
        ? _getValue("name", "Ejercicio")
        : widget.eObj["title"]?.toString() ?? "Ejercicio";

    final String value = widget.eObj["value"]?.toString() ?? "12x";
    final String type = widget.eObj["type"]?.toString() ?? "reps";

    final String image = _getValue("image", "assets/img/video_temp.png");

    final String description = _getValue(
      "description",
      "Ejercicio incluido en PulseAI. Realízalo manteniendo una técnica correcta y adaptando la intensidad a tu nivel físico.",
    );

    final String instructions = _getValue("instructions", "");

    final String sets = widget.eObj["sets"]?.toString() ?? "-";
    final String restSeconds = widget.eObj["rest_seconds"]?.toString() ?? "-";

    final String muscleGroup = _getValue("muscle_group", "General");
    final String difficulty = _getValue("difficulty", "Sin nivel");
    final String category = _getValue("category", "Ejercicio");
    final String equipment = _getValue("equipment", "Sin material específico");

    final String notes = widget.eObj["notes"]?.toString() ?? "";

    final steps = _buildStepsFromInstructions(instructions);

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
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: isLoadingDetails
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TColor.rojo,
                      ),
                    )
                  : Icon(
                      Icons.info_outline_rounded,
                      color: TColor.black,
                      size: 22,
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
                _buildVideoCard(
                  media,
                  image,
                  title: title,
                  muscleGroup: muscleGroup,
                  category: category,
                ),
                const SizedBox(height: 22),
                _buildTitleSection(
                  title: title,
                  value: value,
                  type: type,
                  difficulty: difficulty,
                ),
                const SizedBox(height: 20),
                _buildStatsRow(
                  type: type,
                  value: value,
                  sets: sets,
                  restSeconds: restSeconds,
                ),
                const SizedBox(height: 26),
                _buildExerciseInfoCard(
                  muscleGroup: muscleGroup,
                  category: category,
                  difficulty: difficulty,
                  equipment: equipment,
                  sets: sets,
                  reps: value,
                  restSeconds: restSeconds,
                  notes: notes,
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
                  actionText: steps.length == 1 ? "1 paso" : "${steps.length} pasos",
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];

                    return _StepCard(
                      step: step,
                      isLast: index == steps.length - 1,
                    );
                  },
                ),
                const SizedBox(height: 26),
                _buildSectionHeader(
                  title: "Configuración de la rutina",
                  actionText: "",
                ),
                const SizedBox(height: 12),
                _buildRoutineConfigCard(
                  type: type,
                  value: value,
                  sets: sets,
                  restSeconds: restSeconds,
                  notes: notes,
                ),
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
                title: "Entendido",
                elevation: 0,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildVideoCard(
  Size media,
  String image, {
  required String title,
  required String muscleGroup,
  required String category,
}) {
  final explicitVideoUrl = _getValue("video_url", "");

  final hasDirectVideo = ExerciseVideoHelper.hasDirectVideo(
    exerciseName: title,
    explicitVideoUrl: explicitVideoUrl,
  );

  final double cardHeight = (media.width * 0.58).clamp(205.0, 235.0).toDouble();

  return InkWell(
    borderRadius: BorderRadius.circular(26),
    onTap: () {
      _openExerciseVideo(
        title: title,
        muscleGroup: muscleGroup,
        category: category,
      );
    },
    child: Container(
      width: double.infinity,
      height: cardHeight,
      padding: const EdgeInsets.all(18),
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
        children: [
          Positioned(
            right: -16,
            bottom: -18,
            child: Icon(
              Icons.fitness_center_rounded,
              color: Colors.white.withOpacity(0.10),
              size: 120,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  hasDirectVideo
                      ? Icons.play_circle_fill_rounded
                      : Icons.search_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const Spacer(),

              Text(
                hasDirectVideo ? "Demostración externa" : "Buscar técnica",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                hasDirectVideo
                    ? "Abre un recurso externo con la ejecución del ejercicio."
                    : "Busca una demostración técnica externa para este ejercicio.",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.82),
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasDirectVideo
                              ? Icons.open_in_new_rounded
                              : Icons.search_rounded,
                          color: TColor.rojo,
                          size: 15,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          hasDirectVideo
                              ? "Abrir demostración"
                              : "Buscar demostración",
                          style: TextStyle(
                            color: TColor.rojo,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildTitleSection({
    required String title,
    required String value,
    required String type,
    required String difficulty,
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
            difficulty,
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
    required String sets,
    required String restSeconds,
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
        Expanded(
          child: _StatCard(
            icon: Icons.fitness_center_rounded,
            value: sets,
            label: "Series",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.timer_outlined,
            value: restSeconds == "-" ? "-" : "${restSeconds}s",
            label: "Descanso",
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseInfoCard({
    required String muscleGroup,
    required String category,
    required String difficulty,
    required String equipment,
    required String sets,
    required String reps,
    required String restSeconds,
    required String notes,
  }) {
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Datos del ejercicio",
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                icon: Icons.fitness_center_rounded,
                text: muscleGroup,
              ),
              _InfoChip(
                icon: Icons.category_rounded,
                text: category,
              ),
              _InfoChip(
                icon: Icons.speed_rounded,
                text: difficulty,
              ),
              _InfoChip(
                icon: Icons.handyman_rounded,
                text: equipment,
              ),
              _InfoChip(
                icon: Icons.repeat_rounded,
                text: "$sets series",
              ),
              _InfoChip(
                icon: Icons.timer_outlined,
                text: restSeconds == "-" ? "Sin descanso" : "$restSeconds s",
              ),
            ],
          ),
          if (notes.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              "Notas de la rutina",
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              notes,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoutineConfigCard({
    required String type,
    required String value,
    required String sets,
    required String restSeconds,
    required String notes,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Datos asignados en esta rutina",
            style: TextStyle(
              color: TColor.black,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniRoutineBox(
                  icon: Icons.repeat_rounded,
                  value: sets,
                  label: "Series",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniRoutineBox(
                  icon: type == "time"
                      ? Icons.timer_outlined
                      : Icons.fitness_center_rounded,
                  value: value,
                  label: type == "time" ? "Tiempo" : "Reps",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniRoutineBox(
                  icon: Icons.timelapse_rounded,
                  value: restSeconds == "-" ? "-" : "${restSeconds}s",
                  label: "Descanso",
                ),
              ),
            ],
          ),
          if (notes.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              notes,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
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

class _MiniRoutineBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _MiniRoutineBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: TColor.primaryColor1,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: TColor.rojo,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: TColor.rojo,
              fontSize: 11,
              fontWeight: FontWeight.w800,
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