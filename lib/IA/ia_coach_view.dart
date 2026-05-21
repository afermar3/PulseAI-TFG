import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/ai_chat_service.dart';
import 'package:afermar3_tf_ipc/IA/ai_generated_workout_view.dart';
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _isLoading) return;

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
      final answer = await AiChatService.sendMessage(text);

      if (!mounted) return;

      setState(() {
        final loadingIndex = _messages.indexWhere(
          (message) => message["isLoading"] == true,
        );

        if (loadingIndex != -1) {
          _messages[loadingIndex] = {
            "isUser": false,
            "text": answer,
          };
        } else {
          _messages.add({
            "isUser": false,
            "text": answer,
          });
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

  void _sendQuickAction(String action) {
    if (_isLoading) return;

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
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TColor.negro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
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
                  ..._messages.map((message) {
                    final isLoadingMessage = message["isLoading"] == true;

                    return _ChatBubble(
                      text: message["text"].toString(),
                      isUser: message["isUser"] as bool,
                      isLoading: isLoadingMessage,
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
              onTap: _isLoading
                  ? null
                  : () {
                      _sendQuickAction(item["title"].toString());
                    },
              child: Opacity(
                opacity: _isLoading ? 0.55 : 1,
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
              enabled: !_isLoading,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (!_isLoading) {
                  _sendMessage();
                }
              },
              decoration: InputDecoration(
                hintText: _isLoading
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
            onTap: _isLoading ? null : _sendMessage,
            child: Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isLoading
                      ? [
                          Colors.grey.shade400,
                          Colors.grey.shade500,
                        ]
                      : TColor.primerG,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: _isLoading
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