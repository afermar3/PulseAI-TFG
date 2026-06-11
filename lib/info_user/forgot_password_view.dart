import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/info_user/reset_password_view.dart';
import 'package:afermar3_tf_ipc/services/auth_service.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:flutter/material.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await AuthService.forgotPassword(
        email: emailController.text.trim(),
      );

      if (!mounted) return;

      final resetToken = response["reset_token"];

      if (resetToken == null || resetToken.toString().trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response["message"] ??
                  "Si el correo existe, se generará una solicitud de recuperación.",
            ),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordView(
            resetToken: resetToken.toString(),
          ),
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
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return "Introduce tu correo electrónico";
  }

  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');

  if (!emailRegex.hasMatch(value.trim())) {
    return "Introduce un correo válido";
  }

  return null;
}

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        leading: IconButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColor.negro,
          ),
        ),
        centerTitle: true,
        title: Text(
          "Recuperar contraseña",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: media.height - MediaQuery.of(context).padding.top,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(height: media.height * 0.08),
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: TColor.rojo.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.lock_reset_rounded,
                      color: TColor.rojo,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "¿Has olvidado tu contraseña?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Introduce tu correo electrónico y generaremos una solicitud para cambiar tu contraseña.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 34),
                  EditTextField(
                    controller: emailController,
                    hintText: "Correo electrónico",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  SizedBox(height: media.height * 0.12),
                  botonredondo(
                    title: isLoading ? "Generando..." : "Continuar",
                    onPressed: isLoading ? () {} : _sendRecoveryRequest,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}