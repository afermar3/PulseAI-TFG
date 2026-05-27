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

  final List<Map<String, dynamic>> _messages = [
    {
      "isUser": false,
      "text":
          "Hola, soy tu Coach IA de PulseAI. Puedes preguntarme sobre entrenamiento, comida, sueño o hábitos saludables.",
    },
  ];

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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isLoading || _isApplyingAction) return;

    setState(() {
      _messages.add({
        "isUser": true,
        "text": text,
      });

      _messages.add({
        "isUser": false,
        "text": "Pensando...",
        "isLoading": true,
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
          };
        } else {
          _messages.add({
            "isUser": false,
            "text": errorMessage,
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
    if (_isApplyingAction || _isLoading) return;

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
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? TColor.rojo : Colors.orange,
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
    if (_isLoading || _isApplyingAction) return;

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

  return type == "add_workout_day" ||
      type == "add_exercise_to_day" ||
      type == "replace_exercise" ||
      type == "update_exercise_config";
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
                  ...List.generate(_messages.length, (index) {
                    final message = _messages[index];
                    final isLoadingMessage = message["isLoading"] == true;
                    final isUser = message["isUser"] == true;
                    final pendingAction = _safeMap(message["pendingAction"]);
                    final actionApplied = message["actionApplied"] == true;

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
                            canApply:
                                _canApplyAction(pendingAction) && !actionApplied,
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
              onTap: _isLoading || _isApplyingAction
                  ? null
                  : () {
                      _sendQuickAction(item["title"].toString());
                    },
              child: Opacity(
                opacity: _isLoading || _isApplyingAction ? 0.55 : 1,
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
              enabled: !_isLoading && !_isApplyingAction,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!_isLoading && !_isApplyingAction) {
                  _sendMessage();
                }
              },
              decoration: InputDecoration(
                hintText: _isApplyingAction
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
            onTap: _isLoading || _isApplyingAction ? null : _sendMessage,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoading || _isApplyingAction
                      ? [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ]
                      : TColor.primerG,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: _isLoading || _isApplyingAction
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

  String _extractSummary() {
    final type = action["type"]?.toString() ?? "";
    final payload = action["payload"];

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

    if (type == "replace_exercise" && payload is Map) {
      final oldExercise = payload["old_exercise"]?.toString() ?? "Ejercicio actual";
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

  final updateText = parts.isEmpty ? "Actualizar configuración" : parts.join(" · ");

  return "$exerciseName · Día $dayNumber - $dayName · $updateText";
}

        return action["description"]?.toString() ?? "Acción propuesta por PulseAI";
      }

  @override
  Widget build(BuildContext context) {
    final title = action["title"]?.toString() ?? "Propuesta de cambio";
    final type = action["type"]?.toString() ?? "";
    final isErrorType = type == "missing_exercises" || type == "not_enough_exercises";

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
                    alreadyApplied ? "Cambios aplicados" : title,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alreadyApplied
                        ? "Esta propuesta ya se ha añadido a tu rutina."
                        : _extractSummary(),
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
                          backgroundColor: TColor.rojo,
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