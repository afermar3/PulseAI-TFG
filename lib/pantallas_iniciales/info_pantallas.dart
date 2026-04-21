import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class infopantallas extends StatelessWidget {
  final Map pObj;
  const infopantallas({super.key, required this.pObj});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SizedBox(
      width: media.width,
      height: media.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            pObj["imagen"].toString(),
            width: media.width,
            fit: BoxFit.fitWidth,
          ),
          SizedBox(
            height: media.width * 0.1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              pObj["titulo"].toString(),
              style: TextStyle(
                  color: TColor.negro,
                  fontSize: 24,
                  fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(
              pObj["info"].toString(),
              style: TextStyle(color: TColor.gris, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
