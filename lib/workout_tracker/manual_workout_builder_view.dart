import 'package:afermar3_tf_ipc/services/exercise_service.dart';
import 'package:afermar3_tf_ipc/services/workout_plan_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:flutter/material.dart';

class ManualWorkoutBuilderView extends StatefulWidget {
  final int? workoutId;
  final Map<String, dynamic>? existingWorkout;

  const ManualWorkoutBuilderView({
    super.key,
    this.workoutId,
    this.existingWorkout,
  });

  @override
  State<ManualWorkoutBuilderView> createState() =>
      _ManualWorkoutBuilderViewState();
}

class _ManualWorkoutBuilderViewState extends State<ManualWorkoutBuilderView> {
  final TextEditingController titleController = TextEditingController(
    text: "Rutina manual",
  );

  String selectedGoal = "Ganar músculo";
  String selectedLevel = "Principiante/Intermedio";
  int daysPerWeek = 4;
  int durationMinutes = 60;
  int selectedDayIndex = 0;

  bool isLoadingExercises = true;
  bool isSaving = false;
  String? errorMessage;

  List<Map<String, dynamic>> exercises = [];
  List<Map<String, dynamic>> days = [];

  bool get isEditing =>
      widget.workoutId != null && widget.existingWorkout != null;

  final List<String> goalOptions = [
    "Ganar músculo",
    "Perder grasa",
    "Mejorar resistencia",
    "Mantener forma",
  ];

  final List<String> levelOptions = [
    "Principiante",
    "Principiante/Intermedio",
    "Intermedio",
    "Avanzado",
  ];

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _loadExistingWorkout();
    } else {
      _generateDays();
    }

    _loadExercises();
  }

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    return int.tryParse(value.toString());
  }

  Map<String, dynamic> _getExistingContent() {
    final rawContent = widget.existingWorkout?["content"];

    if (rawContent is Map<String, dynamic>) {
      return rawContent;
    }

    if (rawContent is Map) {
      return Map<String, dynamic>.from(rawContent);
    }

    return {};
  }

  void _loadExistingWorkout() {
    final existingWorkout = widget.existingWorkout ?? {};
    final content = _getExistingContent();

    final title = existingWorkout["title"]?.toString() ??
        content["title"]?.toString() ??
        "Rutina manual";

    titleController.text = title;

    selectedGoal = existingWorkout["goal"]?.toString() ??
        content["goal"]?.toString() ??
        selectedGoal;

    selectedLevel = existingWorkout["level"]?.toString() ??
        content["level"]?.toString() ??
        selectedLevel;

    daysPerWeek = _parseInt(
          existingWorkout["days_per_week"] ?? content["days_per_week"],
        ) ??
        4;

    durationMinutes = _parseInt(
          existingWorkout["duration_minutes"] ?? content["duration_minutes"],
        ) ??
        60;

    final rawDays = content["days"];

    if (rawDays is List && rawDays.isNotEmpty) {
      days = rawDays.map((rawDay) {
        Map<String, dynamic> day;

        if (rawDay is Map<String, dynamic>) {
          day = rawDay;
        } else if (rawDay is Map) {
          day = Map<String, dynamic>.from(rawDay);
        } else {
          day = {};
        }

        final rawExercises = day["exercises"];

        final parsedExercises = <Map<String, dynamic>>[];

        if (rawExercises is List) {
          for (final rawExercise in rawExercises) {
            if (rawExercise is Map<String, dynamic>) {
              parsedExercises.add(Map<String, dynamic>.from(rawExercise));
            } else if (rawExercise is Map) {
              parsedExercises.add(Map<String, dynamic>.from(rawExercise));
            }
          }
        }

        return {
          "day_number": _parseInt(day["day_number"]) ?? parsedExercises.length + 1,
          "name": day["name"]?.toString() ?? "Día",
          "focus": day["focus"]?.toString() ?? "Entrenamiento personalizado",
          "exercises": parsedExercises,
        };
      }).toList();

      daysPerWeek = days.length;
      selectedDayIndex = 0;
    } else {
      _generateDays();
    }
  }

  void _generateDays() {
    days = List.generate(daysPerWeek, (index) {
      return {
        "day_number": index + 1,
        "name": "Día ${index + 1}",
        "focus": "Entrenamiento personalizado",
        "exercises": <Map<String, dynamic>>[],
      };
    });

    selectedDayIndex = 0;
  }

