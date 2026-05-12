import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class InfoPantallas extends StatelessWidget {
  final Map<String, String> pObj;

  const InfoPantallas({
    super.key,
    required this.pObj,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 55),

          Center(
            child: Image.asset(
              pObj["imagen"] ?? "",
              width: media.width * 0.9,
              height: media.height * 0.43,
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(height: 35),

          Text(
            pObj["titulo"] ?? "",
            style: TextStyle(
              color: TColor.negro,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            pObj["info"] ?? "",
            style: TextStyle(
              color: TColor.gris,
              fontSize: 16,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}