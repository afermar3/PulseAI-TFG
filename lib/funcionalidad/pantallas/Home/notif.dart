import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class Notificacion extends StatefulWidget {
  const Notificacion({super.key});

  @override
  State<Notificacion> createState() => _NotificacionState();
}

class _NotificacionState extends State<Notificacion> {
  List notificationArr = [
    {
      "imagen": "assets/img/act1.png",
      "titulo": "Hora de comer",
      "tiempo": "Hace 1 minuto"
    },
    {
      "imagen": "assets/img/act2.png",
      "titulo": "No olvides de ejercitar el tren inferior. ",
      "tiempo": "Hace 3 minutos"
    },
    {
      "imagen": "assets/img/act3.png",
      "titulo": "Vamos, añade mas comidas a tu dieta. ",
      "tiempo": "Hace 3 horas"
    },
    {
      "imagen": "assets/img/act1.png",
      "titulo": "Felicidades has acabado el tren superior. ",
      "tiempo": "5 de Junio"
    },
    {
      "imagen": "assets/img/act2.png",
      "titulo": "eyyy, es hora de cenar!",
      "tiempo": "30 Marzo"
    },
    {
      "imagen": "assets/img/act3.png",
      "titulo": "OYE!! Has olvidado de hacer tren inferior",
      "tiempo": "21 Febrero"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.negro, borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/flecha.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Notificationes",
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
                  color: TColor.negro, borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/dospuntos.png",
                width: 12,
                height: 12,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.blanco,
      body: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          itemBuilder: ((context, index) {
            var nObj = notificationArr[index] as Map? ?? {};
            return NotificationRow(nObj: nObj);
          }),
          separatorBuilder: (context, index) {
            return Divider(
              color: TColor.negro.withOpacity(0.5),
              height: 1,
            );
          },
          itemCount: notificationArr.length),
    );
  }
}

class NotificationRow extends StatelessWidget {
  final Map nObj;
  const NotificationRow({super.key, required this.nObj});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              nObj["imagen"].toString(),
              width: 40,
              height: 40,
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
                nObj["titulo"].toString(),
                style: TextStyle(
                    color: TColor.negro,
                    fontWeight: FontWeight.w500,
                    fontSize: 12),
              ),
              Text(
                nObj["tiempo"].toString(),
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 10,
                ),
              ),
            ],
          )),
          IconButton(
              onPressed: () {},
              icon: Image.asset(
                "assets/img/sub_menu.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ))
        ],
      ),
    );
  }
}
