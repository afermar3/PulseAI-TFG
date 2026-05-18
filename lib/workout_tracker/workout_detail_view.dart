import 'package:afermar3_tf_ipc/common_widget/round_button.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/workout_tracker/exercises_stpe_details.dart';
import 'package:afermar3_tf_ipc/workout_tracker/workout_schedule_view.dart';
import 'package:flutter/material.dart';

class WorkoutDetailView extends StatefulWidget {
  final Map dObj;

  const WorkoutDetailView({
    super.key,
    required this.dObj,
  });

  @override
  State<WorkoutDetailView> createState() => _WorkoutDetailViewState();
}

class _WorkoutDetailViewState extends State<WorkoutDetailView> {
  bool isFavorite = false;

  final List<Map<String, dynamic>> equipmentArr = [
    {
      "id": 1,
      "image": "assets/img/barbell.png",
      "title": "Mancuernas",
      "subtitle": "Peso ajustable",
    },
    {
      "id": 2,
      "image": "assets/img/skipping_rope.png",
      "title": "Comba",
      "subtitle": "Cardio",
    },
    {
      "id": 3,
      "image": "assets/img/bottle.png",
      "title": "Agua",
      "subtitle": "1 litro",
    },
  ];

  final List<Map<String, dynamic>> exercisesArr = [
    {
      "id": 1,
      "name": "Calentamiento",
      "description": "Activación inicial para preparar el cuerpo.",
      "set": [
        {
          "id": 101,
          "image": "assets/img/img_1.png",
          "title": "Warm Up",
          "value": "05:00",
          "type": "time",
          "description": "Calentamiento general suave para activar el cuerpo.",
        },
        {
          "id": 102,
          "image": "assets/img/img_2.png",
          "title": "Jumping Jack",
          "value": "12x",
          "type": "reps",
          "description": "Ejercicio cardiovascular para elevar pulsaciones.",
        },
        {
          "id": 103,
          "image": "assets/img/img_1.png",
          "title": "Skipping",
          "value": "15x",
          "type": "reps",
          "description": "Elevación de rodillas para activar piernas y core.",
        },
      ],
    },
    {
      "id": 2,
      "name": "Bloque principal",
      "description": "Ejercicios principales de fuerza y resistencia.",
      "set": [
        {
          "id": 201,
          "image": "assets/img/img_2.png",
          "title": "Squats",
          "value": "20x",
          "type": "reps",
          "description": "Sentadillas para trabajar piernas y glúteos.",
        },
        {
          "id": 202,
          "image": "assets/img/img_1.png",
          "title": "Arm Raises",
          "value": "00:53",
          "type": "time",
          "description": "Elevaciones de brazos para hombros y resistencia.",
        },
        {
          "id": 203,
          "image": "assets/img/img_2.png",
          "title": "Rest and Drink",
          "value": "02:00",
          "type": "rest",
          "description": "Descanso breve para recuperar energía.",
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    final String title = widget.dObj["title"]?.toString() ?? "Entrenamiento";
    final String subtitle =
        widget.dObj["subtitle"]?.toString() ?? "Rutina personalizada";
    final String exercises =
        widget.dObj["exercises"]?.toString() ?? "11 ejercicios";
    final String duration = widget.dObj["time"]?.toString() ?? "32 min";
    final String level = widget.dObj["level"]?.toString() ?? "Medio";
    final String kcal = widget.dObj["kcal"]?.toString() ?? "280 kcal";
    final String image =
        widget.dObj["image"]?.toString() ?? "assets/img/detail_top.png";

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: media.width * 0.78,
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
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });

                        // TODO backend:
                        // PATCH /workouts/{id}/favorite
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
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
                        padding: const EdgeInsets.fromLTRB(22, 76, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  image,
                                  width: media.width * 0.72,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      "assets/img/detail_top.png",
                                      width: media.width * 0.72,
                                      fit: BoxFit.contain,
                                    );
                                  },
                                ),
                              ),
                            ),
                            Text(
                              title,
                              style: TextStyle(
                                color: TColor.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: TColor.white.withOpacity(0.80),
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
                        _buildStatsRow(
                          exercises: exercises,
                          duration: duration,
                          kcal: kcal,
                        ),
                        const SizedBox(height: 22),
                        _ActionInfoCard(
                          icon: Icons.calendar_month_rounded,
                          title: "Programar entrenamiento",
                          subtitle: "Añade esta rutina a tu agenda",
                          trailingText: "Elegir",
                          backgroundColor:
                              TColor.primaryColor2.withOpacity(0.22),
                          iconColor: TColor.primaryColor1,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WorkoutScheduleView(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        _ActionInfoCard(
                          icon: Icons.speed_rounded,
                          title: "Dificultad",
                          subtitle: "Nivel recomendado para esta rutina",
                          trailingText: level,
                          backgroundColor:
                              TColor.secondaryColor2.withOpacity(0.20),
                          iconColor: TColor.secondaryColor1,
                          onTap: () {},
                        ),
                        const SizedBox(height: 26),
                        _buildSectionHeader(
                          title: "Material necesario",
                          actionText: "${equipmentArr.length} items",
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            scrollDirection: Axis.horizontal,
                            itemCount: equipmentArr.length,
                            itemBuilder: (context, index) {
                              final item = equipmentArr[index];

                              return _EquipmentCard(item: item);
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        _buildSectionHeader(
                          title: "Ejercicios",
                          actionText: "${exercisesArr.length} bloques",
                        ),
                        const SizedBox(height: 12),
                        ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: exercisesArr.length,
                          itemBuilder: (context, index) {
                            final section = exercisesArr[index];

                            return _ExerciseSetCard(
                              section: section,
                              onExerciseTap: (exercise) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExercisesStepDetails(
                                      eObj: exercise,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
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
                title: "Empezar entrenamiento",
                onPressed: () {
                  // TODO:
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => WorkoutSessionView(workoutId: widget.dObj["id"]),
                  // ));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Iniciando $title"),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: TColor.primaryColor1,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow({
    required String exercises,
    required String duration,
    required String kcal,
  }) {
    return Row(
      children: [
        Expanded(
          child: _WorkoutStatCard(
            icon: Icons.fitness_center_rounded,
            value: exercises.replaceAll("ejercicios", "").trim(),
            label: "Ejercicios",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WorkoutStatCard(
            icon: Icons.timer_outlined,
            value: duration,
            label: "Duración",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _WorkoutStatCard(
            icon: Icons.local_fire_department_rounded,
            value: kcal.replaceAll("kcal", "").trim(),
            label: "Kcal",
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          actionText,
          style: TextStyle(
            color: TColor.gray,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _WorkoutStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WorkoutStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.045),
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

class _ActionInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailingText;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionInfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingText,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 27,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              trailingText,
              style: TextStyle(
                color: iconColor,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: iconColor,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const _EquipmentCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 132,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Center(
              child: Image.asset(
                item["image"].toString(),
                width: 62,
                height: 62,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.inventory_2_outlined,
                    color: TColor.primaryColor1,
                    size: 42,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item["title"].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.black,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item["subtitle"].toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseSetCard extends StatelessWidget {
  final Map<String, dynamic> section;
  final Function(Map<String, dynamic> exercise) onExerciseTap;

  const _ExerciseSetCard({
    required this.section,
    required this.onExerciseTap,
  });

  @override
  Widget build(BuildContext context) {
    final List exercises = section["set"] as List? ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: TColor.primaryColor1.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.playlist_add_check_rounded,
                  color: TColor.primaryColor1,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section["name"].toString(),
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      section["description"].toString(),
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "${exercises.length} ejercicios",
                style: TextStyle(
                  color: TColor.primaryColor1,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: exercises.length,
            separatorBuilder: (context, index) {
              return Divider(
                height: 18,
                color: Colors.grey.shade100,
              );
            },
            itemBuilder: (context, index) {
              final exercise =
                  Map<String, dynamic>.from(exercises[index] as Map);

              return _ExerciseRow(
                exercise: exercise,
                onTap: () {
                  onExerciseTap(exercise);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;

  const _ExerciseRow({
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String type = exercise["type"]?.toString() ?? "reps";

    IconData typeIcon;

    if (type == "time") {
      typeIcon = Icons.timer_outlined;
    } else if (type == "rest") {
      typeIcon = Icons.local_drink_outlined;
    } else {
      typeIcon = Icons.repeat_rounded;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                exercise["image"].toString(),
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 54,
                    height: 54,
                    color: Colors.grey.shade100,
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: TColor.primaryColor1,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise["title"].toString(),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    exercise["description"]?.toString() ??
                        "Ver instrucciones del ejercicio",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: TColor.primaryColor1.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    typeIcon,
                    color: TColor.primaryColor1,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    exercise["value"].toString(),
                    style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
