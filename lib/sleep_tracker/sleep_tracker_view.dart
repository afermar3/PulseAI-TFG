import 'package:afermar3_tf_ipc/services/sleep_goal_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_service.dart';
import 'package:afermar3_tf_ipc/sleep_tracker/sleep_schedule_view.dart';
import 'package:flutter/material.dart';

import '../../widgets/color_extension.dart';

class SleepTrackerView extends StatefulWidget {
  const SleepTrackerView({super.key});

  @override
  State<SleepTrackerView> createState() => _SleepTrackerViewState();
}

class _SleepTrackerViewState extends State<SleepTrackerView> {
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _activeSleepSession;
  Map<String, dynamic>? _latestSleepSession;
  Map<String, dynamic>? _sleepGoal;

  List<dynamic> _sleepSessions = [];

  @override
  void initState() {
    super.initState();
    _loadSleepData();
  }

  Future<void> _loadSleepData() async {
    try {
      final active = await SleepService.getActiveSleepSession();
      final latest = await SleepService.getLatestSleepSession();
      final sessions = await SleepService.getMySleepSessions();
      final goal = await SleepGoalService.getMySleepGoal();

      if (!mounted) return;

      setState(() {
        _activeSleepSession = active;
        _latestSleepSession = latest;
        _sleepSessions = sessions;
        _sleepGoal = goal;
        _errorMessage = null;
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

  Future<void> _startSleep() async {
    if (_isActionLoading) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      await SleepService.startSleepSession();
      await _loadSleepData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Sueño iniciado. Buen descanso."),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  Future<void> _finishSleep({
    required String quality,
    String? notes,
  }) async {
    if (_activeSleepSession == null || _isActionLoading) return;

    final sleepSessionId = _toInt(_activeSleepSession!["id"]);

    if (sleepSessionId == null) {
      _showError("No se ha podido identificar la sesión de sueño activa");
      return;
    }

    setState(() {
      _isActionLoading = true;
    });

    try {
      await SleepService.finishSleepSession(
        sleepSessionId: sleepSessionId,
        quality: quality,
        notes: notes,
      );

      await _loadSleepData();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Sueño finalizado correctamente"),
          backgroundColor: TColor.rojo,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError(e.toString().replaceFirst("Exception: ", ""));
    } finally {
      if (mounted) {
        setState(() {
          _isActionLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
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

  bool _hasEnabledGoal() {
    return _sleepGoal != null && _sleepGoal?["enabled"] == true;
  }

  int _targetSleepMinutes() {
    if (_hasEnabledGoal()) {
      final target = _toInt(_sleepGoal?["target_minutes"]);

      if (target != null && target > 0) {
        return target;
      }
    }

    return 480;
  }

  String _targetSleepLabel() {
    if (_hasEnabledGoal()) {
      return "Tu objetivo";
    }

    return "Recomendado";
  }

  String _targetSleepDurationText() {
    return _formatDurationFromMinutes(_targetSleepMinutes());
  }

  String _goalScheduleText() {
    if (!_hasEnabledGoal()) {
      return "Configura un objetivo personalizado";
    }

    final bedTime = _sleepGoal?["bed_time"]?.toString() ?? "--:--";
    final wakeTime = _sleepGoal?["wake_time"]?.toString() ?? "--:--";
    final repeat = _sleepGoal?["repeat"]?.toString() ?? "Sin repetición";

    return "$bedTime - $wakeTime · $repeat";
  }

  String _formatTime(DateTime? date) {
    if (date == null) return "--:--";

    final local = date.toLocal();
    final hour = local.hour.toString().padLeft(2, "0");
    final minute = local.minute.toString().padLeft(2, "0");

    return "$hour:$minute";
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Fecha no disponible";

    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, "0");
    final month = local.month.toString().padLeft(2, "0");
    final year = local.year.toString();

    return "$day/$month/$year";
  }

  String _formatDurationFromMinutes(dynamic value) {
    final minutes = _toInt(value);

    if (minutes == null || minutes <= 0) {
      return "--";
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours <= 0) {
      return "${remainingMinutes}min";
    }

    if (remainingMinutes == 0) {
      return "${hours}h";
    }

    return "${hours}h ${remainingMinutes}min";
  }

  String _formatActiveDuration() {
    if (_activeSleepSession == null) return "--";

    final startTime = _parseDate(_activeSleepSession!["start_time"]);

    if (startTime == null) return "--";

    final diff = DateTime.now().difference(startTime.toLocal());
    final totalMinutes = diff.inMinutes;

    if (totalMinutes <= 0) {
      return "Menos de 1min";
    }

    return _formatDurationFromMinutes(totalMinutes);
  }

  String _latestSleepTitle() {
    if (_latestSleepSession == null) {
      return "Sin registros todavía";
    }

    return _formatDurationFromMinutes(_latestSleepSession!["duration_minutes"]);
  }

  String _latestSleepSubtitle() {
    if (_latestSleepSession == null) {
      return "Cuando registres tu primera noche aparecerá aquí.";
    }

    final start = _parseDate(_latestSleepSession!["start_time"]);
    final end = _parseDate(_latestSleepSession!["end_time"]);
    final quality = _latestSleepSession!["quality"]?.toString();

    final timeText = "${_formatTime(start)} - ${_formatTime(end)}";
    final dateText = _formatDate(end ?? start);

    if (quality != null && quality.trim().isNotEmpty) {
      return "$timeText · $quality · $dateText";
    }

    return "$timeText · $dateText";
  }

  int _completedSleepCount() {
    return _sleepSessions.where((item) {
      if (item is! Map) return false;

      final session = Map<String, dynamic>.from(item);

      return session["is_active"] == false;
    }).length;
  }

  double _targetRatio() {
    final latestMinutes = _toInt(_latestSleepSession?["duration_minutes"]) ?? 0;
    final targetMinutes = _targetSleepMinutes();

    if (latestMinutes <= 0 || targetMinutes <= 0) return 0;

    return (latestMinutes / targetMinutes).clamp(0.0, 1.0);
  }

  String _targetText() {
    final targetMinutes = _targetSleepMinutes();

    if (_latestSleepSession == null) {
      return _hasEnabledGoal()
          ? "Objetivo configurado: ${_targetSleepDurationText()}."
          : "Objetivo recomendado: 8h.";
    }

    final latestMinutes = _toInt(_latestSleepSession!["duration_minutes"]) ?? 0;
    final diff = latestMinutes - targetMinutes;

    if (diff == 0) {
      return "Has alcanzado exactamente tu objetivo de ${_targetSleepDurationText()}.";
    }

    if (diff > 0) {
      return "Has dormido ${_formatDurationFromMinutes(diff)} más que tu objetivo de ${_targetSleepDurationText()}.";
    }

    return "Te han faltado ${_formatDurationFromMinutes(diff.abs())} para llegar a tu objetivo de ${_targetSleepDurationText()}.";
  }

  void _openSleepSchedule() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SleepScheduleView(),
      ),
    ).then((_) {
      _loadSleepData();
    });
  }

  void _showFinishSleepSheet() {
    String selectedQuality = "Buena";
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44,
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
                              "Finalizar sueño",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "¿Cómo ha sido tu descanso?",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          "Mala",
                          "Regular",
                          "Buena",
                          "Excelente",
                        ].map((quality) {
                          final isSelected = selectedQuality == quality;

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setSheetState(() {
                                selectedQuality = quality;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 11,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? TColor.rojo
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                quality,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : TColor.black,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Notas opcionales",
                          hintStyle: TextStyle(
                            color: TColor.gray,
                            fontSize: 13,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isActionLoading
                              ? null
                              : () {
                                  Navigator.pop(context);

                                  _finishSleep(
                                    quality: selectedQuality,
                                    notes: notesController.text.trim().isEmpty
                                        ? null
                                        : notesController.text.trim(),
                                  );
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
                            "Guardar sueño",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSleepHistorySheet() {
    final completedSessions = _sleepSessions.where((item) {
      if (item is! Map) return false;

      final session = Map<String, dynamic>.from(item);
      return session["is_active"] == false;
    }).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.72,
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: TColor.gray.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                "Historial de sueño",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Registros de sueño completados",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: completedSessions.isEmpty
                    ? Center(
                        child: Text(
                          "Aún no tienes registros de sueño.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: completedSessions.length,
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 12);
                        },
                        itemBuilder: (context, index) {
                          final session = Map<String, dynamic>.from(
                            completedSessions[index] as Map,
                          );

                          return _SleepHistoryCard(
                            duration: _formatDurationFromMinutes(
                              session["duration_minutes"],
                            ),
                            date: _formatDate(
                              _parseDate(session["end_time"]) ??
                                  _parseDate(session["start_time"]),
                            ),
                            subtitle:
                                "${_formatTime(_parseDate(session["start_time"]))} - ${_formatTime(_parseDate(session["end_time"]))}",
                            quality: session["quality"]?.toString(),
                            onTap: () {
                              _showSleepSessionDetail(session);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSleepSessionDetail(Map<String, dynamic> session) {
    final start = _parseDate(session["start_time"]);
    final end = _parseDate(session["end_time"]);
    final quality = session["quality"]?.toString();
    final notes = session["notes"]?.toString();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: TColor.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailHeader(
                icon: Icons.bedtime_rounded,
                title: "Detalle de sueño",
                subtitle: _formatDate(end ?? start),
              ),
              const SizedBox(height: 20),
              _InfoRow(
                icon: Icons.timer_rounded,
                title: "Duración",
                value: _formatDurationFromMinutes(
                  session["duration_minutes"],
                ),
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.nightlight_round,
                title: "Horario real",
                value: "${_formatTime(start)} - ${_formatTime(end)}",
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.flag_rounded,
                title: "Objetivo",
                value: _hasEnabledGoal()
                    ? _targetSleepDurationText()
                    : "No configurado",
              ),
              const SizedBox(height: 12),
              _InfoRow(
                icon: Icons.sentiment_satisfied_alt_rounded,
                title: "Calidad",
                value: quality == null || quality.trim().isEmpty
                    ? "No indicada"
                    : quality,
              ),
              if (notes != null && notes.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.notes_rounded,
                  title: "Notas",
                  value: notes,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

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
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Sueño",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _loadSleepData,
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
                size: 22,
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
                onRefresh: _loadSleepData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryHeader(),
                      const SizedBox(height: 22),
                      if (_errorMessage != null) ...[
                        _buildErrorCard(),
                        const SizedBox(height: 18),
                      ],
                      _buildMainSleepCard(media),
                      const SizedBox(height: 22),
                      _buildTargetCard(),
                      const SizedBox(height: 22),
                      _buildScheduleShortcut(),
                      const SizedBox(height: 22),
                      _buildHistoryHeader(),
                      const SizedBox(height: 10),
                      _buildLatestSleepCard(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Resumen de descanso",
                style: TextStyle(
                  color: TColor.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _activeSleepSession == null
                    ? "Registra tu sueño de forma manual"
                    : "Sueño activo en curso",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: TColor.rojo.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.bedtime_rounded,
            color: TColor.rojo,
            size: 28,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage ?? "No se han podido cargar los datos.",
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainSleepCard(Size media) {
    final hasActiveSleep = _activeSleepSession != null;
    final startTime = _parseDate(_activeSleepSession?["start_time"]);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: hasActiveSleep
              ? [
                  TColor.rojo.withOpacity(0.95),
                  TColor.rojo.withOpacity(0.72),
                ]
              : [
                  TColor.rojo.withOpacity(0.12),
                  TColor.rojo.withOpacity(0.04),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: TColor.rojo.withOpacity(hasActiveSleep ? 0.22 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasActiveSleep ? Icons.nightlight_round : Icons.bedtime_rounded,
            color: hasActiveSleep ? Colors.white : TColor.rojo,
            size: 34,
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveSleep ? "Durmiendo ahora" : "Registro manual de sueño",
            style: TextStyle(
              color: hasActiveSleep ? Colors.white : TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasActiveSleep
                ? "Desde las ${_formatTime(startTime)} · ${_formatActiveDuration()}"
                : "Pulsa el botón cuando te vayas a dormir.",
            style: TextStyle(
              color: hasActiveSleep ? Colors.white70 : TColor.gray,
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isActionLoading
                  ? null
                  : hasActiveSleep
                      ? _showFinishSleepSheet
                      : _startSleep,
              icon: _isActionLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      hasActiveSleep
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round,
                    ),
              label: Text(
                hasActiveSleep ? "Me he despertado" : "Me voy a dormir",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasActiveSleep ? Colors.white : TColor.rojo,
                foregroundColor: hasActiveSleep ? TColor.rojo : Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard() {
    final ratio = _targetRatio();
    final percentage = (ratio * 100).round();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.flag_rounded,
              color: TColor.rojo,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Objetivo de descanso",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${_targetSleepLabel()}: ${_targetSleepDurationText()}",
                  style: TextStyle(
                    color: TColor.rojo,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _targetText(),
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$percentage%",
            style: TextStyle(
              color: TColor.rojo,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleShortcut() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: _openSleepSchedule,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: TColor.rojo.withOpacity(0.10),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: TColor.rojo.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: TColor.white,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                Icons.calendar_month_rounded,
                color: TColor.rojo,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Objetivo de sueño",
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _goalScheduleText(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 72,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TColor.rojo,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "Abrir",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            "Último sueño",
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        TextButton(
          onPressed: _showSleepHistorySheet,
          child: Text(
            "Ver más",
            style: TextStyle(
              color: TColor.rojo,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestSleepCard() {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: _latestSleepSession == null
          ? null
          : () {
              _showSleepSessionDetail(_latestSleepSession!);
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _latestSleepSession == null
                    ? Icons.info_outline_rounded
                    : Icons.bedtime_rounded,
                color: TColor.rojo,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _latestSleepTitle(),
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _latestSleepSubtitle(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${_completedSleepCount()} registros guardados",
                    style: TextStyle(
                      color: TColor.rojo,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (_latestSleepSession != null)
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

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: TColor.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.grey.shade100,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.045),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}

class _SleepHistoryCard extends StatelessWidget {
  final String duration;
  final String date;
  final String subtitle;
  final String? quality;
  final VoidCallback onTap;

  const _SleepHistoryCard({
    required this.duration,
    required this.date,
    required this.subtitle,
    required this.quality,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final qualityText =
        quality == null || quality!.trim().isEmpty ? "Sin calidad" : quality!;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TColor.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: TColor.rojo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                Icons.bedtime_rounded,
                color: TColor.rojo,
                size: 25,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    duration,
                    style: TextStyle(
                      color: TColor.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$subtitle · $qualityText",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
              date,
              style: TextStyle(
                color: TColor.gray,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _DetailHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: TColor.rojo.withOpacity(0.10),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: TColor.rojo,
            size: 28,
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
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
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
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: TColor.rojo.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: TColor.rojo,
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
                  color: TColor.gray,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: TColor.black,
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