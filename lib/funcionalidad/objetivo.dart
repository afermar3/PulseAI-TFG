import 'package:afermar3_tf_ipc/funcionalidad/menu_principal.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:afermar3_tf_ipc/main_tab/main_tab_view.dart';

class objetivo extends StatefulWidget {
  const objetivo({super.key});

  @override
  State<objetivo> createState() => _ObjetivoViewState();
}

class _ObjetivoViewState extends State<objetivo> {
  final CarouselSliderController carouselController =
      CarouselSliderController();

  int selectedIndex = 0;

  final List<Map<String, String>> objetivos = [
    {
      "imagen": "assets/img/objetivo1.png",
      "titulo": "Ganar músculo",
      "info":
          "Ideal si quieres aumentar tu masa muscular con entrenamientos progresivos y una planificación adaptada.",
    },
    {
      "imagen": "assets/img/objetivo2.png",
      "titulo": "Definir y tonificar",
      "info":
          "Perfecto si quieres verte más marcado, mejorar tu forma física y mantener un cuerpo más equilibrado.",
    },
    {
      "imagen": "assets/img/objetivo3.png",
      "titulo": "Perder grasa",
      "info":
          "Pensado para reducir grasa corporal, mejorar tu resistencia y crear hábitos más saludables.",
    },
  ];

  void _confirmarObjetivo() {
    final objetivoSeleccionado = objetivos[selectedIndex];

    // Más adelante aquí guardaremos el objetivo seleccionado
    // junto con el usuario en la base de datos.
    debugPrint("Objetivo seleccionado: ${objetivoSeleccionado["titulo"]}");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Menu(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: TColor.negro,
                    ),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                "¿Cuál es tu objetivo?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Elige el objetivo principal para que podamos adaptar mejor tu experiencia.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 34),

              Expanded(
                child: CarouselSlider.builder(
                  carouselController: carouselController,
                  itemCount: objetivos.length,
                  itemBuilder: (context, index, realIndex) {
                    final item = objetivos[index];
                    final bool isSelected = selectedIndex == index;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.symmetric(
                        vertical: isSelected ? 0 : 14,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        gradient: LinearGradient(
                          colors: TColor.primerG,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: TColor.rojo.withOpacity(0.22),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 28,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Image.asset(
                                item["imagen"]!,
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 22),

                            Text(
                              item["titulo"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Container(
                              width: 42,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            const SizedBox(height: 18),

                            Text(
                              item["info"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  options: CarouselOptions(
                    height: media.height * 0.53,
                    autoPlay: false,
                    enlargeCenterPage: true,
                    viewportFraction: 0.82,
                    initialPage: selectedIndex,
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  objetivos.length,
                  (index) {
                    final bool isActive = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        carouselController.animateToPage(index);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? TColor.rojo
                              : TColor.gris.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _confirmarObjetivo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.rojo,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    "Confirmar objetivo",
                    style: const TextStyle(
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
    );
  }
}