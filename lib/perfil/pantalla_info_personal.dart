import 'package:afermar3_tf_ipc/info_user/login_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:flutter/material.dart';
import 'package:afermar3_tf_ipc/perfil/contact_view.dart';
import 'package:afermar3_tf_ipc/perfil/privacy_policy_view.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _PerfilWidget();
}

class _PerfilWidget extends State<Perfil> {
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
    {
      "icon": Icons.settings_outlined,
      "nombre": "Ajustes",
      "tag": "7",
    },
  ];

  void _onAccountOptionPressed(String tag) {
    switch (tag) {
      case "1":
        // TODO: Navegar a pantalla de información personal
        break;
      case "2":
        // TODO: Navegar a pantalla de logros
        break;
      case "3":
        // TODO: Navegar a historial de actividad
        break;
      case "4":
        // TODO: Navegar a progreso
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
      case "7":
        // TODO: Navegar a ajustes
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.negro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 22),
              const Row(
                children: [
                  Expanded(
                    child: ProfileStatCard(
                      title: "170 cm",
                      subtitle: "Altura",
                      icon: Icons.height_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ProfileStatCard(
                      title: "80 kg",
                      subtitle: "Peso",
                      icon: Icons.monitor_weight_rounded,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ProfileStatCard(
                      title: "22",
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
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(18),
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
            width: 66,
            height: 66,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: TColor.primerG),
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
                  "Usuario",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Objetivo: Perder peso",
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
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
              onPressed: () {
                // TODO: Navegar a editar perfil
              },
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
      onTap: () {
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
