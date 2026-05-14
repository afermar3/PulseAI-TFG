import 'package:flutter/material.dart';

import '../../widgets/color_extension.dart';
import '../../common_widget/notification_row.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final List<Map<String, String>> notificationArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Hora de comer",
      "time": "Hace 1 minuto",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "No olvides tu entrenamiento de tren inferior",
      "time": "Hace 3 horas",
    },
    {
      "image": "assets/img/Workout3.png",
      "title": "Añade tus comidas de hoy",
      "time": "Hace 3 horas",
    },
    {
      "image": "assets/img/Workout1.png",
      "title": "¡Felicidades! Has terminado tu entrenamiento",
      "time": "29 mayo",
    },
    {
      "image": "assets/img/Workout2.png",
      "title": "Hora de comer",
      "time": "8 abril",
    },
    {
      "image": "assets/img/Workout3.png",
      "title": "Has perdido tu entrenamiento programado",
      "time": "8 abril",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColor.black,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          "Notificaciones",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {},
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: TColor.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text(
              "Hoy",
              style: TextStyle(
                color: TColor.black,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Tienes ${notificationArr.length} notificaciones recientes",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 22),

            ListView.separated(
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: notificationArr.length,
              itemBuilder: (context, index) {
                final nObj = notificationArr[index];

                return Container(
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: NotificationRow(nObj: nObj),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
            ),
          ],
        ),
      ),
    );
  }
}