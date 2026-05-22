import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/workout_tracker/exercises_stpe_details.dart';
import 'package:flutter/material.dart';

class ActiveWorkoutDayView extends StatefulWidget {
  final Map<String, dynamic> workout;
  final int? savedWorkoutId;
  final int dayIndex;

  const ActiveWorkoutDayView({
    super.key,
    required this.workout,
    this.savedWorkoutId,
    this.dayIndex = 0,
  });

  @override
  State<ActiveWorkoutDayView> createState() => _ActiveWorkoutDayViewState();
}

class _ActiveWorkoutDayViewState extends State<ActiveWorkoutDayView> {
  final Set<int> completedExercises = {};

  bool isSavingSession = false;

  Map<String, dynamic>? get currentDay {
    final days = widget.workout["days"] as List? ?? [];

    if (days.isEmpty) return null;

    final safeIndex = widget.dayIndex.clamp(0, days.length - 1);
    final day = days[safeIndex];

    if (day is Map<String, dynamic>) {
      return day;
    }

    if (day is Map) {
      return Map<String, dynamic>.from(day);
    }

    return null;
  }

  List<Map<String, dynamic>> get exercises {
    final day = currentDay;

    if (day == null) return [];

    final rawExercises = day["exercises"] as List? ?? [];

    return rawExercises
        .map((item) {
          if (item is Map<String, dynamic>) {
            return item;
          }

          if (item is Map) {
            return Map<String, dynamic>.from(item);
          }

          return <String, dynamic>{};
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }

  int get totalExercises => exercises.length;

  int get completedCount => completedExercises.length;

  double get progress {
    if (totalExercises == 0) return 0;
    return completedCount / totalExercises;
  }

  void _toggleExercise(int index) {
    setState(() {
      if (completedExercises.contains(index)) {
        completedExercises.remove(index);
      } else {
        completedExercises.add(index);
      }
    });
  }

  void _openExerciseDetail(Map<String, dynamic> exercise) {
    final exerciseName = exercise["exercise_name"]?.toString() ?? "Ejercicio";

    final reps = exercise["reps"]?.toString() ?? "";
    final sets = exercise["sets"]?.toString() ?? "";
    final notes = exercise["notes"]?.toString() ?? "";

    final mappedExercise = {
      "title": exerciseName,
      "value": reps.isEmpty ? "12x" : reps,
      "type": "reps",
      "image": "assets/img/video_temp.png",
      "description": notes.isEmpty
          ? "Ejercicio incluido en tu rutina activa. Realízalo manteniendo una técnica correcta y adaptando la intensidad a tu nivel."
          : notes,
      "sets": sets,
      "rest_seconds": exercise["rest_seconds"],
      "exercise_id": exercise["exercise_id"],
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExercisesStepDetails(
          eObj: mappedExercise,
        ),
      ),
    );
  }

  Future<void> _finishWorkout() async {
    if (totalExercises == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No hay ejercicios para guardar"),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (completedCount < totalExercises) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Te faltan ${totalExercises - completedCount} ejercicios por completar",
          ),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isSavingSession) return;

    final day = currentDay;

    if (day == null) return;

    final workoutTitle = widget.workout["title"]?.toString() ?? "Rutina activa";

    final dayNumber = int.tryParse(
      day["day_number"]?.toString() ?? "",
    );

    final dayName = day["name"]?.toString() ?? "Entrenamiento";

    setState(() {
      isSavingSession = true;
    });

    try {
      await WorkoutSessionService.createWorkoutSession(
        savedWorkoutId: widget.savedWorkoutId,
        workoutTitle: workoutTitle,
        dayNumber: dayNumber,
        dayName: dayName,
        totalExercises: totalExercises,
        completedExercises: completedCount,
        durationMinutes: 45,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Entrenamiento guardado correctamente"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingSession = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final day = currentDay;
    final media = MediaQuery.of(context).size;

    if (day == null) {
      return Scaffold(
        backgroundColor: TColor.white,
        appBar: AppBar(
          backgroundColor: TColor.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: TColor.black,
            ),
          ),
          title: Text(
            "Entrenamiento de hoy",
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Text(
              "No se ha podido cargar el día de entrenamiento.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
      );
    }

    final dayNumber = day["day_number"]?.toString() ?? "1";
    final dayName = day["name"]?.toString() ?? "Entrenamiento";
    final focus = day["focus"]?.toString() ?? "";
    final workoutTitle = widget.workout["title"]?.toString() ?? "Rutina activa";

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: media.width * 0.72,
                pinned: true,
                elevation: 0,
                backgroundColor: TColor.primaryColor1,
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
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                title: const Text(
                  "Entrenamiento de hoy",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: TColor.primaryG,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(22, 78, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Center(
                                child: Container(
                                  width: media.width * 0.42,
                                  height: media.width * 0.42,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.fitness_center_rounded,
                                    color: Colors.white,
                                    size: 72,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              "Día $dayNumber · $dayName",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              focus.isEmpty ? workoutTitle : focus,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: TColor.white.withOpacity(0.82),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                              color: TColor.gray.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _buildProgressCard(),
                        const SizedBox(height: 22),
                        _buildStatsRow(),
                        const SizedBox(height: 26),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Ejercicios de hoy",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Text(
                              "$totalExercises ejercicios",
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = exercises[index];
                            final completed =
                                completedExercises.contains(index);

                            return _ActiveExerciseCard(
                              exercise: exercise,
                              index: index,
                              completed: completed,
                              onToggle: () => _toggleExercise(index),
                              onTap: () => _openExerciseDetail(exercise),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _buildAdviceCard(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 18,
            child: SafeArea(
              top: false,
              child: RoundButton(
                title: isSavingSession
                    ? "Guardando..."
                    : completedCount == totalExercises && totalExercises > 0
                        ? "Finalizar entrenamiento"
                        : "Completar ejercicios",
                onPressed: isSavingSession ? () {} : _finishWorkout,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: TColor.primaryColor1.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 58,
            height: 58,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  backgroundColor: Colors.white,
                  color: TColor.primaryColor1,
                ),
                Center(
                  child: Text(
                    "${(progress * 100).round()}%",
                    style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$completedCount de $totalExercises completados",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Marca cada ejercicio cuando lo termines.",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
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

  Widget _buildStatsRow() {
    final totalSets = exercises.fold<int>(0, (sum, exercise) {
      final sets = exercise["sets"];

      if (sets is int) return sum + sets;

      return sum + (int.tryParse(sets?.toString() ?? "") ?? 0);
    });

    return Row(
      children: [
        Expanded(
          child: _TodayStatCard(
            icon: Icons.fitness_center_rounded,
            value: totalExercises.toString(),
            label: "Ejercicios",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TodayStatCard(
            icon: Icons.repeat_rounded,
            value: totalSets.toString(),
            label: "Series",
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _TodayStatCard(
            icon: Icons.timer_outlined,
            value: "45-60",
            label: "Min",
          ),
        ),
      ],
    );
  }

  Widget _buildAdviceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: TColor.rojo,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Prioriza la técnica. Descansa lo indicado entre series y no fuerces si aparece dolor.",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _TodayStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: TColor.primaryColor1,
              size: 24,
            ),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                color: TColor.black,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final int index;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _ActiveExerciseCard({
    required this.exercise,
    required this.index,
    required this.completed,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseName = exercise["exercise_name"]?.toString() ?? "Ejercicio";
    final sets = exercise["sets"]?.toString() ?? "-";
    final reps = exercise["reps"]?.toString() ?? "-";
    final rest = exercise["rest_seconds"]?.toString() ?? "-";
    final notes = exercise["notes"]?.toString() ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: completed ? Colors.green.withOpacity(0.06) : TColor.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: completed ? Colors.green : Colors.grey.shade100,
          width: completed ? 1.3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onToggle,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: completed
                    ? Colors.green.withOpacity(0.14)
                    : TColor.primaryColor1.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: completed ? Colors.green : TColor.primaryColor1,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exerciseName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$sets series · $reps reps · descanso $rest s",
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: TColor.gray,
            size: 15,
          ),
        ],
      ),
    );
  }
}