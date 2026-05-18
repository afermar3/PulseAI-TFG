import 'package:flutter/material.dart';

import '../../widgets/color_extension.dart';
import '../../widgets/common.dart';
import '../../common_widget/icon_title_next_row.dart';
import '../../common_widget/round_button.dart';

class SleepAddAlarmView extends StatefulWidget {
  final DateTime date;

  const SleepAddAlarmView({
    super.key,
    required this.date,
  });

  @override
  State<SleepAddAlarmView> createState() => _SleepAddAlarmViewState();
}

class _SleepAddAlarmViewState extends State<SleepAddAlarmView> {
  late TimeOfDay bedtime;
  late TimeOfDay alarmTime;

  bool vibrate = true;
  bool enabled = true;
  String repeatText = "Lun a Vie";

  @override
  void initState() {
    super.initState();

    bedtime = const TimeOfDay(hour: 22, minute: 30);
    alarmTime = const TimeOfDay(hour: 7, minute: 0);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, "0");
    final minute = time.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }

  DateTime _buildDateTime(TimeOfDay time) {
    return DateTime(
      widget.date.year,
      widget.date.month,
      widget.date.day,
      time.hour,
      time.minute,
    );
  }

  Duration _calculateSleepDuration() {
    DateTime bedDate = _buildDateTime(bedtime);
    DateTime wakeDate = _buildDateTime(alarmTime);

    if (wakeDate.isBefore(bedDate) || wakeDate.isAtSameMomentAs(bedDate)) {
      wakeDate = wakeDate.add(const Duration(days: 1));
    }

    return wakeDate.difference(bedDate);
  }

  String _sleepDurationText() {
    final duration = _calculateSleepDuration();
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return "${hours}h ${minutes}min";
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

  void _showRepeatPicker() {
    final options = [
      "Una vez",
      "Todos los días",
      "Lun a Vie",
      "Fines de semana",
    ];

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
                        "Repetir alarma",
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
                  final isSelected = option == repeatText;

                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      setState(() {
                        repeatText = option;
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

  void _saveAlarm() {
    final newAlarm = {
      "id": DateTime.now().millisecondsSinceEpoch,
      "name": "Alarma",
      "image": "assets/img/alaarm.png",
      "date_time": _buildDateTime(alarmTime),
      "bed_time": _buildDateTime(bedtime),
      "duration": _sleepDurationText(),
      "repeat": repeatText,
      "vibrate": vibrate,
      "enabled": enabled,
    };

    Navigator.pop(context, newAlarm);
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
          "Añadir alarma",
          style: TextStyle(
            color: TColor.black,
            fontSize: 17,
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
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeaderSleepCard(
                      dateText: dateToString(
                        widget.date,
                        formatStr: "E, dd MMMM yyyy",
                      ),
                      durationText: _sleepDurationText(),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Horario",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    IconTitleNextRow(
                      icon: "assets/img/Bed_Add.png",
                      title: "Hora de dormir",
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
                      title: "Hora de despertar",
                      time: _formatTime(alarmTime),
                      color: TColor.lightGray,
                      onPressed: () {
                        _selectTime(
                          initialTime: alarmTime,
                          onSelected: (value) {
                            alarmTime = value;
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/HoursTime.png",
                      title: "Horas de sueño",
                      time: _sleepDurationText(),
                      color: TColor.lightGray,
                      onPressed: () {},
                    ),
                    const SizedBox(height: 10),
                    IconTitleNextRow(
                      icon: "assets/img/Repeat.png",
                      title: "Repetir",
                      time: repeatText,
                      color: TColor.lightGray,
                      onPressed: _showRepeatPicker,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Opciones",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SwitchOptionCard(
                      icon: "assets/img/Vibrate.png",
                      title: "Vibrar al sonar",
                      subtitle: "El móvil vibrará junto con la alarma",
                      value: vibrate,
                      onChanged: (value) {
                        setState(() {
                          vibrate = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    _SwitchOptionCard(
                      icon: "assets/img/alaarm.png",
                      title: "Alarma activa",
                      subtitle: "La alarma aparecerá activa en tu horario",
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
              child: RoundButton(
                title: "Añadir alarma",
                onPressed: _saveAlarm,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSleepCard extends StatelessWidget {
  final String dateText;
  final String durationText;

  const _HeaderSleepCard({
    required this.dateText,
    required this.durationText,
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
              Icons.bedtime_rounded,
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
                  dateText,
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
                    color: TColor.gray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
