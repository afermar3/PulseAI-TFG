import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyView extends StatelessWidget {
  final bool showAcceptButton;
  final VoidCallback? onAccept;

  const PrivacyPolicyView({
    super.key,
    this.showAcceptButton = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        centerTitle: true,
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
          "Términos y privacidad",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  22,
                  16,
                  22,
                  showAcceptButton ? 20 : 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 24),
                    _buildLastUpdate(),
                    const SizedBox(height: 18),
                    const _PolicySection(
                      number: "1",
                      title: "Aceptación de los términos",
                      text:
                          "Al crear una cuenta, acceder o utilizar GymFit, aceptas cumplir estos términos y condiciones de uso. Si no estás de acuerdo con ellos, no deberías utilizar la aplicación.",
                    ),
                    const _PolicySection(
                      number: "2",
                      title: "Uso de la aplicación",
                      text:
                          "GymFit está pensada para un uso personal relacionado con el seguimiento de hábitos, entrenamientos, progreso físico y objetivos saludables. No debes utilizar la aplicación con fines ilegales, comerciales no autorizados o de forma que pueda afectar al funcionamiento del servicio.",
                    ),
                    const _PolicySection(
                      number: "3",
                      title: "Cuenta de usuario",
                      text:
                          "El usuario es responsable de la información que introduce en la aplicación y de mantener la confidencialidad de sus datos de acceso. Es recomendable utilizar información veraz para que las recomendaciones, estadísticas y funcionalidades personalizadas sean útiles.",
                    ),
                    const _PolicySection(
                      number: "4",
                      title: "Datos personales y de progreso",
                      text:
                          "La aplicación puede almacenar datos como nombre, correo electrónico, edad, altura, peso, objetivo físico, rutinas, actividad, historial, fotos de progreso y preferencias. Estos datos se utilizarán para ofrecer una experiencia personalizada y mejorar el seguimiento del usuario.",
                    ),
                    const _PolicySection(
                      number: "5",
                      title: "Coach IA y recomendaciones",
                      text:
                          "GymFit podrá incluir funcionalidades de inteligencia artificial para generar rutinas, sugerencias de dieta, análisis de progreso o recomendaciones personalizadas. Estas recomendaciones son orientativas y no sustituyen el consejo de un médico, nutricionista, fisioterapeuta o entrenador profesional.",
                    ),
                    const _PolicySection(
                      number: "6",
                      title: "Cambios en dieta, rutinas u objetivos",
                      text:
                          "Si el usuario solicita al Coach IA modificar una dieta, rutina, objetivo o dato de la aplicación, la app podrá mostrar una propuesta de cambio antes de aplicarla. Los cambios importantes deberían requerir confirmación del usuario.",
                    ),
                    const _PolicySection(
                      number: "7",
                      title: "Fotos de progreso",
                      text:
                          "Las fotos de progreso se utilizarán únicamente para mostrar la evolución física del usuario dentro de la aplicación. El usuario es responsable del contenido que sube y deberá evitar imágenes inapropiadas o de terceros sin permiso.",
                    ),
                    const _PolicySection(
                      number: "8",
                      title: "Propiedad intelectual",
                      text:
                          "Todos los elementos de la aplicación, incluyendo diseño, código, textos, imágenes, funcionalidades y marca, pertenecen a GymFit o a sus respectivos titulares. No está permitido copiar, distribuir, modificar o explotar el contenido de la aplicación sin autorización.",
                    ),
                    const _PolicySection(
                      number: "9",
                      title: "Limitación de responsabilidad",
                      text:
                          "GymFit se ofrece como herramienta de apoyo y seguimiento. No garantizamos que la aplicación esté libre de errores o interrupciones. El usuario acepta que cualquier entrenamiento, dieta o recomendación debe adaptarse a su estado físico real y realizarse con responsabilidad.",
                    ),
                    const _PolicySection(
                      number: "10",
                      title: "Modificaciones",
                      text:
                          "Podemos actualizar estos términos en futuras versiones de la aplicación para adaptarlos a nuevas funcionalidades, cambios técnicos o requisitos legales. Si continúas usando GymFit tras una actualización, se entenderá que aceptas los nuevos términos.",
                    ),
                    const _PolicySection(
                      number: "11",
                      title: "Cancelación o suspensión",
                      text:
                          "Podremos suspender o limitar el acceso a la aplicación si se detecta un uso indebido, incumplimiento de estos términos o cualquier comportamiento que afecte negativamente a la seguridad o funcionamiento del servicio.",
                    ),
                    const _PolicySection(
                      number: "12",
                      title: "Ley aplicable",
                      text:
                          "Estos términos se regirán e interpretarán de acuerdo con la legislación española, sin perjuicio de los derechos que puedan corresponder al usuario según la normativa aplicable.",
                    ),
                    const _PolicySection(
                      number: "13",
                      title: "Contacto",
                      text:
                          "Si tienes preguntas sobre estos términos, privacidad o uso de la aplicación, puedes contactar con nosotros en soporte@pulseai.es",
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "PulseAI podrá actualizar estos términos y condiciones para adaptarlos a nuevas funcionalidades, cambios técnicos o requisitos legales. Te recomendamos revisarlos periódicamente.",
                      style: TextStyle(
                        color: TColor.gris,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (showAcceptButton) _buildAcceptButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primerColor2.withOpacity(0.18),
            TColor.primerColor1.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: TColor.primerColor1.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              color: TColor.rojo,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tu privacidad importa",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Consulta cómo se usan tus datos y qué condiciones aceptas al utilizar PulseAI.",
                  style: TextStyle(
                    color: TColor.gris,
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

  Widget _buildLastUpdate() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update_rounded,
            color: TColor.rojo,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Última actualización: 14 de mayo de 2026",
              style: TextStyle(
                color: TColor.rojo,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: BoxDecoration(
        color: TColor.blanco,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (onAccept != null) {
              onAccept!();
            } else {
              Navigator.pop(context, true);
            }
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
            "Aceptar y continuar",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String number;
  final String title;
  final String text;

  const _PolicySection({
    required this.number,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number,
              style: TextStyle(
                color: TColor.rojo,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    height: 1.45,
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
}
