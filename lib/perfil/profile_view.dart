import 'package:afermar3_tf_ipc/info_user/login_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/perfil/achievements_view.dart';
import 'package:afermar3_tf_ipc/perfil/app_tutorials_view.dart';
import 'package:afermar3_tf_ipc/perfil/contact_view.dart';
import 'package:afermar3_tf_ipc/perfil/personal_info_view.dart';
import 'package:afermar3_tf_ipc/perfil/privacy_policy_view.dart';
import 'package:afermar3_tf_ipc/perfil/profile_activity_history_view.dart';
import 'package:afermar3_tf_ipc/perfil/profile_progress_view.dart';
import 'package:afermar3_tf_ipc/perfil/profile_settings_view.dart';
import 'package:afermar3_tf_ipc/perfil/edit_personal_info_view.dart';
import 'package:afermar3_tf_ipc/services/auth_service.dart';
import 'package:afermar3_tf_ipc/services/profile_service.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:afermar3_tf_ipc/services/api_client.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilWidget();
}

class _PerfilWidget extends State<Perfil> {
  Map<String, dynamic>? profile;
  bool isLoadingProfile = true;

  final List<Map<String, dynamic>> accountArr = [
    {
      "icon": Icons.person_outline_rounded,
      "nombre": "Información personal",
      "tag": "1",
    },
    {
      "icon": Icons.emoji_events_outlined,
      "nombre": "Logros",
      "tag": "2",
    },
    {
      "icon": Icons.history_rounded,
      "nombre": "Historial de actividad",
      "tag": "3",
    },
    {
      "icon": Icons.show_chart_rounded,
      "nombre": "Progreso",
      "tag": "4",
    },
  ];

  final List<Map<String, dynamic>> helpArr = [
    {
      "icon": Icons.help_outline_rounded,
      "nombre": "Ayuda y tutoriales",
      "tag": "8",
    },
  ];

  final List<Map<String, dynamic>> otherArr = [
    {
      "icon": Icons.mail_outline_rounded,
      "nombre": "Contáctanos",
      "tag": "5",
    },
    {
      "icon": Icons.privacy_tip_outlined,
      "nombre": "Política de privacidad",
      "tag": "6",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ProfileService.getProfile();

      if (!mounted) return;

      setState(() {
        profile = data;
        isLoadingProfile = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _openPersonalInfo() async {
    if (profile == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PersonalInfoView(
          profile: profile!,
        ),
      ),
    );

    if (result == true) {
      _loadProfile();
    }
  }

  Future<void> _openEditPersonalInfo() async {
    if (profile == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPersonalInfoView(
          profile: profile!,
        ),
      ),
    );

    if (result == true) {
      _loadProfile();
    }
  }

  void _onAccountOptionPressed(String tag) {
    switch (tag) {
      case "1":
        _openPersonalInfo();
        break;

      case "2":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AchievementsView(),
          ),
        );
        break;

      case "3":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileActivityHistoryView(),
          ),
        );
        break;

