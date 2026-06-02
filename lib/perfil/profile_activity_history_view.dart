import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:flutter/material.dart';

class ProfileActivityHistoryView extends StatefulWidget {
  const ProfileActivityHistoryView({super.key});

  @override
  State<ProfileActivityHistoryView> createState() =>
      _ProfileActivityHistoryViewState();
}

class _ProfileActivityHistoryViewState
    extends State<ProfileActivityHistoryView> {
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedFilter = "ALL";

  List<Map<String, dynamic>> _items = [];

  final List<Map<String, String>> _filters = [
    {
      "label": "Todo",
      "value": "ALL",
    },
    {
      "label": "Entrenos",
      "value": "WORKOUT",
    },
    {
      "label": "Sueño",
      "value": "SLEEP",
    },
    {
      "label": "Fotos",
      "value": "PHOTO",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final allItems = <Map<String, dynamic>>[];

      try {
        final workoutSessions =
            await WorkoutSessionService.getMyWorkoutSessions();

        for (final item in workoutSessions) {
          if (item is! Map) continue;

          final session = Map<String, dynamic>.from(item);
          final completedAt = _parseDate(session["completed_at"]);

          allItems.add({
            "type": "WORKOUT",
            "title": _formatWorkoutTitle(session),
            "subtitle": _formatWorkoutSubtitle(session),
            "date": completedAt,
            "dateText": completedAt == null
                ? "Fecha no disponible"
                : _formatDate(completedAt),
            "icon": Icons.fitness_center_rounded,
            "color": TColor.rojo,
            "payload": session,
          });
        }
      } catch (_) {}

      try {
        final sleepSessions = await SleepService.getMySleepSessions();

        for (final item in sleepSessions) {
          if (item is! Map) continue;

          final sleep = Map<String, dynamic>.from(item);

          final startTime = _parseDate(sleep["start_time"]);
          final endTime = _parseDate(sleep["end_time"]);
          final referenceDate = endTime ?? startTime;
          final duration = _toInt(sleep["duration_minutes"]) ?? 0;

          allItems.add({
            "type": "SLEEP",
            "title": "Sueño registrado",
            "subtitle": duration > 0
                ? "Duración: ${_formatMinutesAsHours(duration)}"
                : "Sesión de sueño sin duración cerrada",
            "date": referenceDate,
            "dateText": referenceDate == null
                ? "Fecha no disponible"
                : _formatDate(referenceDate),
            "icon": Icons.bedtime_rounded,
            "color": Colors.indigo,
            "payload": sleep,
          });
        }
      } catch (_) {}

      try {
        final photos = await ProgressPhotoService.getMyProgressPhotos();

        for (final photo in photos) {
          final createdAt = _parseDate(photo["created_at"]);

          allItems.add({
            "type": "PHOTO",
            "title": "Foto de progreso",
            "subtitle": _photoTypeLabel(photo["photo_type"]?.toString()),
            "date": createdAt,
            "dateText": createdAt == null
                ? "Fecha no disponible"
                : _formatDate(createdAt),
            "icon": Icons.photo_camera_rounded,
            "color": Colors.purple,
            "payload": photo,
          });
        }
      } catch (_) {}

      allItems.sort((a, b) {
        final aDate = a["date"] as DateTime?;
        final bDate = b["date"] as DateTime?;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        _items = allItems;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _filteredItems() {
    if (_selectedFilter == "ALL") {
      return _items;
    }

    return _items.where((item) {
      return item["type"] == _selectedFilter;
    }).toList();
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, "0");
    final month = date.month.toString().padLeft(2, "0");
    final year = date.year.toString();

    return "$day/$month/$year";
  }

  String _formatMinutesAsHours(int minutes) {
    if (minutes <= 0) {
      return "0min";
    }

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours <= 0) {
      return "${mins}min";
    }

    if (mins == 0) {
      return "${hours}h";
    }

    return "${hours}h ${mins}min";
  }

  String _formatWorkoutTitle(Map<String, dynamic> session) {
    final workoutTitle = session["workout_title"]?.toString() ?? "Entrenamiento";
    final dayNumber = session["day_number"];
    final dayName = session["day_name"]?.toString();

    if (dayNumber != null && dayName != null && dayName.trim().isNotEmpty) {
      return "Día $dayNumber - $dayName";
    }

    return workoutTitle;
  }

  String _formatWorkoutSubtitle(Map<String, dynamic> session) {
    final completedExercises = _toInt(session["completed_exercises"]) ?? 0;
    final totalExercises = _toInt(session["total_exercises"]) ?? 0;
    final duration = _toInt(session["duration_minutes"]) ?? 0;

    final exercisesText = totalExercises > 0
        ? "$completedExercises/$totalExercises ejercicios"
        : "$completedExercises ejercicios";

    return "$exercisesText · $duration min";
  }

  String _photoTypeLabel(String? value) {
    switch (value) {
      case "FRONT":
        return "Foto frontal";
      case "SIDE":
        return "Foto lateral";
      case "BACK":
        return "Foto de espalda";
      case "OTHER":
        return "Foto personal";
      default:
        return "Foto de progreso";
    }
  }

  String _filterSubtitle() {
    final total = _items.length;
    final filtered = _filteredItems().length;

    if (_selectedFilter == "ALL") {
      return "$total registros en total";
    }

    return "$filtered registros filtrados";
  }

  void _openItemDetail(Map<String, dynamic> item) {
    final title = item["title"]?.toString() ?? "Actividad";
    final subtitle = item["subtitle"]?.toString() ?? "";
    final dateText = item["dateText"]?.toString() ?? "";
    final icon = item["icon"] as IconData? ?? Icons.history_rounded;
    final color = item["color"] as Color? ?? TColor.rojo;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.blanco,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: TColor.negro,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.info_outline_rounded,
                title: "Detalle",
                value: subtitle,
                color: color,
              ),
              const SizedBox(height: 12),
              _DetailRow(
                icon: Icons.calendar_month_rounded,
                title: "Fecha",
                value: dateText,
                color: color,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Entendido",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.rojo.withOpacity(0.16),
            TColor.rojo.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.10),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.12),
              borderRadius: BorderRadius.circular(21),
            ),
            child: Icon(
              Icons.history_rounded,
              color: TColor.rojo,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Historial de actividad",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _filterSubtitle(),
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
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

  Widget _buildFilters() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (context, index) {
          return const SizedBox(width: 10);
        },
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = _selectedFilter == filter["value"];

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              setState(() {
                _selectedFilter = filter["value"]!;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected ? TColor.rojo : TColor.rojo.withOpacity(0.08),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                filter["label"]!,
                style: TextStyle(
                  color: selected ? Colors.white : TColor.rojo,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TColor.blanco,
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
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            color: TColor.rojo,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            "Sin actividad todavía",
            style: TextStyle(
              color: TColor.negro,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Cuando completes entrenamientos, registres sueño o subas fotos, aparecerán aquí.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.gris,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage ?? "No se ha podido cargar el historial.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _loadHistory,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    final filteredItems = _filteredItems();

    if (filteredItems.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filteredItems.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        final item = filteredItems[index];

        return _HistoryItemCard(
          item: item,
          onTap: () {
            _openItemDetail(item);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColor.negro,
          ),
        ),
        title: Text(
          "Historial",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _loadHistory,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: TColor.negro,
                  size: 21,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: TColor.rojo,
                ),
              )
            : RefreshIndicator(
                color: TColor.rojo,
                onRefresh: _loadHistory,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        _buildErrorState()
                      else ...[
                        _buildHeaderCard(),
                        const SizedBox(height: 18),
                        _buildFilters(),
                        const SizedBox(height: 20),
                        _buildHistoryList(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const _HistoryItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = item["title"]?.toString() ?? "Actividad";
    final subtitle = item["subtitle"]?.toString() ?? "";
    final dateText = item["dateText"]?.toString() ?? "";
    final icon = item["icon"] as IconData? ?? Icons.history_rounded;
    final color = item["color"] as Color? ?? TColor.rojo;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: TColor.blanco,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.045),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: color,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateText,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: TColor.gris,
              size: 15,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: color,
            size: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: TColor.gris,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: TColor.negro,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}