import 'package:afermar3_tf_ipc/Home/pantalla_home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class MyAlert extends StatelessWidget {
  final String content;

  MyAlert({required this.content});

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text("Politicas de privacidad"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                content,
                style: const TextStyle(fontSize: 18.0),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('Cancelar'),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent)),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('Aceptar'),
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.greenAccent)),
            child: const Text('Aceptar'),
          ),
        ],
      );
}
