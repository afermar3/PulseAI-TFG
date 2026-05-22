import 'package:afermar3_tf_ipc/services/scheduled_workout_service.dart';
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

  List<Map<String, dynamic>> eventArr = [];
  List<Map<String, dynamic>> selectedDayEvents = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _loadScheduledWorkouts();
  }

  Future<void> _loadScheduledWorkouts() async {
    try {
      final result = await ScheduledWorkoutService.getMyScheduledWorkouts();

      final events = result.map((item) {
        return _mapScheduledWorkoutToEvent(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        eventArr = events;
        isLoading = false;
        errorMessage = null;
        _loadEventsForSelectedDay(refresh: false);
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Map<String, dynamic> _mapScheduledWorkoutToEvent(
    Map<String, dynamic> item,
  ) {
    final rawDate = item["scheduled_date"]?.toString();

    DateTime parsedDate;

    try {
      parsedDate = DateTime.parse(rawDate ?? "");
    } catch (_) {
      parsedDate = DateTime.now();
    }

    final durationMinutes = item["duration_minutes"] as int? ?? 45;
    final estimatedKcal = durationMinutes * 6;

    return {
      "id": item["id"],
      "saved_workout_id": item["saved_workout_id"],
      "completed_session_id": item["completed_session_id"],
      "name": item["workout_title"]?.toString() ?? "Entrenamiento",
      "category": item["day_name"]?.toString() ?? "Rutina",
      "day_number": item["day_number"],
      "day_name": item["day_name"],
      "duration": "$durationMinutes min",
      "duration_minutes": durationMinutes,
      "kcal": "$estimatedKcal kcal",
      "start_time": parsedDate,
      "completed": item["completed"] == true,
    };
  }

  int _extractMinutes(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    return int.tryParse(match?.group(0) ?? "") ?? 45;
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

      try {
        final startTime = newEvent["start_time"] as DateTime;

        final durationMinutes = newEvent["duration_minutes"] as int? ??
            _extractMinutes(newEvent["duration"]?.toString() ?? "45 min");

        final created = await ScheduledWorkoutService.createScheduledWorkout(
          savedWorkoutId: newEvent["saved_workout_id"] as int?,
          workoutTitle: newEvent["name"]?.toString() ?? "Entrenamiento",
          dayNumber: newEvent["day_number"] as int?,
          dayName: newEvent["day_name"]?.toString() ??
              newEvent["category"]?.toString() ??
              newEvent["name"]?.toString(),
          scheduledDate: startTime,
          durationMinutes: durationMinutes,
        );

        final createdEvent = _mapScheduledWorkoutToEvent(created);

        if (!mounted) return;

        setState(() {
          eventArr.add(createdEvent);
          _loadEventsForSelectedDay(refresh: false);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("${createdEvent["name"]} añadido a la agenda"),
            backgroundColor: TColor.rojo,
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
  }

  Future<void> _markWorkoutDone(Map<String, dynamic> event) async {
    Navigator.pop(context);

    try {
      final updated = await ScheduledWorkoutService.completeScheduledWorkout(
        event["id"] as int,
      );

      final updatedEvent = _mapScheduledWorkoutToEvent(updated);

      if (!mounted) return;

      setState(() {
        final index = eventArr.indexWhere(
          (item) => item["id"] == updatedEvent["id"],
        );

        if (index != -1) {
          eventArr[index] = updatedEvent;
        }

        _loadEventsForSelectedDay(refresh: false);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${updatedEvent["name"]} marcado como completado"),
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

  Future<void> _deleteWorkout(Map<String, dynamic> event) async {
    Navigator.pop(context);

    try {
      await ScheduledWorkoutService.deleteScheduledWorkout(
        event["id"] as int,
      );

      if (!mounted) return;

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
              onTap: _loadScheduledWorkouts,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: TColor.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: TColor.rojo,
              ),
            )
          : errorMessage != null
              ? _ScheduleErrorView(
                  message: errorMessage!,
                  onRetry: _loadScheduledWorkouts,
                )
              : Column(
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
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 140),
                      ),
                      lastDate: DateTime.now().add(
                        const Duration(days: 90),
                      ),
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
                              padding:
                                  const EdgeInsets.fromLTRB(22, 8, 22, 110),
                              itemCount: selectedDayEvents.length,
                              itemBuilder: (context, index) {
                                final event = selectedDayEvents[index];

                                return _ScheduleWorkoutCard(
                                  event: event,
                                  time: _formatTime(
                                    event["start_time"] as DateTime,
                                  ),
                                  onTap: () {
                                    _openWorkoutDetail(event);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
      floatingActionButton: isLoading || errorMessage != null
          ? null
          : InkWell(
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
            color: completed ? Colors.green : Colors.grey.shade100,
            width: completed ? 1.4 : 1,
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
                      if (completed) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            "Completado",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
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

class _ScheduleErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ScheduleErrorView({
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
              "No se pudo cargar la agenda",
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