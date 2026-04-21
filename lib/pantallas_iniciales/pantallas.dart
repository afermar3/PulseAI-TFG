//pantalla con diseño en el que habra un boton en medio que ponga login para inicializar la aplicacion, o si deseas entrar sin logearte.
//si le damos al boton de ok o de continuar nos llevara a la pagina de poner los datos de la persona
import 'package:afermar3_tf_ipc/pantallas_iniciales/info_pantallas.dart';
import 'package:afermar3_tf_ipc/info_user/sign_up_view.dart';
import 'package:flutter/material.dart';

class Pantallas extends StatefulWidget {
  const Pantallas({super.key});

  @override
  State<Pantallas> createState() => _PantallasFoto();
}

class _PantallasFoto extends State<Pantallas> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      selectPage = controller.page?.round() ?? 0;

      setState(() {});
    });
  }

  List pageArr = [
    {
      "titulo": "Consigue tus objetivos",
      "info":
          "No te preocupes si tu solo no puedes llegar a tus objetivos, para eso estamos nosotros aqui!",
      "imagen": "assets/img/pant1.png"
    },
    {
      "titulo": "Con energia",
      "info":
          "Siempre con energia para poder conseguir tus metas, no importa el tiempo que tarde en conseguirlas, lo importante es llegar.",
      "imagen": "assets/img/pant2.png"
    },
    {
      "titulo": "Come saludable",
      "info":
          "Es muy importante que tus dietas esten adaptadas a las rutinas de entrenamiento, para eso tenemos nuestro plan de dietas, para que no te preocupes por ello.",
      "imagen": "assets/img/pant3.png"
    },
    {
      "titulo": "Horas de sueño",
      "info":
          "Lo mas importante de todo este camino el dormir bien, es esencial poder dormir las horas suficientes para coger el dia con energia, por esto tambien tenemos un planing de horas de descanso",
      "imagen": "assets/img/pant4.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              itemBuilder: (context, index) {
                var pObj = pageArr[index] as Map? ?? {};
                return infopantallas(pObj: pObj);
              }),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 70,
                  height: 70,
                  child: CircularProgressIndicator(
                    color: TColor.primerColor1,
                    value: (selectPage + 1) / 4,
                    strokeWidth: 2,
                  ),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: TColor.primerColor1,
                      borderRadius: BorderRadius.circular(35)),
                  child: IconButton(
                    icon: Icon(
                      Icons.navigate_next,
                      color: TColor.blanco,
                    ),
                    onPressed: () {
                      if (selectPage < 3) {
                        selectPage = selectPage + 1;

                        controller.animateToPage(selectPage,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.bounceInOut);
                        setState(() {});
                      } else {
                        print("Hola");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp()));
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class TColor {
  static get primerColor1 => const Color.fromARGB(255, 184, 4, 4);
  static Color get primerColor2 => Color.fromARGB(255, 0, 0, 0);

  static get segundoColor1 => Color.fromARGB(255, 0, 0, 0);
  static Color get segundoColor2 => Color.fromARGB(255, 0, 0, 0);

  static get tercerColor1 => Color.fromARGB(255, 255, 0, 0);
  static Color get tercerColor2 => Color.fromARGB(255, 255, 255, 255);

  static List<Color> get primerG => [primerColor2, primerColor1];
  static List<Color> get segundoG => [segundoColor2, segundoColor1];
  static List<Color> get tercerG => [tercerColor2, tercerColor1];

  static Color get negro => Color.fromARGB(255, 0, 0, 0);
  static Color get gris => Color.fromARGB(255, 0, 0, 0);
  static Color get blanco => Colors.white;
  static Color get rojo => const Color.fromARGB(255, 184, 4, 4);
  static Color get azul => Color.fromARGB(255, 28, 51, 154);
}
