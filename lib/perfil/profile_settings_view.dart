import 'package:afermar3_tf_ipc/Home/notif.dart';
import 'package:afermar3_tf_ipc/info_user/login_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/perfil/contact_view.dart';
import 'package:afermar3_tf_ipc/perfil/privacy_policy_view.dart';
import 'package:afermar3_tf_ipc/services/auth_service.dart';
import 'package:flutter/material.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key});

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView> {
  bool _coachContextEnabled = true;
  bool _showHealthTips = true;
  bool _internalNotificationsEnabled = true;

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationView(),
      ),
    );
  }

  void _openPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PrivacyPolicyView(),
      ),
    );
  }

  void _openContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ContactView(),
      ),
    );
  }

  void _showTutorialInfo() {
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
                  Icons.play_circle_outline_rounded,
                  color: TColor.rojo,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Tutorial de la app",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Aquí más adelante podrás volver a ver el tutorial inicial de PulseAI: perfil, rutinas con IA, entrenamientos, sueño y fotos de progreso.",
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

  void _showAiPreferencesInfo() {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: TColor.rojo.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    color: TColor.rojo,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  "Preferencias IA",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _InfoText(
                text:
                    "El Coach IA utiliza tu perfil, objetivo, rutina activa y datos recientes para darte respuestas más personalizadas.",
              ),
              const SizedBox(height: 10),
              _InfoText(
                text:
                    "En una versión futura, estas preferencias podrían guardarse en backend para ajustar el estilo de las recomendaciones.",
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

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cerrar sesión"),
          content: const Text(
            "¿Seguro que quieres cerrar sesión en PulseAI?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Cerrar sesión"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
      (route) => false,
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
              Icons.settings_rounded,
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
                  "Ajustes",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Configura preferencias, notificaciones y accesos de tu cuenta.",
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

  Widget _buildAiSection() {
    return _SettingsSection(
      title: "Coach IA",
      children: [
        _SwitchSettingRow(
          icon: Icons.psychology_alt_outlined,
          title: "Usar contexto personal",
          subtitle: "Permite que el Coach tenga en cuenta tu perfil y progreso.",
          value: _coachContextEnabled,
          onChanged: (value) {
            setState(() {
              _coachContextEnabled = value;
            });
          },
        ),
        _SwitchSettingRow(
          icon: Icons.health_and_safety_outlined,
          title: "Consejos saludables",
          subtitle: "Mostrar recomendaciones generales de hábitos saludables.",
          value: _showHealthTips,
          onChanged: (value) {
            setState(() {
              _showHealthTips = value;
            });
          },
        ),
        _NavigationSettingRow(
          icon: Icons.info_outline_rounded,
          title: "Información sobre preferencias IA",
          subtitle: "Cómo se usan tus datos dentro de PulseAI.",
          onTap: _showAiPreferencesInfo,
        ),
      ],
    );
  }

  Widget _buildAppSection() {
    return _SettingsSection(
      title: "Aplicación",
      children: [
        _SwitchSettingRow(
          icon: Icons.notifications_active_outlined,
          title: "Notificaciones internas",
          subtitle: "Mostrar avisos de entreno, sueño y progreso dentro de la app.",
          value: _internalNotificationsEnabled,
          onChanged: (value) {
            setState(() {
              _internalNotificationsEnabled = value;
            });
          },
        ),
        _NavigationSettingRow(
          icon: Icons.notifications_none_rounded,
          title: "Ver notificaciones",
          subtitle: "Consulta tus avisos recientes.",
          onTap: _openNotifications,
        ),
        _NavigationSettingRow(
          icon: Icons.play_circle_outline_rounded,
          title: "Tutorial de la app",
          subtitle: "Aprende a usar las funciones principales.",
          onTap: _showTutorialInfo,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _SettingsSection(
      title: "Cuenta y soporte",
      children: [
        _NavigationSettingRow(
          icon: Icons.privacy_tip_outlined,
          title: "Política de privacidad",
          subtitle: "Consulta información legal y de privacidad.",
          onTap: _openPrivacyPolicy,
        ),
        _NavigationSettingRow(
          icon: Icons.mail_outline_rounded,
          title: "Contáctanos",
          subtitle: "Envía dudas o sugerencias.",
          onTap: _openContact,
        ),
        _NavigationSettingRow(
          icon: Icons.logout_rounded,
          title: "Cerrar sesión",
          subtitle: "Salir de tu cuenta actual.",
          color: Colors.redAccent,
          onTap: _confirmLogout,
        ),
      ],
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
          "Ajustes",
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
              _buildAiSection(),
              const SizedBox(height: 18),
              _buildAppSection(),
              const SizedBox(height: 18),
              _buildAccountSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 6),
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

class _NavigationSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? color;

  const _NavigationSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? TColor.rojo;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: effectiveColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                color: effectiveColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color ?? TColor.negro,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 11,
                      height: 1.25,
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
}

class _SwitchSettingRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchSettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: TColor.rojo,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 11,
                    height: 1.25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: TColor.rojo,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _InfoText extends StatelessWidget {
  final String text;

  const _InfoText({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: TColor.gris,
        fontSize: 13,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}