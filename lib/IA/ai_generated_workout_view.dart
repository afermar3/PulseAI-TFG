import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/ai_workout_service.dart';
import 'package:afermar3_tf_ipc/services/workout_plan_service.dart';
import 'package:flutter/material.dart';

class AiGeneratedWorkoutView extends StatefulWidget {
  const AiGeneratedWorkoutView({super.key});

  @override
  State<AiGeneratedWorkoutView> createState() => _AiGeneratedWorkoutViewState();
}

class _AiGeneratedWorkoutViewState extends State<AiGeneratedWorkoutView> {
  late Future<Map<String, dynamic>> _workoutFuture;

  @override
  void initState() {
    super.initState();

    _workoutFuture = AiWorkoutService.generateWorkout(
      daysPerWeek: 4,
      durationMinutes: 60,
      focus: "Ganar músculo",
      level: "Principiante/intermedio",
    );
  }

  Future<void> _regenerateWorkout() async {
    setState(() {
      _workoutFuture = AiWorkoutService.generateWorkout(
        daysPerWeek: 4,
        durationMinutes: 60,
        focus: "Ganar músculo",
        level: "Principiante/intermedio",
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Rutina IA",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColor.negro,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _regenerateWorkout,
            icon: Icon(
              Icons.refresh_rounded,
              color: TColor.rojo,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _workoutFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _LoadingView();
            }

            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString().replaceFirst(
                      "Exception: ",
                      "",
                    ),
                onRetry: _regenerateWorkout,
              );
            }

            final workout = snapshot.data ?? {};

            return _WorkoutContent(
              workout: workout,
              onSave: () async {
  try {
    await WorkoutPlanService.saveWorkoutPlan(
      workout: workout,
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Rutina guardada correctamente"),
        backgroundColor: TColor.rojo,
      ),
    );
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e.toString().replaceFirst("Exception: ", ""),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
},
            );
          },
        ),
      ),
    );
  }
}

class _WorkoutContent extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onSave;

  const _WorkoutContent({
    required this.workout,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final title = workout["title"]?.toString() ?? "Rutina personalizada";
    final summary = workout["summary"]?.toString() ?? "";
    final goal = workout["goal"]?.toString() ?? "";
    final level = workout["level"]?.toString() ?? "";
    final daysPerWeek = workout["days_per_week"]?.toString() ?? "";
    final durationMinutes = workout["duration_minutes"]?.toString() ?? "";
    final days = workout["days"] as List? ?? [];
    final warmup = workout["warmup"] as List? ?? [];
    final progression = workout["progression"] as List? ?? [];
    final finalTips = workout["final_tips"] as List? ?? [];

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(
                title: title,
                summary: summary,
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.flag_rounded,
                      label: "Objetivo",
                      value: goal,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.bar_chart_rounded,
                      label: "Nivel",
                      value: level,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.calendar_month_rounded,
                      label: "Días",
                      value: "$daysPerWeek/semana",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.timer_rounded,
                      label: "Duración",
                      value: "$durationMinutes min",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                "Plan semanal",
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              ...days.map((day) {
                return _WorkoutDayCard(day: day as Map<String, dynamic>);
              }),

              const SizedBox(height: 12),

              _ListSection(
                title: "Calentamiento",
                icon: Icons.local_fire_department_rounded,
                items: warmup,
              ),

              _ListSection(
                title: "Progresión",
                icon: Icons.trending_up_rounded,
                items: progression,
              ),

              _ListSection(
                title: "Consejos finales",
                icon: Icons.tips_and_updates_rounded,
                items: finalTips,
              ),
            ],
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _SaveWorkoutBottomBar(
            onSave: onSave,
          ),
        ),
      ],
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String title;
  final String summary;

  const _HeaderCard({
    required this.title,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primerColor2.withOpacity(0.20),
            TColor.primerColor1.withOpacity(0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primerG),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary,
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
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 76,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: TColor.rojo,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutDayCard extends StatelessWidget {
  final Map<String, dynamic> day;

  const _WorkoutDayCard({
    required this.day,
  });

  @override
  Widget build(BuildContext context) {
    final dayNumber = day["day_number"]?.toString() ?? "";
    final name = day["name"]?.toString() ?? "Entrenamiento";
    final focus = day["focus"]?.toString() ?? "";
    final exercises = day["exercises"] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: TColor.rojo.withOpacity(0.12),
                child: Text(
                  dayNumber,
                  style: TextStyle(
                    color: TColor.rojo,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: TColor.negro,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      focus,
                      style: TextStyle(
                        color: TColor.gris,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          ...exercises.map((exercise) {
            return _ExerciseTile(
              exercise: exercise as Map<String, dynamic>,
            );
          }),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const _ExerciseTile({
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseId = exercise["exercise_id"]?.toString() ?? "";
    final name = exercise["exercise_name"]?.toString() ?? "";
    final sets = exercise["sets"]?.toString() ?? "";
    final reps = exercise["reps"]?.toString() ?? "";
    final rest = exercise["rest_seconds"]?.toString() ?? "";
    final notes = exercise["notes"]?.toString() ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              exerciseId,
              style: TextStyle(
                color: TColor.rojo,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "$sets series · $reps reps · descanso $rest s",
                  style: TextStyle(
                    color: TColor.rojo,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    notes,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 11,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List items;

  const _ListSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: TColor.rojo,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                "- ${item.toString()}",
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SaveWorkoutBottomBar extends StatelessWidget {
  final VoidCallback onSave;

  const _SaveWorkoutBottomBar({
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
      decoration: BoxDecoration(
        color: TColor.blanco,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_rounded),
            label: const Text("Guardar rutina"),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.rojo,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: TColor.rojo,
            ),
            const SizedBox(height: 18),
            Text(
              "PulseAI está generando tu rutina...",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.negro,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Estamos usando tu perfil y los ejercicios disponibles en la app.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.gris,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: TColor.rojo,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              "No se pudo generar la rutina",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.negro,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.gris,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.rojo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Reintentar"),
            ),
          ],
        ),
      ),
    );
  }
}