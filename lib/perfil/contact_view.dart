import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class ContactView extends StatefulWidget {
  const ContactView({super.key});

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedReason = "Soporte técnico";

  final List<String> _reasons = [
    "Soporte técnico",
    "Problema con la cuenta",
    "Sugerencia",
    "Entrenamientos",
    "Nutrición",
    "Otro",
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: TColor.rojo,
          content: const Text(
            "Mensaje enviado correctamente.",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );

      _subjectController.clear();
      _messageController.clear();

      setState(() {
        _selectedReason = "Soporte técnico";
      });
    }
  }

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
          "Contáctanos",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 26),
              Text(
                "Envíanos un mensaje",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Cuéntanos qué necesitas y te ayudaremos lo antes posible.",
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildReasonDropdown(),
                    const SizedBox(height: 16),
                    _ContactTextField(
                      controller: _subjectController,
                      label: "Asunto",
                      hintText: "Ejemplo: problema al guardar mi progreso",
                      icon: Icons.subject_rounded,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Introduce un asunto";
                        }

                        if (value.trim().length < 4) {
                          return "El asunto es demasiado corto";
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _ContactTextField(
                      controller: _messageController,
                      label: "Mensaje",
                      hintText: "Escribe aquí tu consulta...",
                      icon: Icons.message_outlined,
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Introduce un mensaje";
                        }

                        if (value.trim().length < 10) {
                          return "El mensaje debe tener al menos 10 caracteres";
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 26),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.rojo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Enviar mensaje",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _buildContactInfoCard(),
            ],
          ),
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
          color: TColor.primerColor2.withOpacity(0.14),
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
              Icons.support_agent_rounded,
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
                  "¿Necesitas ayuda?",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Estamos aquí para ayudarte con cualquier duda sobre la app.",
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

  Widget _buildReasonDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedReason,
      dropdownColor: Colors.white,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: TColor.rojo,
      ),
      decoration: InputDecoration(
        labelText: "Motivo",
        labelStyle: TextStyle(
          color: TColor.gris,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          Icons.category_outlined,
          color: TColor.rojo,
        ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TColor.rojo,
            width: 1.4,
          ),
        ),
      ),
      items: _reasons.map((reason) {
        return DropdownMenuItem<String>(
          value: reason,
          child: Text(
            reason,
            style: TextStyle(
              color: TColor.negro,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedReason = value;
          });
        }
      },
    );
  }

  Widget _buildContactInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(22),
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
          _ContactInfoRow(
            icon: Icons.email_outlined,
            title: "Correo",
            value: "soporte@pulseai.es",
          ),
          Divider(
            height: 24,
            color: Colors.grey.shade100,
          ),
          _ContactInfoRow(
            icon: Icons.schedule_rounded,
            title: "Horario",
            value: "Lunes a viernes, 9:00 - 18:00",
          ),
        ],
      ),
    );
  }
}

class _ContactTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ContactTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final bool isMultiline = maxLines > 1;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: isMultiline,
        labelStyle: TextStyle(
          color: TColor.gris,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: TextStyle(
          color: TColor.gris.withOpacity(0.65),
          fontSize: 13,
        ),
        prefixIcon: isMultiline
            ? Padding(
                padding: const EdgeInsets.only(bottom: 82),
                child: Icon(
                  icon,
                  color: TColor.rojo,
                ),
              )
            : Icon(
                icon,
                color: TColor.rojo,
              ),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TColor.rojo,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ContactInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: TColor.rojo.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: TColor.rojo,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
