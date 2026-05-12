import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:flutter/material.dart';

class EjercicioAcabado extends StatefulWidget {
  const EjercicioAcabado({super.key});

  @override
  State<EjercicioAcabado> createState() => _EjercicioAcabadoState();
}

class _EjercicioAcabadoState extends State<EjercicioAcabado> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                "assets/img/act_acabada.png",
                height: media.width * 0.8,
                fit: BoxFit.fitHeight,
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Felicidades, has acabado tu trabajo",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Los ejercicios y la comida son muy importantes, combinalos y se el mas fuerte.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Spacer(),
              botonredondo(
                  title: "Volver inicio",
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
