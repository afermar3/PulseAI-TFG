import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:flutter/material.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _PantPrincipal();
}

class _PantPrincipal extends State<StartedView> {
  bool colordif = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.blanco,
      body: Container(
          width: media.width,
          decoration: BoxDecoration(
            gradient: colordif
                ? LinearGradient(
                    colors: TColor.primerG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Text(
                "GYMFIT",
                style: TextStyle(
                    color: TColor.negro,
                    fontSize: 36,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                "Todos podemos entrenar!",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: botonredondo(
                    title: "Empezar",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Pantallas()));
                    },
                  ),
                ),
              )
            ],
          )),
    );
  }
}