      case "4":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileProgressView(),
          ),
        );
        break;
    }
  }

  void _onHelpOptionPressed(String tag) {
    switch (tag) {
      case "8":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AppTutorialsView(),
          ),
        );
        break;
    }
  }

  void _onOtherOptionPressed(String tag) {
    switch (tag) {
      case "5":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ContactView(),
          ),
        );
        break;

      case "6":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PrivacyPolicyView(),
          ),
        );
        break;
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

  String _defaultAvatarByGender(dynamic gender) {
    final normalizedGender = gender?.toString().trim().toLowerCase() ?? "";

    if (normalizedGender == "hombre" ||
        normalizedGender == "masculino" ||
        normalizedGender == "male") {
      return "assets/img/avatar_hombre.png";
    }

    if (normalizedGender == "mujer" ||
        normalizedGender == "femenino" ||
        normalizedGender == "female") {
      return "assets/img/avatar_mujer.png";
    }

    return "assets/img/avatar_otro.png";
  }

  String? _profileImageUrl() {
    final path = profile?["profile_image_path"]?.toString();

    if (path == null || path.trim().isEmpty || path == "null") {
      return null;
    }

    if (path.startsWith("http")) {
      return path;
    }

    return "${ApiClient.baseUrl}$path";
  }

  Future<void> _pickAndUploadProfileImage() async {
    try {
      final picker = ImagePicker();

      final pickedImage = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 900,
      );

      if (pickedImage == null) return;

      setState(() {
        isLoadingProfile = true;
      });

      final updatedProfile = await ProfileService.uploadProfileImage(
        image: pickedImage,
      );

      if (!mounted) return;

      setState(() {
        profile = updatedProfile;
        isLoadingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Imagen de perfil actualizada correctamente"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = profile?["height_cm"] == null
        ? "--"
        : "${_formatNumber(profile!["height_cm"])} cm";

    final weight = profile?["weight_kg"] == null
        ? "--"
        : "${_formatNumber(profile!["weight_kg"])} kg";

    final age = profile?["age"] == null ? "--" : _formatNumber(profile!["age"]);

    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        title: Text(
          "Perfil",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingsView(),
                  ),
                );
              },
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.negro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoadingProfile
            ? Center(
                child: CircularProgressIndicator(
                  color: TColor.rojo,
                ),
              )
            : RefreshIndicator(
                color: TColor.rojo,
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 115),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ProfileStatCard(
                              title: height,
                              subtitle: "Altura",
                              icon: Icons.height_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ProfileStatCard(
                              title: weight,
                              subtitle: "Peso",
                              icon: Icons.monitor_weight_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ProfileStatCard(
                              title: age,
                              subtitle: "Edad",
                              icon: Icons.cake_outlined,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      _buildSectionCard(
                        title: "Cuenta",
                        items: accountArr,
                        onItemPressed: _onAccountOptionPressed,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: "Ayuda",
                        items: helpArr,
                        onItemPressed: _onHelpOptionPressed,
                      ),
                      const SizedBox(height: 20),
                      _buildSectionCard(
                        title: "Otros",
                        items: otherArr,
                        onItemPressed: _onOtherOptionPressed,
                      ),
                      const SizedBox(height: 20),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final name = _displayText(profile?["name"], "Usuario");
    final surname = _displayText(profile?["surname"], "");
    final goal = _displayText(profile?["goal"], "Sin objetivo definido");
    final gender = _displayText(profile?["gender"], "Sin género definido");

    final fullName = surname.isEmpty ? name : "$name $surname";

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
          GestureDetector(
            onTap: _pickAndUploadProfileImage,
            child: Stack(
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
                    child: _profileImageUrl() != null
                        ? Image.network(
                            _profileImageUrl()!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                _defaultAvatarByGender(profile?["gender"]),
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.asset(
                            _defaultAvatarByGender(profile?["gender"]),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: TColor.rojo,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TColor.blanco,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
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
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Objetivo: $goal",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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
          SizedBox(
            width: 82,
            height: 34,
            child: botonredondo(
              title: "Editar",
              type: RoundButtonType.bgGradient,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              onPressed: _openEditPersonalInfo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Map<String, dynamic>> items,
    required Function(String tag) onItemPressed,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColor.negro,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (context, index) {
              return Divider(
                color: Colors.grey.shade100,
                height: 1,
              );
            },
            itemBuilder: (context, index) {
              final item = items[index];

              return SettingRow(
                icon: item["icon"] as IconData,
                title: item["nombre"].toString(),
                onPressed: () {
                  onItemPressed(item["tag"].toString());
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await AuthService.logout();

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const Login(),
          ),
          (route) => false,
        );
      },
      child: Container(
        height: 54,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TColor.rojo.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          "Cerrar sesión",
          style: TextStyle(
            color: TColor.rojo,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ProfileStatCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
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
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.blanco,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
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

class SettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;

  const SettingRow({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
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
}
