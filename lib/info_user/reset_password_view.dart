import 'package:afermar3_tf_ipc/info_user/login_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/auth_service.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:flutter/material.dart';

class ResetPasswordView extends StatefulWidget {
  final String resetToken;

  const ResetPasswordView({
    super.key,
    required this.resetToken,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Introduce una contraseña";
    }

    if (value.trim().length < 6) {
      return "La contraseña debe tener al menos 6 caracteres";
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Repite la contraseña";
    }

    if (value.trim() != passwordController.text.trim()) {
      return "Las contraseñas no coinciden";
    }

    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final message = await AuthService.resetPassword(
        token: widget.resetToken,
        newPassword: passwordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
        (route) => false,
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
          "Nueva contraseña",
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
                      Icons.password_rounded,
                      color: TColor.rojo,
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Crea una nueva contraseña",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Introduce una nueva contraseña para recuperar el acceso a tu cuenta.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.gris,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 34),
                  EditTextField(
                    controller: passwordController,
                    hintText: "Nueva contraseña",
                    icon: "assets/img/lock.png",
                    obscureText: obscurePassword,
                    validator: _validatePassword,
                    rightIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: TColor.gris,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  EditTextField(
                    controller: confirmPasswordController,
                    hintText: "Repetir contraseña",
                    icon: "assets/img/lock.png",
                    obscureText: obscureConfirmPassword,
                    validator: _validateConfirmPassword,
                    rightIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: TColor.gris,
                        size: 22,
                      ),
                    ),
                  ),
                  SizedBox(height: media.height * 0.10),
                  botonredondo(
                    title: isLoading ? "Actualizando..." : "Cambiar contraseña",
                    onPressed: isLoading ? () {} : _resetPassword,
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