import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/profile_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PersonalInfoView extends StatefulWidget {
  final Map<String, dynamic> profile;

  const PersonalInfoView({
    super.key,
    required this.profile,
  });

  @override
  State<PersonalInfoView> createState() => _PersonalInfoViewState();
}

class _PersonalInfoViewState extends State<PersonalInfoView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController surnameController;
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;

  String selectedGender = "Otro";
  String selectedGoal = "Ganar músculo";

  bool isLoading = false;

  final List<String> genderOptions = [
    "Hombre",
    "Mujer",
    "Otro",
  ];

  final List<String> goalOptions = [
    "Ganar músculo",
    "Definir y tonificar",
    "Perder grasa",
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.profile["name"]?.toString() ?? "",
    );

    surnameController = TextEditingController(
      text: widget.profile["surname"]?.toString() ?? "",
    );

    ageController = TextEditingController(
      text: widget.profile["age"]?.toString() ?? "",
    );

    heightController = TextEditingController(
      text: _cleanNumber(widget.profile["height_cm"]),
    );

    weightController = TextEditingController(
      text: _cleanNumber(widget.profile["weight_kg"]),
    );

    selectedGender = widget.profile["gender"]?.toString() ?? "Otro";
    selectedGoal = widget.profile["goal"]?.toString() ?? goalOptions.first;

    if (!genderOptions.contains(selectedGender)) {
      selectedGender = "Otro";
    }

    if (!goalOptions.contains(selectedGoal)) {
      selectedGoal = goalOptions.first;
    }
  }

  String _cleanNumber(dynamic value) {
    if (value == null) return "";

    final text = value.toString();

    if (text.endsWith(".0")) {
      return text.replaceAll(".0", "");
    }

    return text;
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Revisa los datos introducidos."),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ProfileService.updateProfile(
        name: nameController.text.trim(),
        surname: surnameController.text.trim(),
        gender: selectedGender,
        age: int.tryParse(ageController.text.trim()),
        heightCm: double.tryParse(
          heightController.text.trim().replaceAll(",", "."),
        ),
        weightKg: double.tryParse(
          weightController.text.trim().replaceAll(",", "."),
        ),
        goal: selectedGoal,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Perfil actualizado correctamente"),
          backgroundColor: TColor.rojo,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Campo obligatorio";
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Introduce tu edad";
    }

    final age = int.tryParse(value);

    if (age == null) {
      return "Introduce un número válido";
    }

    if (age < 10 || age > 100) {
      return "Introduce una edad realista";
    }

    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Introduce tu altura";
    }

    final height = double.tryParse(value.replaceAll(",", "."));

    if (height == null) {
      return "Introduce un número válido";
    }

    if (height < 80 || height > 250) {
      return "Introduce una altura realista";
    }

    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Introduce tu peso";
    }

    final weight = double.tryParse(value.replaceAll(",", "."));

    if (weight == null) {
      return "Introduce un número válido";
    }

    if (weight < 20 || weight > 300) {
      return "Introduce un peso realista";
    }

    return null;
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
          onPressed: isLoading ? null : () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColor.negro,
          ),
        ),
        title: Text(
          "Información personal",
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _HeaderCard(
                  title: "Tus datos",
                  subtitle:
                      "Mantén tu información actualizada para que PulseAI pueda personalizar mejor tus rutinas, progreso y recomendaciones.",
                ),

                const SizedBox(height: 22),

                _InputField(
                  controller: nameController,
                  label: "Nombre",
                  icon: Icons.person_outline_rounded,
                  validator: _requiredText,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: surnameController,
                  label: "Apellidos",
                  icon: Icons.badge_outlined,
                  validator: _requiredText,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 14),

                _DropdownField(
                  label: "Género",
                  icon: Icons.wc_rounded,
                  value: selectedGender,
                  items: genderOptions,
                  enabled: !isLoading,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedGender = value;
                    });
                  },
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: ageController,
                  label: "Edad",
                  icon: Icons.cake_outlined,
                  suffixText: "años",
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  validator: _validateAge,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: heightController,
                  label: "Altura",
                  icon: Icons.height_rounded,
                  suffixText: "cm",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: _validateHeight,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 14),

                _InputField(
                  controller: weightController,
                  label: "Peso",
                  icon: Icons.monitor_weight_rounded,
                  suffixText: "kg",
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: _validateWeight,
                  enabled: !isLoading,
                ),

                const SizedBox(height: 14),

                _DropdownField(
                  label: "Objetivo",
                  icon: Icons.flag_outlined,
                  value: selectedGoal,
                  items: goalOptions,
                  enabled: !isLoading,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedGoal = value;
                    });
                  },
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.rojo,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: TColor.rojo.withOpacity(0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      isLoading ? "Guardando..." : "Guardar cambios",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.08),
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
              Icons.manage_accounts_rounded,
              color: TColor.rojo,
              size: 30,
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
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 12,
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
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? suffixText;
  final bool enabled;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.suffixText,
    this.enabled = true,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        color: TColor.negro,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: TColor.gris,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: TColor.rojo,
        ),
        suffixText: suffixText,
        suffixStyle: TextStyle(
          color: TColor.negro,
          fontWeight: FontWeight.w800,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TColor.rojo,
            width: 1.5,
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
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final bool enabled;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: enabled ? onChanged : null,
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: TColor.rojo,
      ),
      dropdownColor: Colors.white,
      style: TextStyle(
        color: TColor.negro,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: TColor.gris,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TColor.rojo,
            width: 1.5,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }
}