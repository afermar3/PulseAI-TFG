import 'package:afermar3_tf_ipc/widgets/calendar_agenda/lib/calendar_agenda.dart';
import 'package:afermar3_tf_ipc/widgets/color_extension.dart';
import 'package:afermar3_tf_ipc/widgets/common.dart';
import 'package:flutter/material.dart';

import 'add_schedule_view.dart';

class WorkoutScheduleView extends StatefulWidget {
  const WorkoutScheduleView({super.key});

  @override
  State<WorkoutScheduleView> createState() => _WorkoutScheduleViewState();
}

class _WorkoutScheduleViewState extends State<WorkoutScheduleView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar =
      CalendarAgendaController();

  late DateTime _selectedDate;

  List<Map<String, dynamic>> eventArr = [
    {
      "id": 1,
      "name": "Full Body",
      "category": "Fuerza",
      "duration": "32 min",
      "kcal": "280 kcal",
      "start_time": DateTime.now().copyWith(hour: 7, minute: 30),
      "completed": false,
    },
    {
      "id": 2,
      "name": "Tren superior",
      "category": "Fuerza",
      "duration": "40 min",
      "kcal": "330 kcal",
      "start_time": DateTime.now().copyWith(hour: 12, minute: 0),
      "completed": false,
    },
    {
      "id": 3,
      "name": "Abdominales",
      "category": "Core",
      "duration": "20 min",
      "kcal": "180 kcal",
      "start_time": DateTime.now().add(const Duration(days: 1)).copyWith(
            hour: 18,
            minute: 30,
          ),
      "completed": false,
    },
  ];

  List<Map<String, dynamic>> selectedDayEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadEventsForSelectedDay(refresh: false);
  }

  void _loadEventsForSelectedDay({bool refresh = true}) {
    final selectedStartDate = dateToStartDate(_selectedDate);

    selectedDayEvents = eventArr.where((event) {
      final eventDate = event["start_time"];

      if (eventDate is! DateTime) {
        return false;
      }

      return dateToStartDate(eventDate) == selectedStartDate;
    }).toList();

    selectedDayEvents.sort((a, b) {
      final dateA = a["start_time"] as DateTime;
      final dateB = b["start_time"] as DateTime;
      return dateA.compareTo(dateB);
    });

    if (refresh && mounted) {
      setState(() {});
    }
  }

  Future<void> _openAddSchedule() async {
    final newSchedule = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScheduleView(
          date: _selectedDate,
        ),
      ),
    );

    if (newSchedule == null) return;

    if (newSchedule is Map) {
      final newEvent = Map<String, dynamic>.from(newSchedule);

      if (newEvent["start_time"] is! DateTime) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: la fecha del entrenamiento no es válida"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() {
        eventArr.add(newEvent);
        _loadEventsForSelectedDay(refresh: false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${newEvent["name"]} añadido a la agenda"),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _markWorkoutDone(Map<String, dynamic> event) {
    Navigator.pop(context);

    setState(() {
      final index = eventArr.indexWhere((item) => item["id"] == event["id"]);

      if (index != -1) {
        eventArr[index]["completed"] = true;
      }

      _loadEventsForSelectedDay(refresh: false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${event["name"]} marcado como completado"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteWorkout(Map<String, dynamic> event) {
    Navigator.pop(context);

    setState(() {
      eventArr.removeWhere((item) => item["id"] == event["id"]);
      _loadEventsForSelectedDay(refresh: false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${event["name"]} eliminado"),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openWorkoutDetail(Map<String, dynamic> event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return _WorkoutEventBottomSheet(
          event: event,
          onMarkDone: () {
            _markWorkoutDone(event);
          },
          onDelete: () {
            _deleteWorkout(event);
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

  String _formatSelectedDate(DateTime date) {
    return dateToString(date, formatStr: "dd MMMM yyyy");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
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
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: TColor.black,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          "Agenda de entrenamientos",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.more_horiz_rounded,
                  color: TColor.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
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
            dayBGColor: Colors.grey.withOpacity(0.12),
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
            lastDate: DateTime.now().add(const Duration(days: 90)),
            events: eventArr
                .where((event) => event["start_time"] is DateTime)
                .map((event) => event["start_time"] as DateTime)
                .toList(),
            onDateSelected: (date) {
              setState(() {
                _selectedDate = date;
                _loadEventsForSelectedDay(refresh: false);
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
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _formatSelectedDate(_selectedDate),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: TColor.primaryColor1.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    "${selectedDayEvents.length} entrenamientos",
                    style: TextStyle(
                      color: TColor.primaryColor1,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedDayEvents.isEmpty
                ? _EmptyScheduleView(
                    onAdd: _openAddSchedule,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 8, 22, 110),
                    itemCount: selectedDayEvents.length,
                    itemBuilder: (context, index) {
                      final event = selectedDayEvents[index];

                      return _ScheduleWorkoutCard(
                        event: event,
                        time: _formatTime(event["start_time"] as DateTime),
                        onTap: () {
                          _openWorkoutDetail(event);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: _openAddSchedule,
        child: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: TColor.primaryG),
            borderRadius: BorderRadius.circular(29),
            boxShadow: [
              BoxShadow(
                color: TColor.primaryColor1.withOpacity(0.35),
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

class _ScheduleWorkoutCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String time;
  final VoidCallback onTap;

  const _ScheduleWorkoutCard({
    required this.event,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final completed = event["completed"] as bool? ?? false;

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
                color: completed
                    ? Colors.green.withOpacity(0.12)
                    : TColor.primaryColor1.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                completed
                    ? Icons.check_circle_rounded
                    : Icons.fitness_center_rounded,
                color: completed ? Colors.green : TColor.primaryColor1,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event["name"].toString(),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${event["category"]} · ${event["duration"]} · ${event["kcal"]}",
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
                        color: TColor.primaryColor1,
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        time,
                        style: TextStyle(
                          color: TColor.primaryColor1,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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

class _WorkoutEventBottomSheet extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onMarkDone;
  final VoidCallback onDelete;

  const _WorkoutEventBottomSheet({
    required this.event,
    required this.onMarkDone,
    required this.onDelete,
  });

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, "0");
    final minute = date.minute.toString().padLeft(2, "0");
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    final startTime = event["start_time"] as DateTime;
    final completed = event["completed"] as bool? ?? false;

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
                    color: completed
                        ? Colors.green.withOpacity(0.12)
                        : TColor.primaryColor1.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    completed
                        ? Icons.check_circle_rounded
                        : Icons.fitness_center_rounded,
                    color: completed ? Colors.green : TColor.primaryColor1,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event["name"].toString(),
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        event["category"].toString(),
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
                  child: _WorkoutInfoBox(
                    icon: Icons.access_time_rounded,
                    value: _formatTime(startTime),
                    label: "Hora",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WorkoutInfoBox(
                    icon: Icons.timer_outlined,
                    value: event["duration"].toString(),
                    label: "Duración",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _WorkoutInfoBox(
                    icon: Icons.local_fire_department_rounded,
                    value: event["kcal"].toString(),
                    label: "Calorías",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: completed ? null : onMarkDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                  disabledBackgroundColor: Colors.green.withOpacity(0.18),
                  foregroundColor: Colors.white,
                  disabledForegroundColor: Colors.green,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  completed ? "Entrenamiento completado" : "Marcar como hecho",
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
                label: const Text("Eliminar entrenamiento"),
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

class _WorkoutInfoBox extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WorkoutInfoBox({
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
            color: TColor.primaryColor1,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.black,
              fontSize: 13,
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

class _EmptyScheduleView extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyScheduleView({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(22),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: TColor.primaryColor1.withOpacity(0.10),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: TColor.primaryColor1,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            "No hay entrenamientos",
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Todavía no tienes ningún entrenamiento programado para este día.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 13,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text("Añadir entrenamiento"),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.primaryColor1,
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