Future<void> _resizeDays(int newValue) async {
  if (newValue == daysPerWeek) return;

  if (newValue < daysPerWeek) {
    final removedDays = days.skip(newValue).toList();

    final removedExercisesCount = removedDays.fold<int>(0, (sum, day) {
      final dayExercises = day["exercises"] as List? ?? [];
      return sum + dayExercises.length;
    });

    if (removedExercisesCount > 0) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Reducir días"),
            content: Text(
              "Vas a eliminar ${daysPerWeek - newValue} día(s) de la rutina. "
              "Esos días contienen $removedExercisesCount ejercicio(s). "
              "Si continúas, se perderán de esta rutina.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancelar"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  "Eliminar días",
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

      if (confirm != true) return;
    }
  }

  final updatedDays = <Map<String, dynamic>>[];

  for (int i = 0; i < newValue; i++) {
    if (i < days.length) {
      final current = Map<String, dynamic>.from(days[i]);
      current["day_number"] = i + 1;
      updatedDays.add(current);
    } else {
      updatedDays.add({
        "day_number": i + 1,
        "name": "Día ${i + 1}",
        "focus": "Entrenamiento personalizado",
        "exercises": <Map<String, dynamic>>[],
      });
    }
  }

  if (!mounted) return;

  setState(() {
    daysPerWeek = newValue;
    days = updatedDays;

    if (selectedDayIndex >= days.length) {
      selectedDayIndex = days.length - 1;
    }

    if (selectedDayIndex < 0) {
      selectedDayIndex = 0;
    }
  });
}

  Future<void> _loadExercises() async {
    try {
      final result = await ExerciseService.getExercises();

      final loadedExercises = result.map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }

        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }

        return <String, dynamic>{};
      }).where((item) {
        return item.isNotEmpty;
      }).toList();

      if (!mounted) return;

      setState(() {
        exercises = loadedExercises;
        isLoadingExercises = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingExercises = false;
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Map<String, dynamic> get currentDay => days[selectedDayIndex];

  List<Map<String, dynamic>> get currentDayExercises {
    return List<Map<String, dynamic>>.from(currentDay["exercises"] as List);
  }

  int get totalExercises {
    return days.fold<int>(0, (sum, day) {
      final exercises = day["exercises"] as List? ?? [];
      return sum + exercises.length;
    });
  }

  void _updateCurrentDayField(String key, String value) {
    setState(() {
      days[selectedDayIndex][key] = value;
    });
  }

  void _removeExerciseFromCurrentDay(int index) {
    setState(() {
      final list = currentDay["exercises"] as List;
      list.removeAt(index);
    });
  }

  void _moveExerciseUp(int index) {
  if (index <= 0) return;

  setState(() {
    final list = currentDay["exercises"] as List;

    final exercise = list.removeAt(index);
    list.insert(index - 1, exercise);
  });
}

void _moveExerciseDown(int index) {
  final list = currentDay["exercises"] as List;

  if (index < 0 || index >= list.length - 1) return;

  setState(() {
    final exercise = list.removeAt(index);
    list.insert(index + 1, exercise);
  });
}

  void _showSimplePicker({
    required String title,
    required List<String> options,
    required String currentValue,
    required Function(String value) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
          decoration: BoxDecoration(
            color: TColor.white,
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
                    color: TColor.gray.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: TColor.gray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...options.map((option) {
                  final isSelected = option == currentValue;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      onSelected(option);
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? TColor.primaryColor1.withOpacity(0.10)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? TColor.primaryColor1.withOpacity(0.25)
                              : Colors.grey.shade100,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? TColor.primaryColor1
                                    : TColor.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: TColor.primaryColor1,
                              size: 22,
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddExerciseSheet() {
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No hay ejercicios disponibles"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    String searchText = "";
    List<Map<String, dynamic>> filtered = List.from(exercises);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            void applySearch(String value) {
              setModalState(() {
                searchText = value.toLowerCase().trim();
                filtered = exercises.where((exercise) {
                  final name =
                      exercise["name"]?.toString().toLowerCase() ?? "";
                  final muscleGroup =
                      exercise["muscle_group"]?.toString().toLowerCase() ?? "";
                  final category =
                      exercise["category"]?.toString().toLowerCase() ?? "";

                  return searchText.isEmpty ||
                      name.contains(searchText) ||
                      muscleGroup.contains(searchText) ||
                      category.contains(searchText);
                }).toList();
              });
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.82,
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: TColor.gray.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Añadir ejercicio",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: TColor.gray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search_rounded,
                            color: TColor.gray,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: applySearch,
                              decoration: InputDecoration(
                                hintText: "Buscar ejercicio...",
                                hintStyle: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                "No se encontraron ejercicios",
                                style: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final exercise = filtered[index];

                                return _ExercisePickerCard(
                                  exercise: exercise,
                                  onTap: () {
                                    Navigator.pop(context);
                                    _showConfigureExerciseSheet(exercise);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConfigureExerciseSheet(
    Map<String, dynamic> exercise, {
    int? editIndex,
  }) {
    final isEditingExercise = editIndex != null;

    final setsController = TextEditingController(
      text: isEditingExercise
          ? currentDayExercises[editIndex]["sets"]?.toString() ?? "3"
          : "3",
    );

    final repsController = TextEditingController(
      text: isEditingExercise
          ? currentDayExercises[editIndex]["reps"]?.toString() ?? "10-12"
          : "10-12",
    );

    final restController = TextEditingController(
      text: isEditingExercise
          ? currentDayExercises[editIndex]["rest_seconds"]?.toString() ?? "60"
          : "60",
    );

    final notesController = TextEditingController(
      text: isEditingExercise
          ? currentDayExercises[editIndex]["notes"]?.toString() ?? ""
          : "",
    );

    final exerciseName = isEditingExercise
        ? currentDayExercises[editIndex]["exercise_name"]?.toString() ??
            currentDayExercises[editIndex]["name"]?.toString() ??
            "Ejercicio"
        : exercise["name"]?.toString() ?? "Ejercicio";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: TColor.gray.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exerciseName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: TColor.gray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SmallInputField(
                            controller: setsController,
                            label: "Series",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallInputField(
                            controller: repsController,
                            label: "Reps",
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _SmallInputField(
                            controller: restController,
                            label: "Descanso",
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _LargeInputField(
                      controller: notesController,
                      label: "Notas opcionales",
                      hint: "Ej: Mantén el core activo",
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          final sets =
                              int.tryParse(setsController.text.trim()) ?? 3;
                          final rest =
                              int.tryParse(restController.text.trim()) ?? 60;

                          final configuredExercise = {
                            "exercise_id": isEditingExercise
                                ? currentDayExercises[editIndex]["exercise_id"]
                                : exercise["id"],
                            "exercise_name": exerciseName,
                            "sets": sets,
                            "reps": repsController.text.trim().isEmpty
                                ? "10-12"
                                : repsController.text.trim(),
                            "rest_seconds": rest,
                            "notes": notesController.text.trim(),
                          };

                          setState(() {
                            final list = currentDay["exercises"] as List;

                            if (isEditingExercise) {
                              list[editIndex] = configuredExercise;
                            } else {
                              list.add(configuredExercise);
                            }
                          });

                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.primaryColor1,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isEditingExercise
                              ? "Guardar ejercicio"
                              : "Añadir ejercicio",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveManualWorkout() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Pon un nombre para la rutina"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (totalExercises == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Añade al menos un ejercicio"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    final cleanDays = days.map((day) {
      final exercises = List<Map<String, dynamic>>.from(
        day["exercises"] as List,
      );

      return {
        "day_number": day["day_number"],
        "name": day["name"],
        "focus": day["focus"],
        "exercises": exercises,
      };
    }).toList();

    final workout = {
      "title": title,
      "summary":
          "Rutina creada manualmente con $daysPerWeek días por semana y $totalExercises ejercicios.",
      "goal": selectedGoal,
      "level": selectedLevel,
      "days_per_week": daysPerWeek,
      "duration_minutes": durationMinutes,
      "source": "MANUAL",
      "days": cleanDays,
    };

    try {
      if (isEditing) {
        await WorkoutPlanService.updateWorkoutPlan(
          workoutId: widget.workoutId!,
          workout: workout,
        );
      } else {
        await WorkoutPlanService.saveWorkoutPlan(
          workout: workout,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? "Rutina manual actualizada correctamente"
                : "Rutina manual guardada correctamente",
          ),
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
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = currentDay;
    final currentExercises = currentDayExercises;

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
          isEditing ? "Editar rutina" : "Rutina manual",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: isLoadingExercises ? null : _loadExercises,
            icon: Icon(
              Icons.refresh_rounded,
              color: TColor.primaryColor1,
            ),
          ),
        ],
      ),
      body: isLoadingExercises
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.primaryColor1,
              ),
            )
          : errorMessage != null
              ? _ManualBuilderError(
                  message: errorMessage!,
                  onRetry: _loadExercises,
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 14, 22, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SectionTitle(title: "Datos generales"),
                            const SizedBox(height: 10),
                            _LargeInputField(
                              controller: titleController,
                              label: "Nombre de la rutina",
                              hint: "Ej: Rutina fuerza 4 días",
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _OptionCard(
                                    title: "Objetivo",
                                    value: selectedGoal,
                                    icon: Icons.flag_rounded,
                                    onTap: () {
                                      _showSimplePicker(
                                        title: "Elegir objetivo",
                                        options: goalOptions,
                                        currentValue: selectedGoal,
                                        onSelected: (value) {
                                          setState(() {
                                            selectedGoal = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _OptionCard(
                                    title: "Nivel",
                                    value: selectedLevel,
                                    icon: Icons.bar_chart_rounded,
                                    onTap: () {
                                      _showSimplePicker(
                                        title: "Elegir nivel",
                                        options: levelOptions,
                                        currentValue: selectedLevel,
                                        onSelected: (value) {
                                          setState(() {
                                            selectedLevel = value;
                                          });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _StepperCard(
                                    title: "Días",
                                    value: "$daysPerWeek",
                                    subtitle: "por semana",
                                    onMinus: daysPerWeek <= 1
                                        ? null
                                        : () => _resizeDays(
                                              daysPerWeek - 1,
                                            ),
                                    onPlus: daysPerWeek >= 7
                                        ? null
                                        : () => _resizeDays(
                                              daysPerWeek + 1,
                                            ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _StepperCard(
                                    title: "Duración",
                                    value: "$durationMinutes",
                                    subtitle: "min",
                                    onMinus: durationMinutes <= 20
                                        ? null
                                        : () {
                                            setState(() {
                                              durationMinutes -= 5;
                                            });
                                          },
                                    onPlus: durationMinutes >= 120
                                        ? null
                                        : () {
                                            setState(() {
                                              durationMinutes += 5;
                                            });
                                          },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 26),
                            _SectionTitle(title: "Días de entrenamiento"),
                            const SizedBox(height: 12),
                            _DaySelector(
                              days: days,
                              selectedIndex: selectedDayIndex,
                              onSelected: (index) {
                                setState(() {
                                  selectedDayIndex = index;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            _LargeInputField(
                              key: ValueKey(
                                "day_name_${selectedDayIndex}_${current["name"]}",
                              ),
                              initialValue: current["name"]?.toString() ?? "",
                              label: "Nombre del día",
                              hint: "Ej: Tren superior A",
                              onChanged: (value) {
                                _updateCurrentDayField("name", value);
                              },
                            ),
                            const SizedBox(height: 12),
                            _LargeInputField(
                              key: ValueKey(
                                "day_focus_${selectedDayIndex}_${current["focus"]}",
                              ),
                              initialValue: current["focus"]?.toString() ?? "",
                              label: "Enfoque",
                              hint: "Ej: Pecho, hombro y tríceps",
                              onChanged: (value) {
                                _updateCurrentDayField("focus", value);
                              },
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _SectionTitle(
                                    title:
                                        "Ejercicios del día ${selectedDayIndex + 1}",
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _showAddExerciseSheet,
                                  icon: const Icon(Icons.add_rounded),
                                  label: const Text("Añadir"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: TColor.primaryColor1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (currentExercises.isEmpty)
                              _EmptyDayExercisesCard(
                                onAdd: _showAddExerciseSheet,
                              )
                            else
                              ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: currentExercises.length,
                                itemBuilder: (context, index) {
                                  final exercise = currentExercises[index];

                                    return _ManualExerciseCard(
                                      exercise: exercise,
                                      canMoveUp: index > 0,
                                      canMoveDown: index < currentExercises.length - 1,
                                      onMoveUp: () {
                                        _moveExerciseUp(index);
                                      },
                                      onMoveDown: () {
                                        _moveExerciseDown(index);
                                      },
                                      onEdit: () {
                                        _showConfigureExerciseSheet(
                                          exercise,
                                          editIndex: index,
                                        );
                                      },
                                      onDelete: () {
                                        _removeExerciseFromCurrentDay(index);
                                      },
                                    );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 14,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: isSaving ? null : _saveManualWorkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primaryColor1,
                            disabledBackgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            isSaving
                                ? isEditing
                                    ? "Actualizando..."
                                    : "Guardando..."
                                : isEditing
                                    ? "Guardar cambios"
                                    : "Guardar rutina",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: TColor.black,
        fontSize: 18,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(22),
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
            Icon(
              icon,
              color: TColor.primaryColor1,
              size: 22,
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TColor.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;

  const _StepperCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
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
        children: [
          Text(
            title,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundSmallButton(
                icon: Icons.remove_rounded,
                onTap: onMinus,
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              _RoundSmallButton(
                icon: Icons.add_rounded,
                onTap: onPlus,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundSmallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _RoundSmallButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: enabled
              ? TColor.primaryColor1.withOpacity(0.10)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? TColor.primaryColor1 : Colors.grey,
        ),
      ),
    );
  }
}

class _DaySelector extends StatelessWidget {
  final List<Map<String, dynamic>> days;
  final int selectedIndex;
  final Function(int index) onSelected;

  const _DaySelector({
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? TColor.primaryColor1 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  "Día ${index + 1}",
                  style: TextStyle(
                    color: isSelected ? TColor.white : TColor.gray,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExercisePickerCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;

  const _ExercisePickerCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = exercise["name"]?.toString() ?? "Ejercicio";
    final muscleGroup = exercise["muscle_group"]?.toString() ?? "General";
    final difficulty = exercise["difficulty"]?.toString() ?? "Sin nivel";

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: TColor.primaryColor1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$muscleGroup · $difficulty",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.add_circle_outline_rounded,
              color: TColor.primaryColor1,
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;

  final bool canMoveUp;
  final bool canMoveDown;

  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ManualExerciseCard({
    required this.exercise,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name = exercise["exercise_name"]?.toString() ?? "Ejercicio";
    final sets = exercise["sets"]?.toString() ?? "-";
    final reps = exercise["reps"]?.toString() ?? "-";
    final rest = exercise["rest_seconds"]?.toString() ?? "-";
    final notes = exercise["notes"]?.toString() ?? "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            children: [
              _OrderButton(
                icon: Icons.keyboard_arrow_up_rounded,
                enabled: canMoveUp,
                onTap: onMoveUp,
              ),
              const SizedBox(height: 4),
              _OrderButton(
                icon: Icons.keyboard_arrow_down_rounded,
                enabled: canMoveDown,
                onTap: onMoveDown,
              ),
            ],
          ),
          const SizedBox(width: 10),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: TColor.primaryColor1.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: TColor.primaryColor1,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onEdit,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$sets series · $reps reps · descanso $rest s",
                      style: TextStyle(
                        color: TColor.primaryColor1,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 3),
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
          IconButton(
            onPressed: onEdit,
            icon: Icon(
              Icons.edit_note_rounded,
              color: TColor.primaryColor1,
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}


class _OrderButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _OrderButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? onTap : null,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: enabled
              ? TColor.primaryColor1.withOpacity(0.10)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? TColor.primaryColor1 : Colors.grey.shade400,
        ),
      ),
    );
  }
}

class _EmptyDayExercisesCard extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyDayExercisesCard({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onAdd,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColor.primaryColor1.withOpacity(0.07),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: TColor.primaryColor1.withOpacity(0.10),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: TColor.primaryColor1,
              size: 32,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "Añade ejercicios a este día",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 14,
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

class _SmallInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  const _SmallInputField({
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        filled: true,
        fillColor: TColor.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _LargeInputField extends StatelessWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String label;
  final String hint;
  final Function(String value)? onChanged;

  const _LargeInputField({
    super.key,
    this.controller,
    this.initialValue,
    required this.label,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      onChanged: onChanged,
      maxLines: 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: TColor.gray,
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: TColor.gray.withOpacity(0.7),
          fontSize: 12,
        ),
        filled: true,
        fillColor: TColor.lightGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _ManualBuilderError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ManualBuilderError({
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
              "No se pudieron cargar los ejercicios",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.gray,
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