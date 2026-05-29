import 'package:afermar3_tf_ipc/services/sleep_goal_service.dart';
import 'package:afermar3_tf_ipc/sleep_tracker/sleep_add_alarm.dart';
import 'package:flutter/material.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

import '../../widgets/color_extension.dart';

class SleepScheduleView extends StatefulWidget {
  const SleepScheduleView({super.key});

  @override
  State<SleepScheduleView> createState() => _SleepScheduleViewState();
}

class _SleepScheduleViewState extends State<SleepScheduleView> {
  bool _isLoading = true;
  bool _isActionLoading = false;
  String? _errorMessage;

  List<dynamic> _sleepGoals = [];
  Map<String, dynamic>? _effectiveGoalData;

  final List<String> _goalTypes = [
    "WEEKDAYS",
    "WEEKENDS",
    "ALL_DAYS",
  ];

  @override
  void initState() {
    super.initState();
    _loadSleepGoals();
  }

  Future<void> _loadSleepGoals() async {
    try {
      final goals = await SleepGoalService.getMySleepGoals();
      final effectiveGoal = await SleepGoalService.getEffectiveSleepGoalToday();

      if (!mounted) return;

      setState(() {
        _sleepGoals = goals;
        _effectiveGoalData = effectiveGoal;
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

  Map<String, dynamic>? _goalByType(String goalType) {
    for (final item in _sleepGoals) {
      if (item is! Map) continue;

      final goal = Map<String, dynamic>.from(item);

      if (goal["goal_type"] == goalType) {
        return goal;
      }
    }

    return null;
  }

  Future<void> _openEditGoal({
    required String goalType,
    Map<String, dynamic>? initialGoal,
  }) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SleepAddAlarmView(
          goalType: goalType,
          initialGoal: initialGoal,
        ),
      ),
    );

    if (updated == true) {
      _loadSleepGoals();
    }
  }

  Future<void> _toggleGoal(Map<String, dynamic> goal) async {
    if (_isActionLoading) return;

    final goalId = _toInt(goal["id"]);

    if (goalId == null) {
      _showError("No se ha podido identificar el objetivo de sueño");
      return;
    }

    setState(() {
      _isActionLoading = true;
    });

    try {
      await SleepGoalService.toggleSleepGoal(goalId);
      await _loadSleepGoals();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            goal["enabled"] == true
                ? "Objetivo de sueño desactivado"
                : "Objetivo de sueño activado",
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

  Future<void> _deleteGoal(Map<String, dynamic> goal) async {
    if (_isActionLoading) return;

    final goalId = _toInt(goal["id"]);

    if (goalId == null) {
      _showError("No se ha podido identificar el objetivo de sueño");
      return;
    }

    final confirmed = await _confirmDelete(goal);

    if (confirmed != true) return;

    setState(() {
      _isActionLoading = true;
    });

    try {
      await SleepGoalService.deleteSleepGoal(goalId);
      await _loadSleepGoals();

      if (!mounted) return;

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

  Future<bool?> _confirmDelete(Map<String, dynamic> goal) {
    final goalType = goal["goal_type"]?.toString() ?? "";
    final title = SleepGoalService.goalTypeLabel(goalType);

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
                const Icon(
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
                  "Se eliminará el objetivo de sueño de $title. Podrás configurarlo de nuevo cuando quieras.",
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

  int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value.toString());
  }

  int _toIntSafe(dynamic value) {
    return _toInt(value) ?? 0;
  }

  String _formatDurationFromMinutes(dynamic value) {
    final minutes = _toIntSafe(value);

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

  double _recommendedRatio(Map<String, dynamic>? goal) {
    final minutes = _toIntSafe(goal?["target_minutes"]);

    if (minutes <= 0) return 0.0;

    return (minutes / 480).clamp(0.0, 1.0);
  }

  Map<String, dynamic>? _effectiveGoal() {
    final goal = _effectiveGoalData?["goal"];

    if (goal is Map) {
      return Map<String, dynamic>.from(goal);
    }

    return null;
  }

  String _effectiveGoalTitle() {
    final source = _effectiveGoalData?["source"]?.toString();

    if (source == null || source == "RECOMMENDED") {
      return "Recomendado";
    }

    return SleepGoalService.goalTypeLabel(source);
  }

  String _effectiveGoalDescription() {
    final goal = _effectiveGoal();

    if (goal == null) {
      return "Hoy se usará el objetivo recomendado de 8h.";
    }

    final bedTime = goal["bed_time"]?.toString() ?? "--:--";
    final wakeTime = goal["wake_time"]?.toString() ?? "--:--";
    final duration = _formatDurationFromMinutes(goal["target_minutes"]);

    return "$bedTime - $wakeTime · $duration";
  }

  int _activeGoalCount() {
    int count = 0;

    for (final item in _sleepGoals) {
      if (item is! Map) continue;

      final goal = Map<String, dynamic>.from(item);

      if (goal["enabled"] == true) {
        count++;
      }
    }

    return count;
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
          "Objetivos de sueño",
          style: TextStyle(
            color: TColor.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _loadSleepGoals,
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
                onRefresh: _loadSleepGoals,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null) ...[
                        _ErrorGoalCard(
                          message: _errorMessage!,
                          onRetry: _loadSleepGoals,
                        ),
                        const SizedBox(height: 18),
                      ],
                      _SleepHeaderCard(
                        media: media,
                        title: "Objetivo efectivo de hoy",
                        duration: _effectiveGoalTitle(),
                        subtitle: _effectiveGoalDescription(),
                      ),
                      const SizedBox(height: 22),
                      _SummaryGoalCard(
                        totalGoals: _sleepGoals.length,
                        activeGoals: _activeGoalCount(),
                      ),
                      const SizedBox(height: 22),
                      Text(
                        "Tus objetivos",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Configura un horario distinto para entre semana y fin de semana.",
                        style: TextStyle(
                          color: TColor.gray,
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ..._goalTypes.map((goalType) {
                        final goal = _goalByType(goalType);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _GoalProfileCard(
                            goalType: goalType,
                            goal: goal,
                            ratio: _recommendedRatio(goal),
                            durationText: goal == null
                                ? "No configurado"
                                : _formatDurationFromMinutes(
                                    goal["target_minutes"],
                                  ),
                            onCreate: () {
                              _openEditGoal(
                                goalType: goalType,
                                initialGoal: null,
                              );
                            },
                            onEdit: goal == null
                                ? null
                                : () {
                                    _openEditGoal(
                                      goalType: goalType,
                                      initialGoal: goal,
                                    );
                                  },
                            onToggle: goal == null
                                ? null
                                : () {
                                    _toggleGoal(goal);
                                  },
                            onDelete: goal == null
                                ? null
                                : () {
                                    _deleteGoal(goal);
                                  },
                          ),
                        );
                      }),
                    ],
                  ),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 12,
                    height: 1.25,
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

class _SummaryGoalCard extends StatelessWidget {
  final int totalGoals;
  final int activeGoals;

  const _SummaryGoalCard({
    required this.totalGoals,
    required this.activeGoals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
            width: 54,
            height: 54,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$activeGoals objetivos activos",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$totalGoals configurados en total",
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
      ),
    );
  }
}

class _GoalProfileCard extends StatelessWidget {
  final String goalType;
  final Map<String, dynamic>? goal;
  final double ratio;
  final String durationText;
  final VoidCallback onCreate;
  final VoidCallback? onEdit;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const _GoalProfileCard({
    required this.goalType,
    required this.goal,
    required this.ratio,
    required this.durationText,
    required this.onCreate,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  String _bedTimeText() {
    return goal?["bed_time"]?.toString() ?? "--:--";
  }

  String _wakeTimeText() {
    return goal?["wake_time"]?.toString() ?? "--:--";
  }

  bool _enabled() {
    return goal?["enabled"] == true;
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = goal != null;
    final title = SleepGoalService.goalTypeLabel(goalType);
    final description = SleepGoalService.goalTypeDescription(goalType);
    final percentage = (ratio * 100).round();

    return Container(
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: TColor.rojo.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  goalType == "WEEKENDS"
                      ? Icons.weekend_rounded
                      : goalType == "WEEKDAYS"
                          ? Icons.work_rounded
                          : Icons.calendar_month_rounded,
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
                      title,
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
              if (hasGoal)
                Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: _enabled(),
                    activeColor: TColor.white,
                    activeTrackColor: TColor.rojo,
                    inactiveThumbColor: TColor.white,
                    inactiveTrackColor: Colors.grey.shade300,
                    onChanged: (_) {
                      if (onToggle != null) onToggle!();
                    },
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasGoal)
            _EmptyGoalButton(
              onPressed: onCreate,
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _MiniInfo(
                    title: "Dormir",
                    value: _bedTimeText(),
                    icon: Icons.bedtime_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniInfo(
                    title: "Despertar",
                    value: _wakeTimeText(),
                    icon: Icons.wb_sunny_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniInfo(
                    title: "Objetivo",
                    value: durationText,
                    icon: Icons.timer_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _ProgressAgainstRecommended(
              ratio: ratio,
              percentage: percentage,
              durationText: durationText,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text("Editar"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: TColor.rojo,
                      side: BorderSide(
                        color: TColor.rojo.withOpacity(0.35),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text("Eliminar"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(
                        color: Colors.redAccent,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyGoalButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EmptyGoalButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: TColor.rojo.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: TColor.rojo.withOpacity(0.10),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_rounded,
              color: TColor.rojo,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              "Configurar objetivo",
              style: TextStyle(
                color: TColor.rojo,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _MiniInfo({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: TColor.rojo,
            size: 18,
          ),
          const SizedBox(height: 5),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.black,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressAgainstRecommended extends StatelessWidget {
  final double ratio;
  final int percentage;
  final String durationText;

  const _ProgressAgainstRecommended({
    required this.ratio,
    required this.percentage,
    required this.durationText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Comparado con el objetivo recomendado de 8h",
            style: TextStyle(
              color: TColor.black,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            durationText,
            style: TextStyle(
              color: TColor.gray,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Stack(
            alignment: Alignment.center,
            children: [
              SimpleAnimationProgressBar(
                height: 14,
                width: double.infinity,
                backgroundColor: Colors.grey.shade100,
                foregroundColor: Colors.purple,
                ratio: ratio,
                direction: Axis.horizontal,
                curve: Curves.fastLinearToSlowEaseIn,
                duration: const Duration(seconds: 2),
                borderRadius: BorderRadius.circular(7),
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
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
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