import 'dart:convert';

import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';

class Exercise {
  final String name;
  final String description;
  final String image;

  Exercise({
    required this.name,
    required this.description,
    required this.image,
  });
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      description: json['description'],
      image: json['image'],
    );
  }
}

class ExerciseLista extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.rojo,
        title: Text('Lista de Ejercicios'),
      ),
      body: FutureBuilder(
        future: DefaultAssetBundle.of(context)
            .loadString('assets/json/pantallas.json'),
        builder: (context, snapshot) {
          var exercises = <Exercise>[];
          if (snapshot.hasData) {
            var jsonList = json.decode(snapshot.data.toString());
            var exerciseJson = jsonList['exercises'] as List;
            exercises = exerciseJson
                .map((exercise) => Exercise.fromJson(exercise))
                .toList();
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              var exercise = exercises[index];
              return ListTile(
                leading: Image.asset(
                  exercise.image,
                  width: 50,
                  height: 50,
                ),
                title: Text(exercise.name),
                subtitle: Text(exercise.description),
              );
            },
          );
        },
      ),
    );
  }
}
