import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class AppTutorialsView extends StatelessWidget {
  const AppTutorialsView({super.key});

  void _openTutorialDetail(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: TColor.rojo.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: TColor.rojo,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.rojo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Entendido",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTutorialCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String description,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        _openTutorialDetail(
          context,
          title: title,
          description: description,
          icon: icon,
        );
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
                icon,
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
                    title,
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
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                  "Aprende a usar las funciones principales de PulseAI.",
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
              _buildTutorialCard(
                context: context,
                icon: Icons.person_outline_rounded,
                title: "Primeros pasos",
                subtitle: "Configura tu perfil para personalizar la app.",
                description:
                    "Completa tus datos personales, objetivo, peso y altura. PulseAI utiliza esta información para adaptar tus rutinas, progreso y respuestas del Coach IA.",
              ),
              const SizedBox(height: 12),
              _buildTutorialCard(
                context: context,
                icon: Icons.smart_toy_outlined,
                title: "Coach IA",
                subtitle: "Pregunta, genera rutinas y aplica cambios.",
                description:
                    "El Coach IA puede ayudarte con rutinas, recomendaciones y cambios en objetivos como sueño o entrenamientos. Cuando una acción modifica datos, la app te pedirá confirmación.",
              ),
              const SizedBox(height: 12),
              _buildTutorialCard(
                context: context,
                icon: Icons.fitness_center_rounded,
                title: "Entrenamientos",
                subtitle: "Gestiona agenda, rutina activa y sesiones.",
                description:
                    "Desde actividad puedes consultar entrenamientos programados, completar sesiones y revisar tu rutina activa. El Home muestra un resumen semanal y mensual.",
              ),
              const SizedBox(height: 12),
              _buildTutorialCard(
                context: context,
                icon: Icons.bedtime_rounded,
                title: "Sueño",
                subtitle: "Registra descanso y objetivos de sueño.",
                description:
                    "Puedes iniciar y finalizar sesiones de sueño, configurar objetivos diferentes para todos los días, entre semana o fines de semana, y revisar tu progreso.",
              ),
              const SizedBox(height: 12),
              _buildTutorialCard(
                context: context,
                icon: Icons.photo_camera_rounded,
                title: "Fotos de progreso",
                subtitle: "Sube fotos y compara tu evolución.",
                description:
                    "Registra fotos con tipo, peso y notas. Cuando tengas al menos dos fotos, podrás compararlas para ver tu evolución visual.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}