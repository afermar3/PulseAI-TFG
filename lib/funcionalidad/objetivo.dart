import 'package:afermar3_tf_ipc/funcionalidad/menu_principal.dart';
import 'package:afermar3_tf_ipc/funcionalidad/pantallas/Home/pantalla_home.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_controller.dart';

class objetivo extends StatefulWidget {
  const objetivo({super.key});

  @override
  State<objetivo> createState() => _objetivoView();
}

class _objetivoView extends State<objetivo> {
  CarouselSliderController buttonCarouselController = CarouselSliderController();
//convertir en fichero json
  List objetivos = [
    {
      "imagen": "assets/img/objetivo1.png",
      "titulo": "Subir de peso",
      "info":
          " ¿Estas un poco flojo? Entonces sube de peso controladamente\n  para poder aumentar tu musculo."
    },
    {
      "imagen": "assets/img/objetivo2.png",
      "titulo": "Definir o tonificar",
      "info":
          "Quieres definir o estar mas marcado para este verano? \n Define y pierde ese poco peso que te sobra."
    },
    {
      "imagen": "assets/img/objetivo3.png",
      "titulo": "Perder grasa",
      "info":
          "Estas un poco pasado de peso, o te estas preparando para algo? \npierde ese peso aqui."
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: CarouselSlider(
              items: objetivos
                  .map(
                    (gObj) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: TColor.primerG,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: media.width * 0.1, horizontal: 25),
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Column(
                          children: [
                            Image.asset(
                              gObj["imagen"].toString(),
                              width: media.width * 0.5,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              height: media.width * 0.1,
                            ),
                            Text(
                              gObj["titulo"].toString(),
                              style: TextStyle(
                                  color: TColor.blanco,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                            Container(
                              width: media.width * 0.1,
                              height: 1,
                              color: TColor.blanco,
                            ),
                            SizedBox(
                              height: media.width * 0.02,
                            ),
                            Text(
                              gObj["info"].toString(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: TColor.blanco, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              carouselController: buttonCarouselController,
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 0.7,
                aspectRatio: 0.74,
                initialPage: 0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            width: media.width,
            child: Column(
              children: [
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "Cual es tu objetivo?",
                  style: TextStyle(
                      color: TColor.negro,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "Aqui te podemos ayudar a escoger el mejor\nprograma para ti",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gris, fontSize: 12),
                ),
                const Spacer(),
                SizedBox(
                  height: media.width * 0.05,
                ),
                botonredondo(
                    title: "Confirmar",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Menu()));
                    }),
              ],
            ),
          )
        ],
      )),
    );
  }
}
