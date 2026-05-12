import 'package:afermar3_tf_ipc/funcionalidad/objetivo.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum Genero { hombre, mujer, otro }

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController txtDate = TextEditingController();
  final TextEditingController txtPeso = TextEditingController();
  final TextEditingController txtAltura = TextEditingController();

  Genero _selectedGenero = Genero.otro;

  @override
  void dispose() {
    txtDate.dispose();
    txtPeso.dispose();
    txtAltura.dispose();
    super.dispose();
  }

  String _generoLabel(Genero genero) {
    switch (genero) {
      case Genero.hombre:
        return "Hombre";
      case Genero.mujer:
        return "Mujer";
      case Genero.otro:
        return "Otro";
    }
  }

  Future<void> _selectDate() async {
    final DateTime today = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(today.year - 18, today.month, today.day),
      firstDate: DateTime(1900),
      lastDate: today,
      helpText: "Selecciona tu fecha de nacimiento",
      cancelText: "Cancelar",
      confirmText: "Aceptar",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TColor.rojo,
              onPrimary: Colors.white,
              onSurface: TColor.negro,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      txtDate.text =
          "${pickedDate.year.toString().padLeft(4, '0')}-"
          "${pickedDate.month.toString().padLeft(2, '0')}-"
          "${pickedDate.day.toString().padLeft(2, '0')}";
    }
  }

  void _goNext() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const objetivo(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, revisa los datos introducidos."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: TColor.blanco,
        foregroundColor: TColor.negro,
        centerTitle: false,
        title: const Text(
          "Completa tu perfil",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: media.height * 0.02),

                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: TColor.rojo.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: TColor.rojo,
                    size: 44,
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  "Solo unos datos más",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Esto nos ayudará a personalizar mejor tu experiencia dentro de la app.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 34),

                _ProfileDropdownField(
                  value: _selectedGenero,
                  label: "Género",
                  icon: Icons.wc_rounded,
                  items: Genero.values,
                  itemLabel: _generoLabel,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedGenero = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                _ProfileTextField(
                  controller: txtDate,
                  label: "Fecha de nacimiento",
                  icon: Icons.calendar_month_rounded,
                  readOnly: true,
                  onTap: _selectDate,
                  validator: validateFecha,
                ),

                const SizedBox(height: 18),

                _ProfileTextField(
                  controller: txtPeso,
                  label: "Peso",
                  icon: Icons.monitor_weight_rounded,
                  suffixText: "KG",
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: validatePeso,
                ),

                const SizedBox(height: 18),

                _ProfileTextField(
                  controller: txtAltura,
                  label: "Altura",
                  icon: Icons.height_rounded,
                  suffixText: "CM",
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  validator: validateAltura,
                ),

                const SizedBox(height: 34),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _goNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.rojo,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Siguiente",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? suffixText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _ProfileTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(
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
          fontSize: 13,
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

class _ProfileDropdownField<T> extends StatelessWidget {
  final T value;
  final String label;
  final IconData icon;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const _ProfileDropdownField({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: TColor.rojo,
            width: 1.5,
          ),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(itemLabel(item)),
        );
      }).toList(),
    );
  }
}

String? validateAltura(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Introduce tu altura en cm";
  }

  final height = double.tryParse(value.replaceAll(",", "."));

  if (height == null) {
    return "Introduce un número válido";
  }

  if (height <= 0) {
    return "La altura debe ser positiva";
  }

  if (height < 80 || height > 250) {
    return "Introduce una altura realista";
  }

  return null;
}

String? validatePeso(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Introduce tu peso en kg";
  }

  final weight = double.tryParse(value.replaceAll(",", "."));

  if (weight == null) {
    return "Introduce un número válido";
  }

  if (weight <= 0) {
    return "El peso debe ser positivo";
  }

  if (weight < 20 || weight > 300) {
    return "Introduce un peso realista";
  }

  return null;
}

String? validateFecha(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Introduce tu fecha de nacimiento";
  }

  final birthday = DateTime.tryParse(value);

  if (birthday == null) {
    return "Formato incorrecto";
  }

  final today = DateTime.now();

  if (birthday.isAfter(today)) {
    return "La fecha no puede ser futura";
  }

  final age = today.year -
      birthday.year -
      ((today.month < birthday.month ||
              (today.month == birthday.month && today.day < birthday.day))
          ? 1
          : 0);

  if (age < 10) {
    return "Debes tener al menos 10 años";
  }

  if (age > 100) {
    return "Introduce una fecha realista";
  }

  return null;
}