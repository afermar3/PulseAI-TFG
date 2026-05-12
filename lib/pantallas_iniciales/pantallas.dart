import 'package:afermar3_tf_ipc/info_user/sign_up_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/info_pantallas.dart';
import 'package:flutter/material.dart';

class Pantallas extends StatefulWidget {
  const Pantallas({super.key});

  @override
  State<Pantallas> createState() => _PantallasFoto();
}

class _PantallasFoto extends State<Pantallas> {
  int selectPage = 0;
  final PageController controller = PageController();

  final List<Map<String, String>> pageArr = [
    {
      "titulo": "Consigue tus objetivos",
      "info":
          "No te preocupes si no puedes alcanzar tus objetivos por tu cuenta. Nosotros te ayudamos en cada paso.",
      "imagen": "assets/img/pant1.png"
    },
    {
      "titulo": "Entrena con energía",
      "info":
          "Mantén la motivación y avanza poco a poco. Lo importante no es la velocidad, sino seguir progresando.",
      "imagen": "assets/img/pant2.png"
    },
    {
      "titulo": "Come saludable",
      "info":
          "Combina tus rutinas con una alimentación adaptada a tus necesidades para mejorar tus resultados.",
      "imagen": "assets/img/pant3.png"
    },
    {
      "titulo": "Descansa mejor",
      "info":
          "Dormir bien es clave para recuperarte, rendir más y afrontar cada día con energía.",
      "imagen": "assets/img/pant4.png"
    },
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void nextPage() {
    if (selectPage < pageArr.length - 1) {
      controller.animateToPage(
        selectPage + 1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignUp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              onPageChanged: (index) {
                setState(() {
                  selectPage = index;
                });
              },
              itemBuilder: (context, index) {
                return InfoPantallas(pObj: pageArr[index]);
              },
            ),

            Positioned(
              top: 16,
              right: 20,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUp()),
                  );
                },
                child: Text(
                  "Saltar",
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 25,
              right: 25,
              bottom: 28,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      pageArr.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 8),
                        width: selectPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: selectPage == index
                              ? TColor.primerColor1
                              : TColor.primerColor1.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: nextPage,
                    borderRadius: BorderRadius.circular(35),
                    child: Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: TColor.primerColor1,
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: TColor.primerColor1.withOpacity(0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        selectPage == pageArr.length - 1
                            ? Icons.check
                            : Icons.arrow_forward_ios_rounded,
                        color: TColor.blanco,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TColor {
  static Color get primerColor1 => const Color.fromARGB(255, 184, 4, 4);
  static Color get primerColor2 => const Color.fromARGB(255, 0, 0, 0);

  static Color get segundoColor1 => const Color.fromARGB(255, 0, 0, 0);
  static Color get segundoColor2 => const Color.fromARGB(255, 0, 0, 0);

  static Color get tercerColor1 => const Color.fromARGB(255, 255, 0, 0);
  static Color get tercerColor2 => const Color.fromARGB(255, 255, 255, 255);

  static List<Color> get primerG => [primerColor2, primerColor1];
  static List<Color> get segundoG => [segundoColor2, segundoColor1];
  static List<Color> get tercerG => [tercerColor2, tercerColor1];

  static Color get negro => const Color.fromARGB(255, 0, 0, 0);
  static Color get gris => const Color.fromARGB(255, 95, 95, 95);
  static Color get blanco => Colors.white;
  static Color get rojo => const Color.fromARGB(255, 184, 4, 4);
  static Color get azul => const Color.fromARGB(255, 28, 51, 154);
}