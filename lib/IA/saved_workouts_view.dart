import 'package:afermar3_tf_ipc/IA/ai_generated_workout_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/workout_plan_service.dart';
import 'package:afermar3_tf_ipc/workout_tracker/manual_workout_builder_view.dart';
import 'package:flutter/material.dart';

class SavedWorkoutsView extends StatefulWidget {
  const SavedWorkoutsView({super.key});

  @override
  State<SavedWorkoutsView> createState() => _SavedWorkoutsViewState();
}

class _SavedWorkoutsViewState extends State<SavedWorkoutsView> {
  late Future<List<dynamic>> _savedWorkoutsFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedWorkouts();
  }

  void _loadSavedWorkouts() {
    _savedWorkoutsFuture = WorkoutPlanService.getMyWorkoutPlans();
  }

  Future<void> _refresh() async {
    setState(() {
      _loadSavedWorkouts();
    });
  }

  bool _isManualWorkout(Map<String, dynamic> workout) {
    final content = _getWorkoutContent(workout);

    final rawSource = workout["source"]?.toString() ??
        content["source"]?.toString() ??
        "";

    return rawSource.toUpperCase() == "MANUAL";
  }

  Map<String, dynamic> _getWorkoutContent(Map<String, dynamic> workout) {
    final rawContent = workout["content"];

    if (rawContent is Map<String, dynamic>) {
      return rawContent;
    }

    if (rawContent is Map) {
      return Map<String, dynamic>.from(rawContent);
    }

    return {};
  }

  Future<void> _deleteWorkout(int workoutId) async {
    try {
      await WorkoutPlanService.deleteWorkoutPlan(workoutId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Rutina eliminada correctamente"),
          backgroundColor: TColor.rojo,
        ),
      );

      _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst("Exception: ", ""),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _openWorkout(Map<String, dynamic> savedWorkout) async {
    final content = _getWorkoutContent(savedWorkout);

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se ha podido abrir la rutina"),
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AiGeneratedWorkoutView(
          initialWorkout: content,
          isSavedWorkout: true,
          savedWorkoutId: savedWorkout["id"] as int?,
          isActiveWorkout: savedWorkout["is_active"] == true,
        ),
      ),
    );

    if (result == true && mounted) {
      _refresh();
    }
  }

  Future<void> _editManualWorkout(Map<String, dynamic> savedWorkout) async {
    final workoutId = savedWorkout["id"];

    if (workoutId is! int) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se ha podido editar la rutina"),
        ),
      );
      return;
    }

    final content = _getWorkoutContent(savedWorkout);

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No se ha podido cargar el contenido de la rutina"),
        ),
      );
      return;
    }

    final existingWorkout = Map<String, dynamic>.from(savedWorkout);
    existingWorkout["content"] = content;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManualWorkoutBuilderView(
          workoutId: workoutId,
          existingWorkout: existingWorkout,
        ),
      ),
    );

    if (result == true && mounted) {
      _refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Rutina actualizada correctamente"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _duplicateWorkout(Map<String, dynamic> savedWorkout) async {
    try {
      final content = _getWorkoutContent(savedWorkout);

      if (content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No se ha podido duplicar la rutina"),
          ),
        );
        return;
      }

      final originalTitle = savedWorkout["title"]?.toString() ??
          content["title"]?.toString() ??
          "Rutina";

      final duplicatedContent = Map<String, dynamic>.from(content);

      duplicatedContent["title"] = "Copia de $originalTitle";
      duplicatedContent["summary"] = content["summary"]?.toString() ??
          savedWorkout["summary"]?.toString() ??
          "Copia de una rutina guardada.";
      duplicatedContent["goal"] = content["goal"] ?? savedWorkout["goal"];
      duplicatedContent["level"] = content["level"] ?? savedWorkout["level"];
      duplicatedContent["days_per_week"] =
          content["days_per_week"] ?? savedWorkout["days_per_week"];
      duplicatedContent["duration_minutes"] =
          content["duration_minutes"] ?? savedWorkout["duration_minutes"];

      await WorkoutPlanService.saveWorkoutPlan(
        workout: duplicatedContent,
      );

      if (!mounted) return;

      _refresh();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Rutina duplicada correctamente"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
    }
  }

  void _confirmDelete(Map<String, dynamic> workout) {
    final workoutId = workout["id"];

    if (workoutId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Eliminar rutina"),
          content: const Text(
            "¿Seguro que quieres eliminar esta rutina guardada?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteWorkout(workoutId as int);
              },
              child: Text(
                "Eliminar",
                style: TextStyle(
                  color: TColor.rojo,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openWorkoutActions(Map<String, dynamic> workout) {
    final isManual = _isManualWorkout(workout);
    final isActive = workout["is_active"] == true;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: TColor.gris.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        workout["title"]?.toString() ?? "Rutina guardada",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.negro,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: TColor.gris,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WorkoutActionButton(
                  icon: Icons.visibility_rounded,
                  title: "Ver rutina",
                  subtitle: "Abrir el detalle completo de la rutina",
                  color: TColor.rojo,
                  onTap: () {
                    Navigator.pop(context);
                    _openWorkout(workout);
                  },
                ),
                const SizedBox(height: 10),
                _WorkoutActionButton(
                  icon: Icons.copy_rounded,
                  title: "Duplicar rutina",
                  subtitle: "Crear una copia editable de esta rutina",
                  color: Colors.orangeAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _duplicateWorkout(workout);
                  },
                ),
                if (isManual) ...[
                  const SizedBox(height: 10),
                  _WorkoutActionButton(
                    icon: Icons.edit_note_rounded,
                    title: "Editar rutina manual",
                    subtitle: "Cambiar días, ejercicios, series y descansos",
                    color: Colors.blueAccent,
                    onTap: () {
                      Navigator.pop(context);
                      _editManualWorkout(workout);
                    },
                  ),
                ],
                const SizedBox(height: 10),
                _WorkoutActionButton(
                  icon: isActive
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  title: isActive ? "Rutina activa" : "No activa",
                  subtitle: isActive
                      ? "Esta es la rutina activa actualmente"
                      : "Puedes activarla desde el detalle de la rutina",
                  color: isActive ? Colors.green : TColor.gris,
                  onTap: () {
                    Navigator.pop(context);
                    _openWorkout(workout);
                  },
                ),
                const SizedBox(height: 10),
                _WorkoutActionButton(
                  icon: Icons.delete_outline_rounded,
                  title: "Eliminar rutina",
                  subtitle: "Borrar esta rutina guardada",
                  color: Colors.redAccent,
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDelete(workout);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
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
          "Mis rutinas",
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
            onPressed: _refresh,
            icon: Icon(
              Icons.refresh_rounded,
              color: TColor.rojo,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: _savedWorkoutsFuture,
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
                onRetry: _refresh,
              );
            }

            final workouts = snapshot.data ?? [];

            if (workouts.isEmpty) {
              return _EmptyView(
                onRefresh: _refresh,
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              color: TColor.rojo,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 110),
                itemCount: workouts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final workout = Map<String, dynamic>.from(
                    workouts[index] as Map,
                  );

                  return _SavedWorkoutCard(
                    workout: workout,
                    onTap: () => _openWorkout(workout),
                    onDelete: () => _confirmDelete(workout),
                    onMore: () => _openWorkoutActions(workout),
                    onDuplicate: () => _duplicateWorkout(workout),
                    onEdit: _isManualWorkout(workout)
                        ? () => _editManualWorkout(workout)
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SavedWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onMore;
  final VoidCallback onDuplicate;
  final VoidCallback? onEdit;

  const _SavedWorkoutCard({
    required this.workout,
    required this.onTap,
    required this.onDelete,
    required this.onMore,
    required this.onDuplicate,
    this.onEdit,
  });

  Map<String, dynamic> get content {
    final rawContent = workout["content"];

    if (rawContent is Map<String, dynamic>) {
      return rawContent;
    }

    if (rawContent is Map) {
      return Map<String, dynamic>.from(rawContent);
    }

    return {};
  }

  String get source {
    final rawSource = workout["source"]?.toString() ??
        content["source"]?.toString() ??
        "";

    if (rawSource.toUpperCase() == "MANUAL") {
      return "MANUAL";
    }

    return "AI";
  }

  String get sourceLabel {
    return source == "MANUAL" ? "Manual" : "IA";
  }

  IconData get sourceIcon {
    return source == "MANUAL"
        ? Icons.edit_note_rounded
        : Icons.auto_awesome_rounded;
  }

  Color get sourceColor {
    return source == "MANUAL" ? Colors.blueAccent : Colors.purpleAccent;
  }

  @override
  Widget build(BuildContext context) {
    final title = workout["title"]?.toString() ?? "Rutina guardada";
    final summary = workout["summary"]?.toString() ?? "";
    final goal = workout["goal"]?.toString() ?? "Sin objetivo";
    final level = workout["level"]?.toString() ?? "Sin nivel";
    final daysPerWeek = workout["days_per_week"]?.toString() ?? "-";
    final durationMinutes = workout["duration_minutes"]?.toString() ?? "-";
    final isActive = workout["is_active"] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColor.blanco,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? Colors.green : Colors.grey.shade100,
            width: isActive ? 1.4 : 1,
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SourceTag(
                  text: sourceLabel,
                  icon: sourceIcon,
                  color: sourceColor,
                ),
                if (isActive)
                  const _SourceTag(
                    text: "Activa",
                    icon: Icons.check_circle_rounded,
                    color: Colors.green,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: TColor.primerG),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    source == "MANUAL"
                        ? Icons.edit_note_rounded
                        : Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.negro,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$daysPerWeek días/semana · $durationMinutes min",
                        style: TextStyle(
                          color: TColor.rojo,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: TColor.blanco,
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  onSelected: (value) {
                    if (value == "view") {
                      onTap();
                    } else if (value == "duplicate") {
                      onDuplicate();
                    } else if (value == "edit") {
                      onEdit?.call();
                    } else if (value == "delete") {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: "view",
                        child: Row(
                          children: [
                            Icon(Icons.visibility_rounded),
                            SizedBox(width: 10),
                            Text("Ver"),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: "duplicate",
                        child: Row(
                          children: [
                            Icon(Icons.copy_rounded),
                            SizedBox(width: 10),
                            Text("Duplicar"),
                          ],
                        ),
                      ),
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: "edit",
                          child: Row(
                            children: [
                              Icon(Icons.edit_note_rounded),
                              SizedBox(width: 10),
                              Text("Editar"),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: "delete",
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                            ),
                            SizedBox(width: 10),
                            Text("Eliminar"),
                          ],
                        ),
                      ),
                    ];
                  },
                  child: Icon(
                    Icons.more_vert_rounded,
                    color: TColor.gris,
                  ),
                ),
              ],
            ),
            if (summary.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                summary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                _SmallTag(
                  icon: Icons.flag_rounded,
                  text: goal,
                ),
                const SizedBox(width: 8),
                _SmallTag(
                  icon: Icons.bar_chart_rounded,
                  text: level,
                ),
              ],
            ),
            if (onEdit != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_note_rounded, size: 18),
                  label: const Text("Editar rutina manual"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blueAccent,
                    side: const BorderSide(
                      color: Colors.blueAccent,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _WorkoutActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withOpacity(0.16),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 11,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceTag extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _SourceTag({
    required this.text,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallTag({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: TColor.rojo.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: TColor.rojo,
              size: 16,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: TColor.rojo,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        color: TColor.rojo,
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyView({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: TColor.rojo,
      child: ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.fitness_center_rounded,
            color: TColor.rojo,
            size: 58,
          ),
          const SizedBox(height: 18),
          Text(
            "Aún no tienes rutinas guardadas",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.negro,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Genera una rutina con PulseAI o crea una rutina manual y guárdala para verla aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.gris,
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

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
              "No se pudieron cargar tus rutinas",
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