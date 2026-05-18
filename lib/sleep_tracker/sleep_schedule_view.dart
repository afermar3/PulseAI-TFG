import 'package:afermar3_tf_ipc/widgets/calendar_agenda/lib/calendar_agenda.dart';
import 'package:afermar3_tf_ipc/sleep_tracker/sleep_add_alarm.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../widgets/color_extension.dart';
import '../../common_widget/round_button.dart';

class SleepScheduleView extends StatefulWidget {
  const SleepScheduleView({super.key});

  @override
  State<SleepScheduleView> createState() => _SleepScheduleViewState();
}

class _SleepScheduleViewState extends State<SleepScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();

  late DateTime _selectedDateAppBBar;

  List<Map<String, dynamic>> sleepArr = [
    {
      "id": 1,
      "name": "Hora de dormir",
      "image": "assets/img/bed.png",
      "date_time": DateTime.now().copyWith(hour: 21, minute: 0),
      "duration": "8h 30min",
      "repeat": "Lun a Vie",
      "vibrate": true,
      "enabled": true,
    },
    {
      "id": 2,
      "name": "Alarma",
      "image": "assets/img/alaarm.png",
      "date_time": DateTime.now().add(const Duration(days: 1)).copyWith(
            hour: 7,
            minute: 0,
          ),
      "duration": "Despertar",
      "repeat": "Lun a Vie",
      "vibrate": true,
      "enabled": true,
    },
  ];

  List<Map<String, dynamic>> selectedDayAlarms = [];

  @override
  void initState() {
    super.initState();
    _selectedDateAppBBar = DateTime.now();
    _loadAlarmsForSelectedDay(refresh: false);
  }

  void _loadAlarmsForSelectedDay({bool refresh = true}) {
    final selectedDate = DateTime(
      _selectedDateAppBBar.year,
      _selectedDateAppBBar.month,
      _selectedDateAppBBar.day,
    );

    selectedDayAlarms = sleepArr.where((alarm) {
      final alarmDate = alarm["date_time"];

      if (alarmDate is! DateTime) return false;

      final alarmDay = DateTime(
        alarmDate.year,
        alarmDate.month,
        alarmDate.day,
      );

      return alarmDay == selectedDate;
    }).toList();

    selectedDayAlarms.sort((a, b) {
      final dateA = a["date_time"] as DateTime;
      final dateB = b["date_time"] as DateTime;
      return dateA.compareTo(dateB);
    });

    if (refresh && mounted) {
      setState(() {});
    }
  }

  Future<void> _openAddAlarm() async {
    final newAlarm = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepAddAlarmView(
          date: _selectedDateAppBBar,
        ),
      ),
    );

    if (newAlarm == null) return;

    if (newAlarm is Map) {
      final alarm = Map<String, dynamic>.from(newAlarm);

      if (alarm["date_time"] is! DateTime) return;

      setState(() {
        sleepArr.add(alarm);
        _loadAlarmsForSelectedDay(refresh: false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Alarma añadida"),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteAlarm(Map<String, dynamic> alarm) {
    Navigator.pop(context);

    setState(() {
      sleepArr.removeWhere((item) => item["id"] == alarm["id"]);
      _loadAlarmsForSelectedDay(refresh: false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Alarma eliminada"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleAlarm(Map<String, dynamic> alarm, bool value) {
    setState(() {
      final index = sleepArr.indexWhere((item) => item["id"] == alarm["id"]);

      if (index != -1) {
        sleepArr[index]["enabled"] = value;
      }

      _loadAlarmsForSelectedDay(refresh: false);
    });
  }

  void _openAlarmDetail(Map<String, dynamic> alarm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _SleepAlarmBottomSheet(
          alarm: alarm,
          onDelete: () {
            _deleteAlarm(alarm);
          },
          onToggle: (value) {
            Navigator.pop(context);
            _toggleAlarm(alarm, value);
          },
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }

  String _sleepSummary() {
    if (selectedDayAlarms.isEmpty) {
      return "No tienes alarmas programadas para este día";
    }

    final alarm = selectedDayAlarms.firstWhere(
      (item) => item["duration"] != null,
      orElse: () => selectedDayAlarms.first,
    );

    return alarm["duration"].toString();
  }

  double _sleepRatio() {
    final text = _sleepSummary();

    final hourMatch = RegExp(r'(\d+)h').firstMatch(text);
    final minMatch = RegExp(r'(\d+)min').firstMatch(text);

    final hours = int.tryParse(hourMatch?.group(1) ?? "0") ?? 0;
    final minutes = int.tryParse(minMatch?.group(1) ?? "0") ?? 0;

    final totalMinutes = (hours * 60) + minutes;

    if (totalMinutes == 0) return 0.0;

    return (totalMinutes / 510).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
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
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Horario de sueño",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
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
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SleepHeaderCard(
              media: media,
              title: "Objetivo de descanso",
              duration: "8h 30min",
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Tu horario",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 10),
            CalendarAgenda(
              controller: _calendarAgendaControllerAppBar,
              appbar: false,
              selectedDayPosition: SelectedDayPosition.center,
              leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowLeft.png",
                  width: 15,
                  height: 15,
                ),
              ),
              training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowRight.png",
                  width: 15,
                  height: 15,
                ),
              ),
              weekDay: WeekDay.short,
              dayNameFontSize: 12,
              dayNumberFontSize: 16,
              dayBGColor: Colors.grey.withOpacity(0.15),
              titleSpaceBetween: 15,
              backgroundColor: Colors.transparent,
              fullCalendarScroll: FullCalendarScroll.horizontal,
              fullCalendarDay: WeekDay.short,
              selectedDateColor: Colors.white,
              dateColor: Colors.black,
              locale: 'es',
              initialDate: DateTime.now(),
              calendarEventColor: TColor.primaryColor2,
              firstDate: DateTime.now().subtract(const Duration(days: 140)),
              lastDate: DateTime.now().add(const Duration(days: 60)),
              events: sleepArr
                  .where((alarm) => alarm["date_time"] is DateTime)
                  .map((alarm) => alarm["date_time"] as DateTime)
                  .toList(),
              onDateSelected: (date) {
                setState(() {
                  _selectedDateAppBBar = date;
                  _loadAlarmsForSelectedDay(refresh: false);
                });
              },
              selectedDayLogo: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${selectedDayAlarms.length} alarmas",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _openAddAlarm,
                    child: Text(
                      "Añadir",
                      style: TextStyle(
                        color: TColor.rojo,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            selectedDayAlarms.isEmpty
                ? _EmptySleepView(
                    onAdd: _openAddAlarm,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: selectedDayAlarms.length,
                    itemBuilder: (context, index) {
                      final alarm = selectedDayAlarms[index];

                      return _SleepAlarmCard(
                        alarm: alarm,
                        time: _formatTime(alarm["date_time"] as DateTime),
                        onTap: () {
                          _openAlarmDetail(alarm);
                        },
                        onToggle: (value) {
                          _toggleAlarm(alarm, value);
                        },
                      );
                    },
                  ),
            _SleepProgressCard(
              media: media,
              summary: _sleepSummary(),
              ratio: _sleepRatio(),
            ),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: _openAddAlarm,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.primaryG),
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: TColor.rojo.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.add_rounded,
            size: 28,
            color: TColor.white,
          ),
        ),
      ),
    );
  }
}

class _SleepHeaderCard extends StatelessWidget {
  final Size media;
  final String title;
  final String duration;

  const _SleepHeaderCard({
    required this.media,
    required this.title,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(20),
      height: media.width * 0.42,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.rojo.withOpacity(0.12),
            TColor.rojo.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  duration,
                  style: TextStyle(
                    color: TColor.rojo,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 112,
                  height: 35,
                  child: RoundButton(
                    title: "Ver consejos",
                    fontSize: 12,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            "assets/img/sleep_schedule.png",
            width: media.width * 0.35,
          ),
        ],
      ),
    );
  }
}

