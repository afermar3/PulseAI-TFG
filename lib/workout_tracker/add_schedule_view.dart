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

  String selectedWorkout = "Upperbody";
  String selectedDifficulty = "Beginner";
  int selectedRepetitions = 12;
  double selectedWeight = 0;

  final List<String> workoutOptions = [
    "Fullbody",
    "Upperbody",
    "Lowerbody",
    "Ab Workout",
    "Cardio",
  ];

  final List<String> difficultyOptions = [
    "Beginner",
    "Intermediate",
    "Advanced",
  ];

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    selectedTime = TimeOfDay(
      hour: now.hour,
      minute: now.minute,
    );
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

  String _formatDateForOldSchedule(DateTime date) {
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();

    int hour = date.hour;
    final minute = date.minute.toString().padLeft(2, "0");
    final amPm = hour >= 12 ? "PM" : "AM";

    if (hour == 0) {
      hour = 12;
    } else if (hour > 12) {
      hour -= 12;
    }

    final hourText = hour.toString().padLeft(2, "0");

    return "$day/$month/$year $hourText:$minute $amPm";
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

  void _showOptionPicker({
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
                          Expanded(
                            child: Text(
                              option,
                              style: TextStyle(
                                color: isSelected ? TColor.rojo : TColor.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
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
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRepetitionPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        int tempRepetitions = selectedRepetitions;

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                            "Custom Repetitions",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          "$tempRepetitions reps",
                          style: TextStyle(
                            color: TColor.rojo,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Slider(
                      value: tempRepetitions.toDouble(),
                      min: 1,
                      max: 30,
                      divisions: 29,
                      activeColor: TColor.rojo,
                      inactiveColor: TColor.rojo.withOpacity(0.15),
                      onChanged: (value) {
                        setModalState(() {
                          tempRepetitions = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedRepetitions = tempRepetitions;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.rojo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Guardar repeticiones",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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

  void _showWeightPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        double tempWeight = selectedWeight;

        return StatefulBuilder(
          builder: (context, setModalState) {
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
                            "Custom Weights",
                            style: TextStyle(
                              color: TColor.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          tempWeight == 0
                              ? "Sin peso"
                              : "${tempWeight.toStringAsFixed(1)} kg",
                          style: TextStyle(
                            color: TColor.rojo,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Slider(
                      value: tempWeight,
                      min: 0,
                      max: 80,
                      divisions: 80,
                      activeColor: TColor.rojo,
                      inactiveColor: TColor.rojo.withOpacity(0.15),
                      onChanged: (value) {
                        setModalState(() {
                          tempWeight = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedWeight = tempWeight;
                          });
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColor.rojo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          "Guardar peso",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
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

  void _saveSchedule() {
    final selectedDateTime = _buildSelectedDateTime();

    final newSchedule = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "name": selectedWorkout,
      "category": selectedDifficulty == "Beginner"
          ? "Básico"
          : selectedDifficulty == "Intermediate"
              ? "Medio"
              : "Avanzado",
      "duration": "32 min",
      "kcal": "280 kcal",
      "start_time": selectedDateTime,
      "completed": false,
      "difficulty": selectedDifficulty,
      "repetitions": selectedRepetitions,
      "weight": selectedWeight,
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
          "Add Schedule",
          style: TextStyle(
            color: TColor.black,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {},
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
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
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
                      "Time",
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Selected Time",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "Tap to change workout time",
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
                      "Details Workout",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/choose_workout.png",
                      title: "Choose Workout",
                      time: selectedWorkout,
                      color: TColor.lightGray,
                      onPressed: () {
                        _showOptionPicker(
                          title: "Choose Workout",
                          options: workoutOptions,
                          currentValue: selectedWorkout,
                          onSelected: (value) {
                            setState(() {
                              selectedWorkout = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/difficulity.png",
                      title: "Difficulty",
                      time: selectedDifficulty,
                      color: TColor.lightGray,
                      onPressed: () {
                        _showOptionPicker(
                          title: "Choose Difficulty",
                          options: difficultyOptions,
                          currentValue: selectedDifficulty,
                          onSelected: (value) {
                            setState(() {
                              selectedDifficulty = value;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/repetitions.png",
                      title: "Custom Repetitions",
                      time: "$selectedRepetitions reps",
                      color: TColor.lightGray,
                      onPressed: _showRepetitionPicker,
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/repetitions.png",
                      title: "Custom Weights",
                      time: selectedWeight == 0
                          ? "No weight"
                          : "${selectedWeight.toStringAsFixed(1)} kg",
                      color: TColor.lightGray,
                      onPressed: _showWeightPicker,
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
                              "This schedule will be added to your workout agenda.",
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
                title: "Save",
                onPressed: _saveSchedule,
              ),
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
