import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});

  @override
  State<Perfil> createState() => _Perfilwidgt();
}

class _Perfilwidgt extends State<Perfil> {
  bool activado = false;

  List accountArr = [
    {"imagen": "assets/img/Icon-Profile.png", "nombre": "Información personal", "tag": "1"},
    {"imagen": "assets/img/Icon-Achievement.png", "nombre": "Logros", "tag": "2"},
    {
      "imagen": "assets/img/Icon-Activity.png",
      "nombre": "Historial de actividad",
      "tag": "3"
    },
    {
      "imagen": "assets/img/Icon-Workout.png",
      "nombre": "Progreso",
      "tag": "4"
    }
  ];

  List otherArr = [
    {"imagen": "assets/img/Icon-Message.png", "nombre": "Contáctanos", "tag": "5"},
    {"imagen": "assets/img/Icon-Privacy.png", "nombre": "Politica de privacidad", "tag": "6"},
    {"imagen": "assets/img/Icon-Setting.png", "nombre": "Ajustes", "tag": "7"},
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Perfil",
          style: TextStyle(
              color: TColor.negro, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.negro,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/dospuntos.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.blanco,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.asset(
                      "assets/img/foto.png",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Usuario",
                          style: TextStyle(
                            color: TColor.negro,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "Perder peso",
                          style: TextStyle(
                            color: TColor.negro,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    height: 25,
                    child: botonredondo(
                      title: "Editar",
                      type: RoundButtonType.bgGradient,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      onPressed: () {
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              const Row(
                children: [
                  Expanded(
                    child: datosperfil(
                      titulo: "170cm",
                      subtitulo: "Altura",
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: datosperfil(
                      titulo: "80kg",
                      subtitulo: "Peso",
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: datosperfil(
                      titulo: "22yo",
                      subtitulo: "Edad",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.rojo,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cuenta",
                      style: TextStyle(
                        color: TColor.negro,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: accountArr.length,
                      itemBuilder: (context, index) {
                        var iObj = accountArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["imagen"].toString(),
                          title: iObj["nombre"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.rojo,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Otros",
                      style: TextStyle(
                        color: TColor.negro,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["imagen"].toString(),
                          title: iObj["nombre"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class datosperfil extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  const datosperfil({super.key, required this.titulo, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
          color: TColor.rojo,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)]),
      child: Column(
        children: [
         
        
            
            Text(
              titulo,
              style: TextStyle(
                  color: TColor.blanco,
                  fontWeight: FontWeight.w500,
                  fontSize: 14),
            ),
          
          Text(
            subtitulo,
            style: TextStyle(
              color: TColor.blanco,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingRow extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onPressed;
  const SettingRow({super.key, required this.icon, required this.title, required this.onPressed });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: SizedBox(
        height: 30,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(icon,
                height: 15, width: 15, fit: BoxFit.contain),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: TColor.blanco,
                  fontSize: 12,
                ),
              ),
            ),
            Image.asset("assets/img/flecha.png",
                height: 12, width: 12, fit: BoxFit.contain)
          ],
        ),
      ),
    );
  }
}
