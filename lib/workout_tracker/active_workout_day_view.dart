import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/services/scheduled_workout_service.dart';
import 'package:afermar3_tf_ipc/services/workout_progress_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/workout_tracker/exercises_stpe_details.dart';
import 'package:flutter/material.dart';

class ActiveWorkoutDayView extends StatefulWidget {
  final Map<String, dynamic> workout;
  final int? savedWorkoutId;
  final int? scheduledWorkoutId;
  final int dayIndex;

  const ActiveWorkoutDayView({
    super.key,
    required this.workout,
    this.savedWorkoutId,
    this.scheduledWorkoutId,
    this.dayIndex = 0,
  });

  @override
  State<ActiveWorkoutDayView> createState() => _ActiveWorkoutDayViewState();
}

class _ActiveWorkoutDayViewState extends State<ActiveWorkoutDayView> {
  final Set<int> completedExercises = {};

  bool isSavingSession = false;
  bool isLoadingProgress = true;

  bool alreadyCompletedToday = false;
  bool isCheckingTodaySession = true;

  // Cuando el usuario quiere repetir el entrenamiento,
  // no modificamos el progreso guardado anterior.
  // Solo usamos checks locales hasta finalizar la nueva sesión.
  bool isRepeatMode = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadExerciseProgress(),
      _checkTodaySessionStatus(),
    ]);
  }

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

  int? get currentDayNumber {
    final day = currentDay;

    if (day == null) return null;

    final value = day["day_number"];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? "");
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

  int? _parseExerciseId(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  String _getExerciseName(Map<String, dynamic> exercise) {
    return exercise["exercise_name"]?.toString() ??
        exercise["name"]?.toString() ??
        "Ejercicio";
  }

  Future<void> _checkTodaySessionStatus() async {
    try {
      final status = await WorkoutSessionService.getTodaySessionStatus(
        savedWorkoutId: widget.savedWorkoutId,
        dayNumber: currentDayNumber,
      );

      final completedToday = status["already_completed_today"] == true;

      if (!mounted) return;

      setState(() {
        alreadyCompletedToday = completedToday;
        isCheckingTodaySession = false;
      });

      if (completedToday && !isRepeatMode) {
        await _ensureAllExercisesCompletedAfterFinish();
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        alreadyCompletedToday = false;
        isCheckingTodaySession = false;
      });
    }
  }

  Future<void> _ensureAllExercisesCompletedAfterFinish() async {
    if (totalExercises == 0) return;

    final indexes = <int>{};

    for (int i = 0; i < exercises.length; i++) {
      final exercise = exercises[i];

      indexes.add(i);

      await WorkoutProgressService.toggleExerciseProgress(
        savedWorkoutId: widget.savedWorkoutId,
        scheduledWorkoutId: null,
        dayNumber: currentDayNumber,
        exerciseIndex: i,
        exerciseId: _parseExerciseId(exercise["exercise_id"]),
        exerciseName: _getExerciseName(exercise),
        completed: true,
      );
    }

    if (!mounted) return;

    setState(() {
      completedExercises
        ..clear()
        ..addAll(indexes);
    });
  }

  Future<void> _loadExerciseProgress() async {
    try {
      final progress = await WorkoutProgressService.getDayProgress(
        savedWorkoutId: widget.savedWorkoutId,
        scheduledWorkoutId: null,
        dayNumber: currentDayNumber,
      );

      final completedIndexesRaw = progress["completed_exercise_indexes"];

      final loadedIndexes = <int>{};

      if (completedIndexesRaw is List) {
        for (final item in completedIndexesRaw) {
          final parsed = int.tryParse(item.toString());

          if (parsed != null && parsed >= 0 && parsed < totalExercises) {
            loadedIndexes.add(parsed);
          }
        }
      }

      if (!mounted) return;

      setState(() {
        completedExercises
          ..clear()
          ..addAll(loadedIndexes);
        isLoadingProgress = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingProgress = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _toggleExercise(int index) async {
    if (alreadyCompletedToday && !isRepeatMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Este entrenamiento ya está finalizado. Pulsa 'Volver a hacer entrenamiento' para repetirlo.",
          ),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (index < 0 || index >= exercises.length) return;

    final exercise = exercises[index];

    final wasCompleted = completedExercises.contains(index);
    final newCompletedValue = !wasCompleted;

    setState(() {
      if (newCompletedValue) {
        completedExercises.add(index);
      } else {
        completedExercises.remove(index);
      }
    });

    // En modo repetición NO tocamos el progreso persistido.
    // El entrenamiento anterior debe seguir constando como completado.
    if (isRepeatMode) return;

    try {
      await WorkoutProgressService.toggleExerciseProgress(
        savedWorkoutId: widget.savedWorkoutId,
        scheduledWorkoutId: null,
        dayNumber: currentDayNumber,
        exerciseIndex: index,
        exerciseId: _parseExerciseId(exercise["exercise_id"]),
        exerciseName: _getExerciseName(exercise),
        completed: newCompletedValue,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (wasCompleted) {
          completedExercises.add(index);
        } else {
          completedExercises.remove(index);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openExerciseDetail(Map<String, dynamic> exercise) {
    final exerciseName = exercise["exercise_name"]?.toString() ??
        exercise["name"]?.toString() ??
        "Ejercicio";

    final reps = exercise["reps"]?.toString() ?? "";
    final sets = exercise["sets"]?.toString() ?? "";
    final notes = exercise["notes"]?.toString() ?? "";

    final mappedExercise = {
      "title": exerciseName,
      "value": reps.isEmpty ? "12x" : reps,
      "type": "reps",
      "image": exercise["image"]?.toString() ?? "assets/img/video_temp.png",
      "description": exercise["description"]?.toString() ??
          (notes.isEmpty
              ? "Ejercicio incluido en tu rutina activa. Realízalo manteniendo una técnica correcta y adaptando la intensidad a tu nivel."
              : notes),
      "sets": sets,
      "rest_seconds": exercise["rest_seconds"],
      "exercise_id": exercise["exercise_id"],
      "notes": notes,
      "muscle_group": exercise["muscle_group"] ?? "General",
      "difficulty": exercise["difficulty"] ?? "Rutina",
      "category": exercise["category"] ?? "Entrenamiento",
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

  Future<void> _finishWorkout({
    bool allowDuplicate = false,
  }) async {
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
      if (widget.scheduledWorkoutId != null && !allowDuplicate) {
        await ScheduledWorkoutService.completeScheduledWorkout(
          widget.scheduledWorkoutId!,
          totalExercises: totalExercises,
          completedExercises: completedCount,
          durationMinutes: 45,
        );
      } else {
        await WorkoutSessionService.createWorkoutSession(
          savedWorkoutId: widget.savedWorkoutId,
          workoutTitle: workoutTitle,
          dayNumber: dayNumber,
          dayName: dayName,
          totalExercises: totalExercises,
          completedExercises: completedCount,
          durationMinutes: 45,
          allowDuplicate: allowDuplicate,
        );
      }

      if (!mounted) return;

      if (!allowDuplicate) {
        setState(() {
          alreadyCompletedToday = true;
          isRepeatMode = false;
        });

        await _ensureAllExercisesCompletedAfterFinish();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: allowDuplicate
              ? const Text("Entrenamiento repetido guardado correctamente")
              : const Text("Entrenamiento guardado correctamente"),
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

  Future<void> _confirmRepeatWorkout() async {
    final repeat = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Volver a hacer entrenamiento"),
          content: const Text(
            "Se reiniciarán los checks en esta pantalla para que puedas repetir el entrenamiento. Solo se sumará una nueva sesión cuando vuelvas a completar todos los ejercicios y finalices.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                "Empezar",
                style: TextStyle(
                  color: TColor.primaryColor1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (repeat == true) {
      setState(() {
        isRepeatMode = true;
        completedExercises.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Modo repetición activado. Vuelve a completar los ejercicios.",
          ),
          backgroundColor: TColor.primaryColor1,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getBottomButtonTitle() {
    if (isSavingSession) return "Guardando...";
    if (isCheckingTodaySession) return "Comprobando...";

    if (isRepeatMode) {
      if (completedCount == totalExercises && totalExercises > 0) {
        return "Finalizar repetición";
      }

      return "Completar repetición";
    }

    if (alreadyCompletedToday) {
      return "Volver a hacer entrenamiento";
    }

    if (completedCount == totalExercises && totalExercises > 0) {
      return "Finalizar entrenamiento";
    }

    return "Completar ejercicios";
  }

  VoidCallback _getBottomButtonAction() {
    if (isSavingSession || isCheckingTodaySession) {
      return () {};
    }

    if (isRepeatMode) {
      return () => _finishWorkout(allowDuplicate: true);
    }

    if (alreadyCompletedToday) {
      return _confirmRepeatWorkout;
    }

    return () => _finishWorkout();
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
                        _buildExercisesList(),
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
                title: _getBottomButtonTitle(),
                onPressed: _getBottomButtonAction(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    if (isLoadingProgress) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TColor.primaryColor1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Cargando progreso de ejercicios...",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (exercises.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
        ),
        child: Text(
          "No hay ejercicios en este día.",
          style: TextStyle(
            color: TColor.gray,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: exercises.length,
      itemBuilder: (context, index) {
        final exercise = exercises[index];
        final completed = completedExercises.contains(index);

        return _ActiveExerciseCard(
          exercise: exercise,
          index: index,
          completed: completed,
          onToggle: () => _toggleExercise(index),
          onTap: () => _openExerciseDetail(exercise),
          locked: alreadyCompletedToday && !isRepeatMode,
        );
      },
    );
  }

  Widget _buildProgressCard() {
    String helperText = "Marca cada ejercicio cuando lo termines.";
    Color helperColor = TColor.gray;

    if (isRepeatMode) {
      helperText = "Modo repetición activo. Vuelve a completar los ejercicios.";
      helperColor = TColor.primaryColor1;
    } else if (alreadyCompletedToday) {
      helperText = "Ya has finalizado este entrenamiento hoy.";
      helperColor = Colors.green;
    }

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
                  helperText,
                  style: TextStyle(
                    color: helperColor,
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
  final bool locked;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const _ActiveExerciseCard({
    required this.exercise,
    required this.index,
    required this.completed,
    required this.locked,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final exerciseName = exercise["exercise_name"]?.toString() ??
        exercise["name"]?.toString() ??
        "Ejercicio";
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
            onTap: locked ? null : onToggle,
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
            locked ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded,
            color: locked ? Colors.green : TColor.gray,
            size: locked ? 18 : 15,
          ),
        ],
      ),
    );
  }
}