class _SleepAlarmCard extends StatelessWidget {
  final Map<String, dynamic> alarm;
  final String time;
  final VoidCallback onTap;
  final Function(bool value) onToggle;

  const _SleepAlarmCard({
    required this.alarm,
    required this.time,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = alarm["enabled"] as bool? ?? true;

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
                color: enabled
                    ? TColor.rojo.withOpacity(0.10)
                    : Colors.grey.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Image.asset(
                alarm["image"].toString(),
                width: 30,
                height: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alarm["name"].toString(),
                    style: TextStyle(
                      color: enabled ? TColor.black : TColor.gray,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${alarm["repeat"]} · ${alarm["duration"]}",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: TColor.rojo,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: TextStyle(
                          color: TColor.rojo,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.75,
              child: Switch(
                value: enabled,
                activeColor: TColor.white,
                activeTrackColor: TColor.rojo,
                inactiveThumbColor: TColor.white,
                inactiveTrackColor: Colors.grey.shade300,
                onChanged: onToggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepAlarmBottomSheet extends StatelessWidget {
  final Map<String, dynamic> alarm;
  final VoidCallback onDelete;
  final Function(bool value) onToggle;

  const _SleepAlarmBottomSheet({
    required this.alarm,
    required this.onDelete,
    required this.onToggle,
  });

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");

    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final dateTime = alarm["date_time"] as DateTime;
    final enabled = alarm["enabled"] as bool? ?? true;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
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
            const SizedBox(height: 22),
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: TColor.rojo.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Image.asset(
                    alarm["image"].toString(),
                    width: 30,
                    height: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm["name"].toString(),
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        alarm["repeat"].toString(),
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _SleepInfoBox(
                    icon: Icons.access_time_rounded,
                    value: _formatTime(dateTime),
                    label: "Hora",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SleepInfoBox(
                    icon: Icons.bedtime_rounded,
                    value: alarm["duration"].toString(),
                    label: "Sueño",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SleepInfoBox(
                    icon: Icons.vibration_rounded,
                    value: (alarm["vibrate"] as bool? ?? false) ? "Sí" : "No",
                    label: "Vibración",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  onToggle(!enabled);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: enabled ? TColor.rojo : Colors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  enabled ? "Desactivar alarma" : "Activar alarma",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text("Eliminar alarma"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SleepInfoBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SleepInfoBox({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.black,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
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
    );
  }
}

class _SleepProgressCard extends StatelessWidget {
  final Size media;
  final String summary;
  final double ratio;

  const _SleepProgressCard({
    required this.media,
    required this.summary,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (ratio * 100).round();

    return Container(
      width: double.maxFinite,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            summary,
            style: TextStyle(
              color: TColor.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 15),
          Stack(
            alignment: Alignment.center,
            children: [
              SimpleAnimationProgressBar(
                height: 15,
                width: media.width - 80,
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.purple,
                ratio: ratio,
                direction: Axis.horizontal,
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(seconds: 3),
                borderRadius: BorderRadius.circular(7.5),
                gradientColor: LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              Text(
                "$percentage%",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySleepView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptySleepView({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.bedtime_rounded,
              color: TColor.rojo,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "No hay alarmas",
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Todavía no tienes alarmas de sueño programadas para este día.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text("Añadir alarma"),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.rojo,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
