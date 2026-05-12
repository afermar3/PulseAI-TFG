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
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 120),

                // TITULO
                Text(
                  "PULSEAI",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),

                const SizedBox(height: 12),

                // SUBTITULO
                Text(
                  "Todos podemos entrenar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: TColor.negro.withOpacity(0.7),
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const Spacer(),

                // BOTON
                SizedBox(
                  width: double.infinity,
                  child: botonredondo(
                    title: "Empezar",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Pantallas(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}