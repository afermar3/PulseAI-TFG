import 'package:afermar3_tf_ipc/services/sleep_goal_service.dart';
import 'package:flutter/material.dart';

import '../../widgets/color_extension.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';

class SleepAddAlarmView extends StatefulWidget {
  final String goalType;
  final Map<String, dynamic>? initialGoal;

  const SleepAddAlarmView({
    super.key,
    required this.goalType,
    this.initialGoal,
  });

  @override
  State<SleepAddAlarmView> createState() => _SleepAddAlarmViewState();
}

class _SleepAddAlarmViewState extends State<SleepAddAlarmView> {
  late TimeOfDay bedtime;
  late TimeOfDay wakeTime;

  bool enabled = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    bedtime = _parseTimeOfDay(
      widget.initialGoal?["bed_time"],
      fallback: _defaultBedtime(),
    );

    wakeTime = _parseTimeOfDay(
      widget.initialGoal?["wake_time"],
      fallback: _defaultWakeTime(),
    );

    enabled = widget.initialGoal?["enabled"] as bool? ?? true;
  }

  TimeOfDay _defaultBedtime() {
    switch (widget.goalType) {
      case "WEEKENDS":
        return const TimeOfDay(hour: 1, minute: 0);
      case "WEEKDAYS":
        return const TimeOfDay(hour: 23, minute: 30);
      case "ALL_DAYS":
      default:
        return const TimeOfDay(hour: 23, minute: 30);
    }
  }

  TimeOfDay _defaultWakeTime() {
    switch (widget.goalType) {
      case "WEEKENDS":
        return const TimeOfDay(hour: 9, minute: 30);
      case "WEEKDAYS":
        return const TimeOfDay(hour: 7, minute: 0);
      case "ALL_DAYS":
      default:
        return const TimeOfDay(hour: 7, minute: 30);
    }
  }

  TimeOfDay _parseTimeOfDay(
    dynamic value, {
    required TimeOfDay fallback,
  }) {
    if (value == null) return fallback;

    final parts = value.toString().split(":");

    if (parts.length != 2) return fallback;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return fallback;
    if (hour < 0 || hour > 23) return fallback;
    if (minute < 0 || minute > 59) return fallback;

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");

    return "$hour:$minute";
  }

  Duration _calculateSleepDuration() {
    DateTime bedDate = DateTime(
      2026,
      1,
      1,
      bedtime.hour,
      bedtime.minute,
    );

    DateTime wakeDate = DateTime(
      2026,
      1,
      1,
      wakeTime.hour,
      wakeTime.minute,
    );

    if (wakeDate.isBefore(bedDate) || wakeDate.isAtSameMomentAs(bedDate)) {
      wakeDate = wakeDate.add(const Duration(days: 1));
    }

    return wakeDate.difference(bedDate);
  }

  int _targetMinutes() {
    return _calculateSleepDuration().inMinutes;
  }

  String _sleepDurationText() {
    final duration = _calculateSleepDuration();
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    if (hours <= 0) {
      return "${minutes}min";
    }

    if (minutes == 0) {
      return "${hours}h";
    }

    return "${hours}h ${minutes}min";
  }

  String _goalTypeTitle() {
    return SleepGoalService.goalTypeLabel(widget.goalType);
  }

  String _goalTypeDescription() {
    return SleepGoalService.goalTypeDescription(widget.goalType);
  }

  Future<void> _selectTime({
    required TimeOfDay initialTime,
    required Function(TimeOfDay value) onSelected,
  }) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
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
        onSelected(pickedTime);
      });
    }
  }

  Future<void> _saveGoal() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await SleepGoalService.saveSleepGoal(
        goalType: widget.goalType,
        bedTime: _formatTime(bedtime),
        wakeTime: _formatTime(wakeTime),
        targetMinutes: _targetMinutes(),
        enabled: enabled,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Objetivo de sueño guardado"),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialGoal != null;

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
          isEditing ? "Editar objetivo" : "Configurar objetivo",
          style: TextStyle(
            color: TColor.black,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderSleepCard(
                      title: _goalTypeTitle(),
                      durationText: _sleepDurationText(),
                      subtitle: _goalTypeDescription(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Horario objetivo",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    IconTitleNextRow(
                      icon: "assets/img/Bed_Add.png",
                      title: "Hora objetivo para dormir",
                      time: _formatTime(bedtime),
                      color: TColor.lightGray,
                      onPressed: () {
                        _selectTime(
                          initialTime: bedtime,
                          onSelected: (value) {
                            bedtime = value;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/alaarm.png",
                      title: "Hora objetivo para despertar",
                      time: _formatTime(wakeTime),
                      color: TColor.lightGray,
                      onPressed: () {
                        _selectTime(
                          initialTime: wakeTime,
                          onSelected: (value) {
                            wakeTime = value;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/HoursTime.png",
                      title: "Objetivo calculado",
                      time: _sleepDurationText(),
                      color: TColor.lightGray,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Estado",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SwitchOptionCard(
                      icon: "assets/img/alaarm.png",
                      title: "Objetivo activo",
                      subtitle:
                          "Si está activo, se usará para comparar tu sueño real.",
                      value: enabled,
                      onChanged: (value) {
                        setState(() {
                          enabled = value;
                        });
                      },
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
              child: SizedBox(
                height: 52,
                child: RoundButton(
                  title: _isSaving
                      ? "Guardando..."
                      : isEditing
                          ? "Guardar cambios"
                          : "Guardar objetivo",
                  onPressed: _isSaving ? () {} : _saveGoal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSleepCard extends StatelessWidget {
  final String title;
  final String durationText;
  final String subtitle;

  const _HeaderSleepCard({
    required this.title,
    required this.durationText,
    required this.subtitle,
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
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.flag_rounded,
              color: TColor.rojo,
              size: 30,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  durationText,
                  style: TextStyle(
                    color: TColor.rojo,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 11,
                    height: 1.25,
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

class _SwitchOptionCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final bool value;
  final Function(bool value) onChanged;

  const _SwitchOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: TColor.lightGray,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Image.asset(
            icon,
            width: 24,
            height: 24,
            fit: BoxFit.contain,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.78,
            child: Switch(
              value: value,
              activeColor: TColor.white,
              activeTrackColor: TColor.rojo,
              inactiveThumbColor: TColor.white,
              inactiveTrackColor: Colors.grey.shade300,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}