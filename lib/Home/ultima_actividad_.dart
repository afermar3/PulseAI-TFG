import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class UltimaActividad extends StatelessWidget {
  final Map obj;
  const UltimaActividad({super.key, required this.obj});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                obj["imagen"].toString(),
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
                  obj["titulo"].toString(),
                  style: TextStyle(
                      color: TColor.negro,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Text(
                  obj["timepo"].toString(),
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
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ))
          ],
        ));
  }
}
