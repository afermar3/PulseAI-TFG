import 'package:afermar3_tf_ipc/services/exercise_service.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/workout_tracker/exercises_stpe_details.dart';
import 'package:flutter/material.dart';

class ExerciseLibraryView extends StatefulWidget {
  const ExerciseLibraryView({super.key});

  @override
  State<ExerciseLibraryView> createState() => _ExerciseLibraryViewState();
}

class _ExerciseLibraryViewState extends State<ExerciseLibraryView> {
  List<Map<String, dynamic>> exercises = [];
  List<Map<String, dynamic>> filteredExercises = [];

  bool isLoading = true;
  String? errorMessage;

  String selectedFilter = "Todos";
  String searchText = "";

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

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
        isLoading = false;
      });

      _applyFilters();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  List<String> get filters {
    final groups = exercises
        .map((exercise) => exercise["muscle_group"]?.toString() ?? "")
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();

    groups.sort();

    return ["Todos", ...groups];
  }

  void _applyFilters() {
    final normalizedSearch = searchText.trim().toLowerCase();

    final filtered = exercises.where((exercise) {
      final name = exercise["name"]?.toString().toLowerCase() ?? "";
      final description =
          exercise["description"]?.toString().toLowerCase() ?? "";
      final muscleGroup =
          exercise["muscle_group"]?.toString().toLowerCase() ?? "";
      final category = exercise["category"]?.toString().toLowerCase() ?? "";
      final difficulty =
          exercise["difficulty"]?.toString().toLowerCase() ?? "";

      final matchesFilter = selectedFilter == "Todos" ||
          muscleGroup == selectedFilter.toLowerCase();

      final matchesSearch = normalizedSearch.isEmpty ||
          name.contains(normalizedSearch) ||
          description.contains(normalizedSearch) ||
          muscleGroup.contains(normalizedSearch) ||
          category.contains(normalizedSearch) ||
          difficulty.contains(normalizedSearch);

      return matchesFilter && matchesSearch;
    }).toList();

    setState(() {
      filteredExercises = filtered;
    });
  }

  void _openExerciseDetail(Map<String, dynamic> exercise) {
    final mappedExercise = {
      "title": exercise["name"]?.toString() ?? "Ejercicio",
      "value": "12x",
      "type": "reps",
      "image": "assets/img/video_temp.png",
      "description": exercise["description"]?.toString() ??
          "Ejercicio disponible en la base de datos de PulseAI.",
      "exercise_id": exercise["id"],
      "muscle_group": exercise["muscle_group"],
      "difficulty": exercise["difficulty"],
      "category": exercise["category"],
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

  @override
  Widget build(BuildContext context) {
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
          "Ejercicios",
          style: TextStyle(
            color: TColor.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadExercises,
            icon: Icon(
              Icons.refresh_rounded,
              color: TColor.primaryColor1,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: TColor.primaryColor1,
                ),
              )
            : errorMessage != null
                ? _ExerciseErrorView(
                    message: errorMessage!,
                    onRetry: _loadExercises,
                  )
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                        child: _SearchBox(
                          controller: searchController,
                          onChanged: (value) {
                            searchText = value;
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FilterChips(
                        filters: filters,
                        selectedFilter: selectedFilter,
                        onSelected: (value) {
                          setState(() {
                            selectedFilter = value;
                          });
                          _applyFilters();
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredExercises.isEmpty
                            ? _EmptyExercisesView(
                                onRetry: () {
                                  searchController.clear();
                                  searchText = "";
                                  selectedFilter = "Todos";
                                  _applyFilters();
                                },
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(22, 8, 22, 120),
                                itemCount: filteredExercises.length,
                                itemBuilder: (context, index) {
                                  final exercise = filteredExercises[index];

                                  return _ExerciseCard(
                                    exercise: exercise,
                                    onTap: () => _openExerciseDetail(exercise),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final Function(String value) onChanged;

  const _SearchBox({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: TColor.gray,
            size: 24,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: "Buscar ejercicio...",
                hintStyle: TextStyle(
                  color: TColor.gray,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final Function(String value) onSelected;

  const _FilterChips({
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => onSelected(filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      isSelected ? TColor.primaryColor1 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: isSelected ? TColor.white : TColor.gray,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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

class _ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name = exercise["name"]?.toString() ?? "Ejercicio";
    final description = exercise["description"]?.toString() ?? "";
    final muscleGroup = exercise["muscle_group"]?.toString() ?? "General";
    final difficulty = exercise["difficulty"]?.toString() ?? "Sin nivel";
    final category = exercise["category"]?.toString() ?? "Ejercicio";

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: TColor.white,
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
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                color: TColor.primaryColor1,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
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
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description.isEmpty ? category : description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      height: 1.25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _ExerciseTag(text: muscleGroup),
                      _ExerciseTag(text: difficulty),
                      _ExerciseTag(text: category),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gray,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseTag extends StatelessWidget {
  final String text;

  const _ExerciseTag({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: TColor.primaryColor1.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: TColor.primaryColor1,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyExercisesView extends StatelessWidget {
  final VoidCallback onRetry;

  const _EmptyExercisesView({
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
              Icons.search_off_rounded,
              color: TColor.primaryColor1,
              size: 58,
            ),
            const SizedBox(height: 18),
            Text(
              "No se encontraron ejercicios",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Prueba con otro nombre o elimina los filtros.",
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
                backgroundColor: TColor.primaryColor1,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Limpiar filtros"),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ExerciseErrorView({
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