import 'package:afermar3_tf_ipc/perfil/pantalla_info_personal.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:flutter/material.dart';

import '../IA/ia_coach_view.dart';
import '../home/pantalla_home.dart';
import '../main_tab/select_view.dart';
import '../photo_progress/photo_progress_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;

  final PageStorageBucket pageBucket = PageStorageBucket();

  Widget currentTab = const Home();

  void _changeTab(int index, Widget screen) {
    setState(() {
      selectTab = index;
      currentTab = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: TColor.white,
      extendBody: true,
      body: PageStorage(
        bucket: pageBucket,
        child: currentTab,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isKeyboardOpen
          ? null
          : Transform.translate(
              offset: const Offset(0, -8),
              child: GestureDetector(
                onTap: () {
                  _changeTab(4, const AiCoachView());
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TColor.white,
                    boxShadow: [
                      BoxShadow(
                        color: TColor.primaryColor1.withOpacity(0.35),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: ClipOval(
                      child: Image.asset(
                        "assets/img/imagenIA.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 74,
          margin: const EdgeInsets.only(
            left: 18,
            right: 18,
            bottom: 12,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: "assets/img/home_tab.png",
                activeIcon: "assets/img/home_tab_select.png",
                label: "Inicio",
                isActive: selectTab == 0,
                onTap: () {
                  _changeTab(0, const Home());
                },
              ),
              _NavItem(
                icon: "assets/img/activity_tab.png",
                activeIcon: "assets/img/activity_tab_select.png",
                label: "Actividad",
                isActive: selectTab == 1,
                onTap: () {
                  _changeTab(1, const SelectView());
                },
              ),
              const SizedBox(width: 72),
              _NavItem(
                icon: "assets/img/camera_tab.png",
                activeIcon: "assets/img/camera_tab_select.png",
                label: "Fotos",
                isActive: selectTab == 2,
                onTap: () {
                  _changeTab(2, const PhotoProgressView());
                },
              ),
              _NavItem(
                icon: "assets/img/profile_tab.png",
                activeIcon: "assets/img/profile_tab_select.png",
                label: "Perfil",
                isActive: selectTab == 3,
                onTap: () {
                  _changeTab(3, const Perfil());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String icon;
  final String activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          height: 64,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isActive ? 42 : 36,
                height: 30,
                decoration: BoxDecoration(
                  color: isActive
                      ? TColor.primaryColor1.withOpacity(0.10)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  isActive ? activeIcon : icon,
                  width: 23,
                  height: 23,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: isActive ? TColor.primaryColor1 : TColor.gray,
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: isActive ? 16 : 0,
                height: 3,
                decoration: BoxDecoration(
                  gradient:
                      isActive ? LinearGradient(colors: TColor.primaryG) : null,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
