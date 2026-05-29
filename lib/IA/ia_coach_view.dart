import 'package:afermar3_tf_ipc/IA/ai_generated_workout_view.dart';
import 'package:afermar3_tf_ipc/IA/saved_workouts_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/ai_chat_service.dart';
import 'package:flutter/material.dart';

class AiCoachView extends StatefulWidget {
  const AiCoachView({super.key});

  @override
  State<AiCoachView> createState() => _AiCoachViewState();
}

class _AiCoachViewState extends State<AiCoachView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isApplyingAction = false;
  bool _isLoadingHistory = true;

  final List<Map<String, dynamic>> _messages = [];

  final List<Map<String, dynamic>> _quickActions = [
    {
      "title": "Crear rutina",
      "subtitle": "Entrenamiento personalizado",
      "icon": Icons.fitness_center_rounded,
    },
    {
      "title": "Ajustar dieta",
      "subtitle": "Según tu objetivo",
      "icon": Icons.restaurant_menu_rounded,
    },
    {
      "title": "Analizar progreso",
      "subtitle": "Peso, fotos y actividad",
      "icon": Icons.show_chart_rounded,
    },
    {
      "title": "Resolver duda",
      "subtitle": "Preguntas fitness",
      "icon": Icons.help_outline_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _safeMap(dynamic value) {
    if (value == null) return null;

    if (value is Map<String, dynamic>) {
      return value;
    }

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return null;
  }

  Map<String, dynamic> _buildWelcomeMessage() {
    return {
      "isUser": false,
      "text":
          "Hola, soy tu Coach IA de PulseAI. Puedes preguntarme sobre entrenamiento, comida, sueño o hábitos saludables.",
      "fromHistory": false,
    };
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await AiChatService.getChatHistory(limit: 40);

      final loadedMessages = history.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        final role = map["role"]?.toString() ?? "assistant";
        final pendingAction = _safeMap(map["pending_action"]);

        return {
          "isUser": role == "user",
          "text": map["content"]?.toString() ?? "",
          "pendingAction": pendingAction,
          "actionApplied": false,
          "fromHistory": true,
        };
      }).where((message) {
        final text = message["text"]?.toString().trim() ?? "";
        return text.isNotEmpty;
      }).toList();

      if (!mounted) return;

      setState(() {
        _messages.clear();

        if (loadedMessages.isEmpty) {
          _messages.add(_buildWelcomeMessage());
        } else {
          _messages.addAll(loadedMessages);
        }

        _isLoadingHistory = false;
      });

      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _messages.clear();
        _messages.add(_buildWelcomeMessage());
        _messages.add({
          "isUser": false,
          "text":
              "No se ha podido cargar el historial anterior, pero puedes seguir usando el Coach IA.",
          "fromHistory": false,
        });
        _isLoadingHistory = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isLoading || _isApplyingAction || _isLoadingHistory) {
      return;
    }

    setState(() {
      _messages.add({
        "isUser": true,
        "text": text,
        "fromHistory": false,
      });

      _messages.add({
        "isUser": false,
        "text": "Pensando...",
        "isLoading": true,
        "fromHistory": false,
      });

      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await AiChatService.sendMessage(text);

      final answer = response["answer"]?.toString() ?? "";
      final pendingAction = _safeMap(response["pending_action"]);

      if (!mounted) return;

      setState(() {
        final loadingIndex = _messages.indexWhere(
          (message) => message["isLoading"] == true,
        );

        final botMessage = {
          "isUser": false,
          "text": answer,
          "pendingAction": pendingAction,
          "actionApplied": false,
          "fromHistory": false,
        };

        if (loadingIndex != -1) {
          _messages[loadingIndex] = botMessage;
        } else {
          _messages.add(botMessage);
        }
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceFirst("Exception: ", "");

      setState(() {
        final loadingIndex = _messages.indexWhere(
          (message) => message["isLoading"] == true,
        );

        if (loadingIndex != -1) {
          _messages[loadingIndex] = {
            "isUser": false,
            "text": errorMessage,
            "fromHistory": false,
          };
        } else {
          _messages.add({
            "isUser": false,
            "text": errorMessage,
            "fromHistory": false,
          });
        }
      });

      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _applyPendingAction({
    required int messageIndex,
    required Map<String, dynamic> pendingAction,
  }) async {
    if (_isApplyingAction || _isLoading || _isLoadingHistory) return;

    setState(() {
      _isApplyingAction = true;
    });

    try {
      final result = await AiChatService.applyPendingAction(
        pendingAction: pendingAction,
      );

      final message = result["message"]?.toString() ??
          "La acción se ha aplicado correctamente.";

      if (!mounted) return;

      final success = result["success"] == true;

      setState(() {
        if (success && messageIndex >= 0 && messageIndex < _messages.length) {
          _messages[messageIndex]["actionApplied"] = true;
        }

        _messages.add({
          "isUser": false,
          "text": message,
          "fromHistory": false,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      final errorMessage = e.toString().replaceFirst("Exception: ", "");

      setState(() {
        _messages.add({
          "isUser": false,
          "text": errorMessage,
          "fromHistory": false,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );

      _scrollToBottom();
    } finally {
      if (mounted) {
        setState(() {
          _isApplyingAction = false;
        });
      }
    }
  }

  void _sendQuickAction(String action) {
    if (_isLoading || _isApplyingAction || _isLoadingHistory) return;

    switch (action) {
      case "Crear rutina":
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AiGeneratedWorkoutView(),
          ),
        );
        return;

      case "Ajustar dieta":
        _messageController.text =
            "Dame recomendaciones de alimentación personalizadas según mi perfil y mi objetivo actual. Incluye ideas de comidas, distribución diaria, proteínas, hidratación y consejos prácticos.";
        break;

      case "Analizar progreso":
        _messageController.text =
            "Analiza mi progreso actual según mi perfil y objetivo. Dame puntos fuertes, aspectos a mejorar y recomendaciones concretas para esta semana.";
        break;

      case "Resolver duda":
        _messageController.text =
            "Tengo una duda sobre entrenamiento, alimentación o descanso.";
        break;

      default:
        _messageController.text = action;
    }

    _sendMessage();
  }

  void _openSavedWorkouts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedWorkoutsView(),
      ),
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 180), () {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  bool _canApplyAction(Map<String, dynamic> action) {
    final type = action["type"]?.toString();
    final requiresConfirmation = action["requires_confirmation"] == true;

    if (!requiresConfirmation) return false;

    return type == "create_workout_plan" ||
        type == "add_workout_day" ||
        type == "add_exercise_to_day" ||
        type == "replace_exercise" ||
        type == "update_exercise_config" ||
        type == "schedule_workout" ||
        type == "update_sleep_goal_profile";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Coach IA",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _openSavedWorkouts,
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.negro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bookmark_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                children: [
                  _buildHeaderCard(),
                  const SizedBox(height: 22),
                  _buildQuickActions(),
                  const SizedBox(height: 22),
                  Text(
                    "Conversación",
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_isLoadingHistory)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: TColor.rojo,
                        ),
                      ),
                    )
                  else
                    ...List.generate(_messages.length, (index) {
                      final message = _messages[index];
                      final isLoadingMessage = message["isLoading"] == true;
                      final isUser = message["isUser"] == true;
                      final pendingAction = _safeMap(message["pendingAction"]);
                      final actionApplied = message["actionApplied"] == true;
                      final fromHistory = message["fromHistory"] == true;

                      return Column(
                        crossAxisAlignment: isUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          _ChatBubble(
                            text: message["text"].toString(),
                            isUser: isUser,
                            isLoading: isLoadingMessage,
                          ),
                          if (!isUser && pendingAction != null)
                            _PendingActionCard(
                              action: pendingAction,
                              canApply: !fromHistory &&
                                  _canApplyAction(pendingAction) &&
                                  !actionApplied,
                              isApplying: _isApplyingAction,
                              alreadyApplied: actionApplied,
                              onApply: () {
                                _applyPendingAction(
                                  messageIndex: index,
                                  pendingAction: pendingAction,
                                );
                              },
                            ),
                        ],
                      );
                    }),
                ],
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TColor.primerColor2.withOpacity(0.20),
            TColor.primerColor1.withOpacity(0.10),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: TColor.primerColor1.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primerG),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: TColor.rojo.withOpacity(0.22),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tu entrenador inteligente",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Pídele rutinas, consejos de alimentación, descanso o hábitos saludables.",
                  style: TextStyle(
                    color: TColor.gris,
                    fontSize: 13,
                    height: 1.35,
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Acciones rápidas",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _quickActions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.45,
          ),
          itemBuilder: (context, index) {
            final item = _quickActions[index];

            return InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _isLoading || _isApplyingAction || _isLoadingHistory
                  ? null
                  : () {
                      _sendQuickAction(item["title"].toString());
                    },
              child: Opacity(
                opacity: _isLoading || _isApplyingAction || _isLoadingHistory
                    ? 0.55
                    : 1,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: TColor.blanco,
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
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item["icon"] as IconData,
                        color: TColor.rojo,
                        size: 26,
                      ),
                      const Spacer(),
                      Text(
                        item["title"].toString(),
                        style: TextStyle(
                          color: TColor.negro,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item["subtitle"].toString(),
                        style: TextStyle(
                          color: TColor.gris,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputBar() {
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final bool disabled = _isLoading || _isApplyingAction || _isLoadingHistory;

    return Container(
      margin: EdgeInsets.fromLTRB(
        18,
        0,
        18,
        isKeyboardOpen ? 8 : 88,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TColor.blanco,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              enabled: !disabled,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!disabled) {
                  _sendMessage();
                }
              },
              decoration: InputDecoration(
                hintText: _isLoadingHistory
                    ? "Cargando historial..."
                    : _isApplyingAction
                        ? "Aplicando cambios..."
                        : _isLoading
                            ? "PulseAI está respondiendo..."
                            : "Pregúntale algo a tu Coach IA...",
                hintStyle: TextStyle(
                  color: TColor.gris,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: disabled ? null : _sendMessage,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: disabled
                      ? [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ]
                      : TColor.primerG,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: disabled
                  ? const SizedBox(
                      width: 21,
                      height: 21,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.3,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingActionCard extends StatelessWidget {
  final Map<String, dynamic> action;
  final bool canApply;
  final bool isApplying;
  final bool alreadyApplied;
  final VoidCallback onApply;

  const _PendingActionCard({
    required this.action,
    required this.canApply,
    required this.isApplying,
    required this.alreadyApplied,
    required this.onApply,
  });

  String _formatActionDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return "Fecha pendiente";
    }

    try {
      final date = DateTime.parse(rawDate);
      final now = DateTime.now();

      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(const Duration(days: 1));
      final actionDay = DateTime(date.year, date.month, date.day);

      final day = date.day.toString().padLeft(2, "0");
      final month = date.month.toString().padLeft(2, "0");
      final year = date.year.toString();

      if (actionDay == today) {
        return "Hoy · $day/$month/$year";
      }

      if (actionDay == tomorrow) {
        return "Mañana · $day/$month/$year";
      }

      return "$day/$month/$year";
    } catch (_) {
      return rawDate;
    }
  }

  String _formatSleepGoalType(String goalType) {
    switch (goalType) {
      case "WEEKDAYS":
        return "Entre semana";
      case "WEEKENDS":
        return "Fin de semana";
      case "ALL_DAYS":
        return "Todos los días";
      default:
        return "Objetivo de sueño";
    }
  }

  String _formatMinutes(dynamic rawMinutes) {
    final targetMinutes = int.tryParse(rawMinutes?.toString() ?? "") ?? 0;

    if (targetMinutes <= 0) {
      return "Duración no especificada";
    }

    final hours = targetMinutes ~/ 60;
    final minutes = targetMinutes % 60;

    if (hours <= 0) {
      return "${minutes}min";
    }

    if (minutes == 0) {
      return "${hours}h";
    }

    return "${hours}h ${minutes}min";
  }

  String _appliedTitle() {
    final type = action["type"]?.toString();

    if (type == "schedule_workout") {
      return "Entrenamiento programado";
    }

    if (type == "update_sleep_goal_profile") {
      return "Objetivo de sueño actualizado";
    }

    return "Cambios aplicados";
  }

  String _appliedSubtitle() {
    final type = action["type"]?.toString();

    if (type == "schedule_workout") {
      return "Esta propuesta ya se ha añadido a tu agenda.";
    }

    if (type == "update_sleep_goal_profile") {
      return "Esta propuesta ya se ha aplicado a tus objetivos de sueño.";
    }

    return "Esta propuesta ya se ha añadido a tu rutina.";
  }

  String _extractSummary() {
    final type = action["type"]?.toString() ?? "";
    final payload = action["payload"];

    if (type == "create_workout_plan" && payload is Map) {
      final workout = payload["workout"];
      final activate = payload["activate"] == true;

      if (workout is Map) {
        final title = workout["title"]?.toString() ?? "Rutina IA";
        final daysPerWeek = workout["days_per_week"]?.toString() ?? "-";
        final duration = workout["duration_minutes"]?.toString() ?? "-";
        final days = workout["days"];

        int totalExercises = 0;

        if (days is List) {
          for (final day in days) {
            if (day is Map && day["exercises"] is List) {
              totalExercises += (day["exercises"] as List).length;
            }
          }
        }

        final activeText = activate ? "Se activará" : "Solo se guardará";

        return "$title · $daysPerWeek días · $duration min · $totalExercises ejercicios · $activeText";
      }

      return "Crear nueva rutina";
    }

    if (type == "update_sleep_goal_profile" && payload is Map) {
      final goalType = payload["goal_type"]?.toString() ?? "";
      final bedTime = payload["bed_time"]?.toString() ?? "--:--";
      final wakeTime = payload["wake_time"]?.toString() ?? "--:--";
      final targetMinutes = payload["target_minutes"];

      final goalLabel = _formatSleepGoalType(goalType);
      final durationText = _formatMinutes(targetMinutes);

      return "$goalLabel · $bedTime - $wakeTime · $durationText";
    }

    if (type == "add_workout_day" && payload is Map) {
      final day = payload["day"];

      if (day is Map) {
        final dayName = day["name"]?.toString() ?? "Nuevo entrenamiento";
        final duration = day["duration_minutes"]?.toString() ?? "-";
        final exercises = day["exercises"];

        final totalExercises = exercises is List ? exercises.length : 0;

        return "$dayName · $duration min · $totalExercises ejercicio(s)";
      }
    }

    if (type == "add_exercise_to_day" && payload is Map) {
      final dayNumber = payload["day_number"]?.toString() ?? "-";
      final dayName = payload["day_name"]?.toString() ?? "Día $dayNumber";
      final exercise = payload["exercise"];

      if (exercise is Map) {
        final exerciseName =
            exercise["exercise_name"]?.toString() ?? "Ejercicio";
        final sets = exercise["sets"]?.toString() ?? "3";
        final reps = exercise["reps"]?.toString() ?? "10-12";

        return "$exerciseName · Día $dayNumber - $dayName · $sets series x $reps";
      }

      return "Añadir ejercicio al día $dayNumber";
    }

    if (type == "replace_exercise" && payload is Map) {
      final oldExercise =
          payload["old_exercise"]?.toString() ?? "Ejercicio actual";
      final newExercise = payload["new_exercise"];

      if (newExercise is Map) {
        final newExerciseName =
            newExercise["exercise_name"]?.toString() ?? "Nuevo ejercicio";

        return "$oldExercise → $newExerciseName";
      }

      return action["description"]?.toString() ?? "Sustituir ejercicio";
    }

    if (type == "update_exercise_config" && payload is Map) {
      final dayNumber = payload["day_number"]?.toString() ?? "-";
      final dayName = payload["day_name"]?.toString() ?? "Día $dayNumber";
      final exerciseName = payload["exercise_name"]?.toString() ?? "Ejercicio";
      final updates = payload["updates"];

      final parts = <String>[];

      if (updates is Map) {
        if (updates["sets"] != null) {
          parts.add("${updates["sets"]} series");
        }

        if (updates["reps"] != null) {
          parts.add("${updates["reps"]} reps");
        }

        if (updates["rest_seconds"] != null) {
          parts.add("${updates["rest_seconds"]} s descanso");
        }
      }

      final updateText =
          parts.isEmpty ? "Actualizar configuración" : parts.join(" · ");

      return "$exerciseName · Día $dayNumber - $dayName · $updateText";
    }

    if (type == "schedule_workout" && payload is Map) {
      final dayNumber = payload["day_number"]?.toString() ?? "-";
      final dayName = payload["day_name"]?.toString() ?? "Entrenamiento";
      final scheduledDate = _formatActionDate(
        payload["scheduled_date"]?.toString(),
      );
      final duration = payload["duration_minutes"]?.toString() ?? "-";

      return "Día $dayNumber - $dayName · $scheduledDate · $duration min";
    }

    return action["description"]?.toString() ?? "Acción propuesta por PulseAI";
  }

  @override
  Widget build(BuildContext context) {
    final title = action["title"]?.toString() ?? "Propuesta de cambio";
    final type = action["type"]?.toString() ?? "";
    final isErrorType = type == "missing_exercises" ||
        type == "not_enough_exercises" ||
        type == "missing_day" ||
        type == "invalid_day" ||
        type == "missing_exercise" ||
        type == "missing_update_values" ||
        type == "missing_schedule_date" ||
        type == "invalid_workout_days" ||
        type == "missing_sleep_goal_type" ||
        type == "missing_sleep_goal_time" ||
        type == "invalid_sleep_goal_duration";

    Color cardColor;
    Color iconColor;
    IconData icon;

    if (alreadyApplied) {
      cardColor = Colors.green.withOpacity(0.08);
      iconColor = Colors.green;
      icon = Icons.check_circle_rounded;
    } else if (isErrorType) {
      cardColor = Colors.orange.withOpacity(0.10);
      iconColor = Colors.orange;
      icon = Icons.info_outline_rounded;
    } else if (type == "schedule_workout") {
      cardColor = TColor.primerColor1.withOpacity(0.08);
      iconColor = TColor.primerColor1;
      icon = Icons.event_available_rounded;
    } else if (type == "update_sleep_goal_profile") {
      cardColor = Colors.indigo.withOpacity(0.08);
      iconColor = Colors.indigo;
      icon = Icons.bedtime_rounded;
    } else if (type == "create_workout_plan") {
      cardColor = Colors.green.withOpacity(0.08);
      iconColor = Colors.green;
      icon = Icons.fitness_center_rounded;
    } else {
      cardColor = TColor.rojo.withOpacity(0.08);
      iconColor = TColor.rojo;
      icon = Icons.auto_fix_high_rounded;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(
          left: 0,
          right: 30,
          bottom: 14,
        ),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: iconColor.withOpacity(0.16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: TColor.blanco,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alreadyApplied ? _appliedTitle() : title,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alreadyApplied ? _appliedSubtitle() : _extractSummary(),
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 12,
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (canApply && !alreadyApplied) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: isApplying ? null : onApply,
                        icon: isApplying
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.check_rounded,
                                size: 19,
                              ),
                        label: Text(
                          isApplying ? "Aplicando..." : "Aplicar cambios",
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: type == "schedule_workout"
                              ? TColor.primerColor1
                              : type == "update_sleep_goal_profile"
                                  ? Colors.indigo
                                  : TColor.rojo,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isLoading;

  const _ChatBubble({
    required this.text,
    required this.isUser,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 290,
        ),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: isUser ? TColor.rojo : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: isLoading
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: TColor.rojo,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    text,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 13,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  color: isUser ? Colors.white : TColor.negro,
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}