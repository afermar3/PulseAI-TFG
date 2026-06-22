import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/perfil/tutorial_video_player.dart';
import 'package:flutter/material.dart';

class TutorialDetailView extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;
  final List<String> tips;
  final String? videoPath;

  const TutorialDetailView({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.steps,
    required this.tips,
    this.videoPath,
  });

  bool get hasVideo => videoPath != null && videoPath!.trim().isNotEmpty;

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
              icon,
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
                  title,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    height: 1.35,
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

  Widget _buildVideoPlaceholder() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.video_library_outlined,
              color: TColor.rojo,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasVideo ? "Vídeo disponible" : "Vídeo no añadido todavía",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasVideo
                      ? "Este tutorial tiene un vídeo asociado."
                      : "La pantalla está preparada para incluir un vídeo corto cuando esté grabado.",
                  style: TextStyle(
                    color: TColor.gris,
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

  Widget _buildStepsSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
      decoration: BoxDecoration(
        color: TColor.blanco,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pasos",
            style: TextStyle(
              color: TColor.negro,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: steps.length,
            itemBuilder: (context, index) {
              return _TutorialStepRow(
                number: index + 1,
                text: steps[index],
                isLast: index == steps.length - 1,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
    if (tips.isEmpty) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.07),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: TColor.rojo,
                size: 23,
              ),
              const SizedBox(width: 8),
              Text(
                "Consejos",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: TColor.rojo,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: TColor.gris,
                        fontSize: 12.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFutureVideoNote() {
    if (hasVideo) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: TColor.gris,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Cuando se añada un vídeo a este tutorial, aparecerá integrado en esta pantalla.",
              style: TextStyle(
                color: TColor.gris,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
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
          "Tutorial",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
              child: Column(
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 18),
                  hasVideo
                      ? TutorialVideoPlayer(
                          videoPath: videoPath!,
                        )
                      : _buildVideoPlaceholder(),
                  const SizedBox(height: 18),
                  _buildStepsSection(),
                  const SizedBox(height: 18),
                  _buildTipsSection(),
                  const SizedBox(height: 18),
                  _buildFutureVideoNote(),
                ],
              ),
            ),
            Positioned(
              left: 22,
              right: 22,
              bottom: 18,
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.rojo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Entendido",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorialStepRow extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;

  const _TutorialStepRow({
    required this.number,
    required this.text,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final numberText = number.toString().padLeft(2, "0");

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
                numberText,
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
                height: 42,
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
              color: TColor.blanco,
              borderRadius: BorderRadius.circular(20),
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
            child: Text(
              text,
              style: TextStyle(
                color: TColor.negro,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
