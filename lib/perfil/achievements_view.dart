import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/progress_photo_service.dart';
import 'package:afermar3_tf_ipc/services/sleep_service.dart';
import 'package:afermar3_tf_ipc/services/workout_plan_service.dart';
import 'package:afermar3_tf_ipc/services/workout_session_service.dart';
import 'package:flutter/material.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  bool _isLoading = true;
  String? _errorMessage;

  int _completedWorkouts = 0;
  int _sleepSessions = 0;
  int _progressPhotos = 0;
  bool _hasActiveWorkoutPlan = false;

  List<_AchievementItem> _achievements = [];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      int completedWorkouts = 0;
      int sleepSessions = 0;
      int progressPhotos = 0;
      bool hasActiveWorkoutPlan = false;

      try {
        final sessions = await WorkoutSessionService.getMyWorkoutSessions();
        completedWorkouts = sessions.length;
      } catch (_) {
        completedWorkouts = 0;
      }

      try {
        final activePlan = await WorkoutPlanService.getActiveWorkoutPlan();
        hasActiveWorkoutPlan = activePlan != null && activePlan.isNotEmpty;
      } catch (_) {
        hasActiveWorkoutPlan = false;
      }

      try {
        final sleep = await SleepService.getMySleepSessions();
        sleepSessions = sleep.length;
      } catch (_) {
        sleepSessions = 0;
      }

      try {
        final photos = await ProgressPhotoService.getMyProgressPhotos();
        progressPhotos = photos.length;
      } catch (_) {
        progressPhotos = 0;
      }

      final achievements = _buildAchievements(
        completedWorkouts: completedWorkouts,
        sleepSessions: sleepSessions,
        progressPhotos: progressPhotos,
        hasActiveWorkoutPlan: hasActiveWorkoutPlan,
      );

      if (!mounted) return;

      setState(() {
        _completedWorkouts = completedWorkouts;
        _sleepSessions = sleepSessions;
        _progressPhotos = progressPhotos;
        _hasActiveWorkoutPlan = hasActiveWorkoutPlan;
        _achievements = achievements;
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

  List<_AchievementItem> _buildAchievements({
    required int completedWorkouts,
    required int sleepSessions,
    required int progressPhotos,
    required bool hasActiveWorkoutPlan,
  }) {
    return [
      _AchievementItem(
        title: "Primer entrenamiento",
        description: "Completa tu primera sesión de entrenamiento.",
        icon: Icons.fitness_center_rounded,
        unlocked: completedWorkouts >= 1,
        progressText: "$completedWorkouts/1",
      ),
      _AchievementItem(
        title: "Constancia inicial",
        description: "Completa 3 entrenamientos.",
        icon: Icons.local_fire_department_rounded,
        unlocked: completedWorkouts >= 3,
        progressText: "${completedWorkouts.clamp(0, 3)}/3",
      ),
      _AchievementItem(
        title: "Semana activa",
        description: "Completa 7 entrenamientos en total.",
        icon: Icons.calendar_month_rounded,
        unlocked: completedWorkouts >= 7,
        progressText: "${completedWorkouts.clamp(0, 7)}/7",
      ),
      _AchievementItem(
        title: "Rutina preparada",
        description: "Activa una rutina de entrenamiento.",
        icon: Icons.assignment_turned_in_rounded,
        unlocked: hasActiveWorkoutPlan,
        progressText: hasActiveWorkoutPlan ? "1/1" : "0/1",
      ),
      _AchievementItem(
        title: "Primer descanso",
        description: "Registra tu primera sesión de sueño.",
        icon: Icons.bedtime_rounded,
        unlocked: sleepSessions >= 1,
        progressText: "$sleepSessions/1",
      ),
      _AchievementItem(
        title: "Seguimiento visual",
        description: "Sube tu primera foto de progreso.",
        icon: Icons.photo_camera_rounded,
        unlocked: progressPhotos >= 1,
        progressText: "$progressPhotos/1",
      ),
      _AchievementItem(
        title: "Comparador desbloqueado",
        description: "Sube al menos 2 fotos para comparar tu evolución.",
        icon: Icons.compare_rounded,
        unlocked: progressPhotos >= 2,
        progressText: "${progressPhotos.clamp(0, 2)}/2",
      ),
    ];
  }

  int _unlockedCount() {
    return _achievements.where((item) => item.unlocked).length;
  }

  int _totalCount() {
    return _achievements.length;
  }

  double _completionPercentage() {
    if (_achievements.isEmpty) return 0;

    return _unlockedCount() / _achievements.length;
  }

  String _completionText() {
    if (_achievements.isEmpty) return "0%";

    final percentage = (_completionPercentage() * 100).round();

    return "$percentage%";
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
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: TColor.rojo.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: TColor.rojo,
              size: 36,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tus logros",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${_unlockedCount()} de ${_totalCount()} desbloqueados",
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _completionPercentage(),
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      TColor.rojo,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _completionText(),
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

  Widget _buildSummaryStats() {
    return Row(
      children: [
        Expanded(
          child: _AchievementStatCard(
            icon: Icons.fitness_center_rounded,
            value: "$_completedWorkouts",
            label: "Entrenos",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AchievementStatCard(
            icon: Icons.bedtime_rounded,
            value: "$_sleepSessions",
            label: "Sueños",
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _AchievementStatCard(
            icon: Icons.photo_library_rounded,
            value: "$_progressPhotos",
            label: "Fotos",
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementList() {
    return ListView.separated(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _achievements.length,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        final achievement = _achievements[index];

        return _AchievementCard(
          achievement: achievement,
        );
      },
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.15),
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
            _errorMessage ?? "No se han podido cargar los logros.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _loadAchievements,
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
          "Logros",
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
              onTap: _loadAchievements,
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
                onRefresh: _loadAchievements,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_errorMessage != null)
                        _buildErrorCard()
                      else ...[
                        _buildHeaderCard(),
                        const SizedBox(height: 18),
                        _buildSummaryStats(),
                        const SizedBox(height: 26),
                        Text(
                          "Insignias",
                          style: TextStyle(
                            color: TColor.negro,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildAchievementList(),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _AchievementItem {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final String progressText;

  const _AchievementItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.progressText,
  });
}

class _AchievementStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _AchievementStatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 98,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: TColor.rojo,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: TColor.rojo.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: TColor.blanco,
            size: 21,
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: TColor.blanco,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: TColor.blanco.withOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final _AchievementItem achievement;

  const _AchievementCard({
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.unlocked;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: unlocked ? TColor.blanco : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked
              ? TColor.rojo.withOpacity(0.16)
              : Colors.grey.shade200,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? TColor.rojo.withOpacity(0.12)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              unlocked ? achievement.icon : Icons.lock_outline_rounded,
              color: unlocked ? TColor.rojo : TColor.gris,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    color: unlocked ? TColor.negro : TColor.gris,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: unlocked
                  ? TColor.rojo.withOpacity(0.10)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              unlocked ? "Hecho" : achievement.progressText,
              style: TextStyle(
                color: unlocked ? TColor.rojo : TColor.gris,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}