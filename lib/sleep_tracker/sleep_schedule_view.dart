import 'package:afermar3_tf_ipc/services/sleep_goal_service.dart';
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
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _sleepGoal;

  @override
  void initState() {
    super.initState();
    _loadSleepGoal();
  }

  Future<void> _loadSleepGoal() async {
    try {
      final goal = await SleepGoalService.getMySleepGoal();

      if (!mounted) return;

      setState(() {
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

  Future<void> _openEditGoal() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepAddAlarmView(
          initialGoal: _sleepGoal,
        ),
      ),
    );

    if (updated == true) {
      _loadSleepGoal();
    }
  }

  Future<void> _toggleGoal() async {
    if (_sleepGoal == null || _isActionLoading) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      final updatedGoal = await SleepGoalService.toggleSleepGoal();

      if (!mounted) return;

      setState(() {
        _sleepGoal = updatedGoal;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            updatedGoal["enabled"] == true
                ? "Objetivo de sueño activado"
                : "Objetivo de sueño desactivado",
          ),
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

  Future<void> _deleteGoal() async {
    if (_sleepGoal == null || _isActionLoading) return;

    final confirmed = await _confirmDelete();

    if (confirmed != true) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      await SleepGoalService.deleteSleepGoal();

      if (!mounted) return;

      setState(() {
        _sleepGoal = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Objetivo de sueño eliminado"),
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

  Future<bool?> _confirmDelete() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 22, 24, 30),
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
                const SizedBox(height: 22),
                Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 42,
                ),
                const SizedBox(height: 14),
                Text(
                  "Eliminar objetivo",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Se eliminará tu objetivo de descanso configurado. Podrás crear uno nuevo cuando quieras.",
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
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Eliminar",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TColor.black,
                      side: BorderSide(
                        color: Colors.grey.shade200,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      "Cancelar",
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

  int _toInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString()) ?? 0;
  }

  String _formatDurationFromMinutes(dynamic value) {
    final minutes = _toInt(value);

    if (minutes <= 0) {
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

  double _sleepRatio() {
    final minutes = _toInt(_sleepGoal?["target_minutes"]);

    if (minutes <= 0) return 0.0;

    return (minutes / 480).clamp(0.0, 1.0);
  }

  String _goalStatusText() {
    if (_sleepGoal == null) {
      return "Sin objetivo configurado";
    }

    final enabled = _sleepGoal?["enabled"] == true;

    return enabled ? "Objetivo activo" : "Objetivo desactivado";
  }

  String _bedTimeText() {
    return _sleepGoal?["bed_time"]?.toString() ?? "--:--";
  }

  String _wakeTimeText() {
    return _sleepGoal?["wake_time"]?.toString() ?? "--:--";
  }

  String _repeatText() {
    return _sleepGoal?["repeat"]?.toString() ?? "Sin repetición";
  }

  String _durationText() {
    return _formatDurationFromMinutes(_sleepGoal?["target_minutes"]);
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
          "Objetivo de sueño",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _loadSleepGoal,
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
                onRefresh: _loadSleepGoal,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        _ErrorGoalCard(
                          message: _errorMessage!,
                          onRetry: _loadSleepGoal,
                        ),
                        const SizedBox(height: 18),
                      ],
                      _SleepHeaderCard(
                        media: media,
                        title: "Objetivo de descanso",
                        duration: _sleepGoal == null
                            ? "No configurado"
                            : _durationText(),
                        subtitle: _goalStatusText(),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        "Configuración",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_sleepGoal == null)
                        _EmptyGoalCard(
                          onCreate: _openEditGoal,
                        )
                      else ...[
                        _GoalInfoCard(
                          icon: Icons.bedtime_rounded,
                          title: "Hora objetivo de dormir",
                          value: _bedTimeText(),
                        ),
                        const SizedBox(height: 12),
                        _GoalInfoCard(
                          icon: Icons.wb_sunny_rounded,
                          title: "Hora objetivo de despertar",
                          value: _wakeTimeText(),
                        ),
                        const SizedBox(height: 12),
                        _GoalInfoCard(
                          icon: Icons.timer_rounded,
                          title: "Duración objetivo",
                          value: _durationText(),
                        ),
                        const SizedBox(height: 12),
                        _GoalInfoCard(
                          icon: Icons.repeat_rounded,
                          title: "Repetición",
                          value: _repeatText(),
                        ),
                        const SizedBox(height: 18),
                        _GoalProgressCard(
                          media: media,
                          summary: _durationText(),
                          ratio: _sleepRatio(),
                        ),
                        const SizedBox(height: 22),
                        _buildActionButtons(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: _sleepGoal == null
          ? InkWell(
              borderRadius: BorderRadius.circular(28),
              onTap: _openEditGoal,
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
            )
          : null,
    );
  }

  Widget _buildActionButtons() {
    final enabled = _sleepGoal?["enabled"] == true;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: RoundButton(
            title: "Editar objetivo",
            onPressed: _openEditGoal,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isActionLoading ? null : _toggleGoal,
            icon: Icon(
              enabled
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
            ),
            label: Text(
              enabled ? "Desactivar objetivo" : "Activar objetivo",
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: enabled ? TColor.rojo : Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
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
            onPressed: _isActionLoading ? null : _deleteGoal,
            icon: const Icon(Icons.delete_outline_rounded),
            label: const Text("Eliminar objetivo"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(
                color: Colors.redAccent,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SleepHeaderCard extends StatelessWidget {
  final Size media;
  final String title;
  final String duration;
  final String subtitle;

  const _SleepHeaderCard({
    required this.media,
    required this.title,
    required this.duration,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
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
                const Spacer(),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
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

class _GoalInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _GoalInfoCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: TColor.rojo,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: TColor.black,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: TColor.rojo,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }
}

class _GoalProgressCard extends StatelessWidget {
  final Size media;
  final String summary;
  final double ratio;

  const _GoalProgressCard({
    required this.media,
    required this.summary,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (ratio * 100).round();

    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Comparado con el objetivo recomendado de 8h",
            style: TextStyle(
              color: TColor.black,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            summary,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 12,
              fontWeight: FontWeight.w500,
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

class _EmptyGoalCard extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyGoalCard({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
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
            "Sin objetivo de sueño",
            style: TextStyle(
              color: TColor.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Configura una hora objetivo para dormir y despertar. No es una alarma, solo una referencia para comparar tu descanso real.",
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
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text("Configurar objetivo"),
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

class _ErrorGoalCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorGoalCard({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.16),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onRetry,
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
}