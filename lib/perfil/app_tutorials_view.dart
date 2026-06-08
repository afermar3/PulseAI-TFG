import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/perfil/tutorial_detail_view.dart';
import 'package:flutter/material.dart';

class AppTutorialsView extends StatelessWidget {
  const AppTutorialsView({super.key});

  List<_TutorialItem> get tutorials {
    return const [
      _TutorialItem(
        title: "Primeros pasos",
        subtitle: "Conoce la estructura principal de PulseAI.",
        description:
            "Este tutorial explica cómo moverte por la app y qué función tiene cada apartado principal.",
        icon: Icons.explore_outlined,
        steps: [
          "Abre PulseAI e inicia sesión con tu cuenta.",
          "Revisa el Home para consultar un resumen de tu actividad, sueño y progreso.",
          "Entra en Entrenamientos para consultar rutinas, agenda y ejercicios.",
          "Accede al perfil para revisar tus datos, logros, historial, progreso y ayuda.",
          "Utiliza el Coach IA para resolver dudas o recibir recomendaciones personalizadas.",
        ],
        tips: [
          "Mantén tu perfil actualizado para que las recomendaciones sean más precisas.",
          "Consulta el Home con frecuencia para ver tu evolución general.",
        ],
      ),
      _TutorialItem(
        title: "Crear rutina con IA",
        subtitle: "Genera una rutina personalizada usando el módulo de IA.",
        description:
            "Aprende a crear una rutina de entrenamiento con ayuda de la inteligencia artificial.",
        icon: Icons.auto_awesome_rounded,
        steps: [
          "Entra en la pantalla de Entrenamientos.",
          "Pulsa el botón Rutina IA.",
          "Revisa la propuesta generada por el sistema.",
          "Comprueba los días, ejercicios, series, repeticiones y descansos.",
          "Guarda la rutina si se adapta a tu objetivo.",
          "Actívala desde tus rutinas guardadas para empezar a utilizarla.",
        ],
        tips: [
          "La rutina se genera usando ejercicios reales disponibles en la aplicación.",
          "Si la primera propuesta no te convence, puedes volver a generar otra rutina.",
        ],
      ),
      _TutorialItem(
        title: "Registrar entrenamiento",
        subtitle: "Completa ejercicios y guarda tu progreso.",
        description:
            "Este tutorial muestra cómo registrar una sesión de entrenamiento desde una rutina activa.",
        icon: Icons.fitness_center_rounded,
        steps: [
          "Entra en Entrenamientos.",
          "Consulta el entrenamiento de hoy o los días de tu rutina activa.",
          "Abre el día de entrenamiento que quieras realizar.",
          "Marca los ejercicios que vas completando.",
          "Revisa el progreso de la sesión.",
          "Finaliza el entrenamiento para guardarlo en tu historial.",
        ],
        tips: [
          "Completar entrenamientos ayuda a calcular estadísticas y rachas.",
          "Puedes consultar sesiones anteriores desde el historial de entrenamientos.",
        ],
      ),
      _TutorialItem(
        title: "Configurar sueño",
        subtitle: "Define objetivos de descanso y registra sesiones.",
        description:
            "Aprende a configurar objetivos de sueño y registrar tu descanso dentro de PulseAI.",
        icon: Icons.bedtime_rounded,
        steps: [
          "Entra en el apartado de Sueño.",
          "Configura tu objetivo de descanso.",
          "Selecciona los días en los que quieres aplicar el objetivo.",
          "Inicia una sesión de sueño cuando vayas a dormir.",
          "Finaliza la sesión al despertarte.",
          "Revisa el resumen y la evolución de tu descanso.",
        ],
        tips: [
          "Puedes diferenciar objetivos para días laborables y fines de semana.",
          "Registrar el sueño ayuda a interpretar mejor tu rendimiento y recuperación.",
        ],
      ),
      _TutorialItem(
        title: "Fotos de progreso",
        subtitle: "Registra imágenes y compara tu evolución.",
        description:
            "Este tutorial explica cómo añadir fotos de progreso y utilizarlas para revisar cambios físicos.",
        icon: Icons.photo_camera_rounded,
        steps: [
          "Entra en la pantalla de Fotos de progreso.",
          "Pulsa el botón para añadir una nueva foto.",
          "Selecciona o toma una imagen.",
          "Indica el tipo de foto, peso o notas si lo necesitas.",
          "Guarda el registro.",
          "Cuando tengas varias fotos, utiliza la comparación para revisar tu evolución.",
        ],
        tips: [
          "Intenta tomar las fotos con una iluminación y postura similares.",
          "No es necesario subir fotos cada día; es mejor hacerlo de forma periódica.",
        ],
      ),
      _TutorialItem(
        title: "Usar el Coach IA",
        subtitle: "Haz preguntas y confirma acciones inteligentes.",
        description:
            "Aprende a utilizar el Coach IA para recibir recomendaciones personalizadas dentro de PulseAI.",
        icon: Icons.smart_toy_outlined,
        steps: [
          "Entra en la pantalla del Coach IA.",
          "Escribe una pregunta relacionada con entrenamiento, rutina, sueño o progreso.",
          "Revisa la respuesta generada por el asistente.",
          "Si la IA propone modificar algún dato importante, confirma la acción antes de aplicarla.",
          "Comprueba que los cambios se han reflejado correctamente en la app.",
        ],
        tips: [
          "El Coach IA utiliza información de tu perfil y datos registrados para responder mejor.",
          "Las acciones importantes requieren confirmación para evitar cambios no deseados.",
        ],
      ),
    ];
  }

  void _openTutorial(BuildContext context, _TutorialItem tutorial) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialDetailView(
          title: tutorial.title,
          description: tutorial.description,
          icon: tutorial.icon,
          steps: tutorial.steps,
          tips: tutorial.tips,
          videoPath: tutorial.videoPath,
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
              Icons.help_outline_rounded,
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
                  "Ayuda y tutoriales",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Aprende a utilizar las funciones principales de PulseAI paso a paso.",
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

  Widget _buildTutorialCard({
    required BuildContext context,
    required _TutorialItem tutorial,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        _openTutorial(context, tutorial);
      },
      child: Container(
        padding: const EdgeInsets.all(15),
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
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                tutorial.icon,
                color: TColor.rojo,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutorial.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tutorial.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        tutorial.videoPath == null
                            ? Icons.checklist_rounded
                            : Icons.play_circle_outline_rounded,
                        color: TColor.rojo,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tutorial.videoPath == null
                            ? "Guía paso a paso"
                            : "Vídeo y pasos",
                        style: TextStyle(
                          color: TColor.rojo,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gris,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: TColor.rojo,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Más adelante se podrán añadir vídeos cortos a estos tutoriales sin cambiar la estructura de la pantalla.",
              style: TextStyle(
                color: TColor.gris,
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

  @override
  Widget build(BuildContext context) {
    final tutorialList = tutorials;

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
          "Ayuda",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 22),
              ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: tutorialList.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemBuilder: (context, index) {
                  final tutorial = tutorialList[index];

                  return _buildTutorialCard(
                    context: context,
                    tutorial: tutorial,
                  );
                },
              ),
              const SizedBox(height: 18),
              _buildFooterNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<String> steps;
  final List<String> tips;
  final String? videoPath;

  const _TutorialItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.steps,
    required this.tips,
    this.videoPath,
  });
}