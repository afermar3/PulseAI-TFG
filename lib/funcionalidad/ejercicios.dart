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
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    );
  }
}

class ExerciseLista extends StatelessWidget {
  const ExerciseLista({super.key});

  Future<List<Exercise>> _loadExercises(BuildContext context) async {
    final jsonString = await DefaultAssetBundle.of(context)
        .loadString('assets/json/pantallas.json');

    final Map<String, dynamic> jsonData = json.decode(jsonString);
    final List exerciseJson = jsonData['exercises'] ?? [];

    return exerciseJson
        .map((exercise) => Exercise.fromJson(exercise))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        centerTitle: true,
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColor.negro,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          'Ejercicios',
          style: TextStyle(
            color: TColor.negro,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Exercise>>(
          future: _loadExercises(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: TColor.rojo,
                ),
              );
            }

            if (snapshot.hasError) {
              return _ErrorState(
                message: 'No se han podido cargar los ejercicios.',
              );
            }

            final exercises = snapshot.data ?? [];

            if (exercises.isEmpty) {
              return const _EmptyState();
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              children: [
                Text(
                  'Lista de ejercicios',
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Consulta ejercicios básicos para tus rutinas y entrenamientos.',
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        color: TColor.gris,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Buscar ejercicio',
                        style: TextStyle(
                          color: TColor.gris,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Todos los ejercicios',
                      style: TextStyle(
                        color: TColor.negro,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${exercises.length} ejercicios',
                      style: TextStyle(
                        color: TColor.gris,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                ...exercises.map(
                  (exercise) => _ExerciseCard(exercise: exercise),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;

  const _ExerciseCard({
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 68,
              height: 68,
              color: Colors.grey.shade100,
              child: Image.asset(
                exercise.image,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.fitness_center_rounded,
                    color: TColor.rojo,
                    size: 30,
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  exercise.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.rojo,
              size: 15,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No hay ejercicios disponibles.',
        style: TextStyle(
          color: TColor.gris,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: TColor.gris,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}