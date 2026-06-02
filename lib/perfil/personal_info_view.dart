import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/perfil/edit_personal_info_view.dart';
import 'package:afermar3_tf_ipc/services/profile_service.dart';
import 'package:flutter/material.dart';

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
  late Map<String, dynamic> _profile;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _profile = Map<String, dynamic>.from(widget.profile);
  }

  Future<void> _reloadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await ProfileService.getProfile();

      if (!mounted) return;

      setState(() {
        _profile = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonalInfoView(
          profile: _profile,
        ),
      ),
    );

    if (result == true) {
      await _reloadProfile();

      if (!mounted) return;

      Navigator.pop(context, true);
    }
  }

  String _formatNumber(dynamic value) {
    if (value == null) return "--";

    final text = value.toString();

    if (text.endsWith(".0")) {
      return text.replaceAll(".0", "");
    }

    return text;
  }

  String _displayText(dynamic value, String fallback) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty || text == "null") {
      return fallback;
    }

    return text;
  }

  String _fullName() {
    final name = _displayText(_profile["name"], "Usuario");
    final surname = _displayText(_profile["surname"], "");

    if (surname.isEmpty) {
      return name;
    }

    return "$name $surname";
  }

  String _heightText() {
    if (_profile["height_cm"] == null) {
      return "No definida";
    }

    return "${_formatNumber(_profile["height_cm"])} cm";
  }

  String _weightText() {
    if (_profile["weight_kg"] == null) {
      return "No definido";
    }

    return "${_formatNumber(_profile["weight_kg"])} kg";
  }

  String _ageText() {
    if (_profile["age"] == null) {
      return "No definida";
    }

    return "${_formatNumber(_profile["age"])} años";
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString().replaceAll(",", "."));
  }

  String _bmiText() {
    final weight = _toDouble(_profile["weight_kg"]);
    final heightCm = _toDouble(_profile["height_cm"]);

    if (weight == null || heightCm == null || weight <= 0 || heightCm <= 0) {
      return "No disponible";
    }

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);

    return bmi.toStringAsFixed(1).replaceAll(".", ",");
  }

  String _bmiStatusText() {
    final weight = _toDouble(_profile["weight_kg"]);
    final heightCm = _toDouble(_profile["height_cm"]);

    if (weight == null || heightCm == null || weight <= 0 || heightCm <= 0) {
      return "Completa peso y altura para calcularlo.";
    }

    final heightM = heightCm / 100;
    final bmi = weight / (heightM * heightM);

    if (bmi < 18.5) {
      return "Bajo peso";
    }

    if (bmi < 25) {
      return "Peso normal";
    }

    if (bmi < 30) {
      return "Sobrepeso";
    }

    return "Obesidad";
  }

  @override
  Widget build(BuildContext context) {
    final goal = _displayText(_profile["goal"], "Sin objetivo definido");
    final gender = _displayText(_profile["gender"], "No definido");

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
          "Información personal",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _isLoading ? null : _reloadProfile,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: TColor.negro,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: TColor.rojo,
          onRefresh: _reloadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_errorMessage != null) ...[
                  _ErrorCard(
                    message: _errorMessage!,
                  ),
                  const SizedBox(height: 16),
                ],
                _ProfileSummaryCard(
                  fullName: _fullName(),
                  goal: goal,
                  gender: gender,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MiniInfoCard(
                        icon: Icons.height_rounded,
                        label: "Altura",
                        value: _heightText(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniInfoCard(
                        icon: Icons.monitor_weight_rounded,
                        label: "Peso",
                        value: _weightText(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _MiniInfoCard(
                        icon: Icons.cake_outlined,
                        label: "Edad",
                        value: _ageText(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _SectionCard(
                  title: "Datos personales",
                  children: [
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      title: "Nombre",
                      value: _displayText(_profile["name"], "No definido"),
                    ),
                    _InfoRow(
                      icon: Icons.badge_outlined,
                      title: "Apellidos",
                      value: _displayText(_profile["surname"], "No definido"),
                    ),
                    _InfoRow(
                      icon: Icons.wc_rounded,
                      title: "Género",
                      value: gender,
                    ),
                    _InfoRow(
                      icon: Icons.flag_outlined,
                      title: "Objetivo",
                      value: goal,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionCard(
                  title: "Medidas y salud",
                  children: [
                    _InfoRow(
                      icon: Icons.cake_outlined,
                      title: "Edad",
                      value: _ageText(),
                    ),
                    _InfoRow(
                      icon: Icons.height_rounded,
                      title: "Altura",
                      value: _heightText(),
                    ),
                    _InfoRow(
                      icon: Icons.monitor_weight_rounded,
                      title: "Peso",
                      value: _weightText(),
                    ),
                    _InfoRow(
                      icon: Icons.favorite_outline_rounded,
                      title: "IMC",
                      value: "${_bmiText()} · ${_bmiStatusText()}",
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _openEditProfile,
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text(
                      "Editar información",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.rojo,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: TColor.rojo.withOpacity(0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Estos datos se usan para personalizar rutinas, objetivos, progreso y recomendaciones del Coach IA.",
                  textAlign: TextAlign.center,
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
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  final String fullName;
  final String goal;
  final String gender;

  const _ProfileSummaryCard({
    required this.fullName,
    required this.goal,
    required this.gender,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.rojo.withOpacity(0.13),
            TColor.rojo.withOpacity(0.04),
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
            width: 66,
            height: 66,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  TColor.rojo.withOpacity(0.9),
                  TColor.rojo,
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Image.asset(
                "assets/img/foto.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Objetivo: $goal",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Género: $gender",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 12,
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

class _MiniInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: TColor.rojo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TColor.rojo.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: TColor.blanco,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.blanco,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.blanco.withOpacity(0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 12,
        bottom: isLast ? 12 : 13,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(
                  color: Colors.grey.shade100,
                ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: TColor.rojo,
              size: 20,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: TColor.gris,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TColor.negro,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}