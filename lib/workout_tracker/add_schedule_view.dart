import 'package:afermar3_tf_ipc/services/workout_plan_service.dart';
import 'package:flutter/material.dart';

import '../../widgets/color_extension.dart';
import '../../widgets/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';

class AddScheduleView extends StatefulWidget {
  final DateTime date;

  const AddScheduleView({
    super.key,
    required this.date,
  });

  @override
  State<AddScheduleView> createState() => _AddScheduleViewState();
}

class _AddScheduleViewState extends State<AddScheduleView> {
  late TimeOfDay selectedTime;

  Map<String, dynamic>? activeWorkout;
  List<Map<String, dynamic>> activeWorkoutDays = [];
  Map<String, dynamic>? selectedDay;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedTime = TimeOfDay(
      hour: now.hour,
      minute: now.minute,
    );

    _loadActiveWorkout();
  }

  Future<void> _loadActiveWorkout() async {
    try {
      final workout = await WorkoutPlanService.getActiveWorkoutPlan();

      final content = workout?["content"];

      List<Map<String, dynamic>> days = [];

      if (content is Map && content["days"] is List) {
        days = (content["days"] as List)
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

      if (!mounted) return;

      setState(() {
        activeWorkout = workout;
        activeWorkoutDays = days;
        selectedDay = days.isNotEmpty ? days.first : null;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        activeWorkout = null;
        activeWorkoutDays = [];
        selectedDay = null;
        isLoading = false;
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  String _formatTime(BuildContext context) {
    return selectedTime.format(context);
  }

  DateTime _buildSelectedDateTime() {
    return DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      selectedTime.hour,
      selectedTime.minute,
    );
  }

  Future<void> _selectTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: TColor.white,
              hourMinuteTextColor: TColor.black,
              dayPeriodTextColor: TColor.black,
              dialHandColor: TColor.rojo,
              dialBackgroundColor: TColor.lightGray,
              entryModeIconColor: TColor.rojo,
            ),
            colorScheme: ColorScheme.light(
              primary: TColor.rojo,
              onPrimary: Colors.white,
              surface: TColor.white,
              onSurface: TColor.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  String _getDayTitle(Map<String, dynamic> day) {
    final dayNumber = day["day_number"]?.toString() ?? "";
    final name = day["name"]?.toString() ?? "Entrenamiento";

    if (dayNumber.isEmpty) {
      return name;
    }

    return "Día $dayNumber - $name";
  }

  int _getDayNumber(Map<String, dynamic> day) {
    final value = day["day_number"];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? "") ?? 1;
  }

  int _getDurationMinutes() {
    final value = activeWorkout?["duration_minutes"];

    if (value is int) return value;

    return int.tryParse(value?.toString() ?? "") ?? 45;
  }

  int _getEstimatedKcal() {
    return _getDurationMinutes() * 6;
  }

  void _showWorkoutDayPicker() {
    if (activeWorkoutDays.isEmpty) return;

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
                        "Elegir día de rutina",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: TColor.gray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: activeWorkoutDays.length,
                    itemBuilder: (context, index) {
                      final day = activeWorkoutDays[index];
                      final isSelected = selectedDay == day;
                      final exercises = day["exercises"] as List? ?? [];
                      final focus = day["focus"]?.toString() ?? "";

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          setState(() {
                            selectedDay = day;
                          });
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
                                ? TColor.rojo.withOpacity(0.10)
                                : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? TColor.rojo.withOpacity(0.25)
                                  : Colors.grey.shade100,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? TColor.rojo.withOpacity(0.12)
                                      : TColor.primaryColor1.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  _getDayNumber(day).toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? TColor.rojo
                                        : TColor.primaryColor1,
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
                                      _getDayTitle(day),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected
                                            ? TColor.rojo
                                            : TColor.black,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      focus.isEmpty
                                          ? "${exercises.length} ejercicios"
                                          : "$focus · ${exercises.length} ejercicios",
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
                              if (isSelected)
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: TColor.rojo,
                                  size: 22,
                                ),
                            ],
                          ),
                        ),
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
  }

  void _saveSchedule() {
    final day = selectedDay;

    if (activeWorkout == null || day == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("No hay una rutina activa para programar"),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedDateTime = _buildSelectedDateTime();

    final workoutTitle =
        activeWorkout?["title"]?.toString() ?? "Rutina activa";

    final dayName = day["name"]?.toString() ?? "Entrenamiento";
    final dayNumber = _getDayNumber(day);
    final durationMinutes = _getDurationMinutes();
    final estimatedKcal = _getEstimatedKcal();

    final newSchedule = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "saved_workout_id": activeWorkout?["id"] as int?,
      "name": workoutTitle,
      "category": dayName,
      "day_number": dayNumber,
      "day_name": dayName,
      "duration": "$durationMinutes min",
      "duration_minutes": durationMinutes,
      "kcal": "$estimatedKcal kcal",
      "start_time": selectedDateTime,
      "completed": false,
    };

    Navigator.pop(context, newSchedule);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Añadir a agenda",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _loadActiveWorkout,
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.refresh_rounded,
                color: TColor.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: TColor.rojo,
                ),
              )
            : errorMessage != null
                ? _ScheduleLoadError(
                    message: errorMessage!,
                    onRetry: _loadActiveWorkout,
                  )
                : activeWorkoutDays.isEmpty
                    ? _NoActiveWorkoutToSchedule(
                        onCreateAI: () {
                          Navigator.pop(context);
                        },
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 25,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _HeaderDateCard(
                                    dateText: dateToString(
                                      widget.date,
                                      formatStr: "E, dd MMMM yyyy",
                                    ),
                                  ),
                                  const SizedBox(height: 22),
                                  Text(
                                    "Hora",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(18),
                                    onTap: _selectTime,
                                    child: Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: TColor.lightGray,
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.access_time_rounded,
                                            color: TColor.rojo,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Hora seleccionada",
                                                  style: TextStyle(
                                                    color: TColor.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  "Toca para cambiar la hora",
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
                                            _formatTime(context),
                                            style: TextStyle(
                                              color: TColor.rojo,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Día de rutina",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  IconTitleNextRow(
                                    icon: "assets/img/choose_workout.png",
                                    title: "Elegir día",
                                    time: selectedDay == null
                                        ? "Seleccionar"
                                        : _getDayTitle(selectedDay!),
                                    color: TColor.lightGray,
                                    onPressed: _showWorkoutDayPicker,
                                  ),
                                  const SizedBox(height: 16),
                                  _SelectedDayPreview(
                                    day: selectedDay,
                                    durationMinutes: _getDurationMinutes(),
                                    estimatedKcal: _getEstimatedKcal(),
                                  ),
                                  const SizedBox(height: 18),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: TColor.rojo.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline_rounded,
                                          color: TColor.rojo,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            "Este día de tu rutina activa se añadirá a la agenda. Podrás marcarlo como completado cuando lo realices.",
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
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(25, 12, 25, 20),
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
                            child: RoundButton(
                              title: "Guardar en agenda",
                              onPressed: _saveSchedule,
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}

class _SelectedDayPreview extends StatelessWidget {
  final Map<String, dynamic>? day;
  final int durationMinutes;
  final int estimatedKcal;

  const _SelectedDayPreview({
    required this.day,
    required this.durationMinutes,
    required this.estimatedKcal,
  });

  @override
  Widget build(BuildContext context) {
    final selectedDay = day;

    if (selectedDay == null) {
      return const SizedBox();
    }

    final dayName = selectedDay["name"]?.toString() ?? "Entrenamiento";
    final focus = selectedDay["focus"]?.toString() ?? "";
    final exercises = selectedDay["exercises"] as List? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
          Text(
            dayName,
            style: TextStyle(
              color: TColor.black,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (focus.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              focus,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _PreviewStat(
                  icon: Icons.fitness_center_rounded,
                  value: exercises.length.toString(),
                  label: "Ejercicios",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PreviewStat(
                  icon: Icons.timer_outlined,
                  value: "$durationMinutes",
                  label: "Min",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PreviewStat(
                  icon: Icons.local_fire_department_rounded,
                  value: "$estimatedKcal",
                  label: "Kcal",
                ),
              ),
            ],
          ),
          if (exercises.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              "Ejercicios",
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ...exercises.take(4).map((exercise) {
              String name = "Ejercicio";

              if (exercise is Map) {
                name = exercise["exercise_name"]?.toString() ?? "Ejercicio";
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline_rounded,
                      color: TColor.rojo,
                      size: 17,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (exercises.length > 4)
              Text(
                "+ ${exercises.length - 4} ejercicios más",
                style: TextStyle(
                  color: TColor.rojo,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _PreviewStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _PreviewStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.07),
        borderRadius: BorderRadius.circular(18),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: TColor.rojo,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: TColor.black,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleLoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ScheduleLoadError({
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
              "No se pudo cargar la rutina activa",
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

class _NoActiveWorkoutToSchedule extends StatelessWidget {
  final VoidCallback onCreateAI;

  const _NoActiveWorkoutToSchedule({
    required this.onCreateAI,
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
              Icons.fitness_center_rounded,
              color: TColor.rojo,
              size: 58,
            ),
            const SizedBox(height: 18),
            Text(
              "No tienes una rutina activa",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Primero crea o activa una rutina para poder programarla en tu agenda.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 13,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onCreateAI,
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.rojo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text("Volver"),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderDateCard extends StatelessWidget {
  final String dateText;

  const _HeaderDateCard({
    required this.dateText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.rojo.withOpacity(0.12),
            TColor.rojo.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/img/date.png",
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              dateText,
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}