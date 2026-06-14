import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/auth_service.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:flutter/material.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Introduce una contraseña";
    }

    if (value.length < 8) {
      return "La contraseña debe tener al menos 8 caracteres";
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Repite la nueva contraseña";
    }

    if (value != newPasswordController.text) {
      return "Las contraseñas no coinciden";
    }

    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final message = await AuthService.changePassword(
        currentPassword: currentPasswordController.text.trim(),
        newPassword: newPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

      Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: TColor.blanco,
      appBar: AppBar(
        backgroundColor: TColor.blanco,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: TColor.negro,
          ),
        ),
        title: Text(
          "Cambiar contraseña",
          style: TextStyle(
            color: TColor.negro,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
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
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: TColor.rojo.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: TColor.rojo,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Actualiza tu contraseña para mantener segura tu cuenta.",
                          style: TextStyle(
                            color: TColor.gris,
                            fontSize: 13,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                EditTextField(
                  controller: currentPasswordController,
                  hintText: "Contraseña actual",
                  icon: "assets/img/lock.png",
                  obscureText: obscureCurrentPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Introduce tu contraseña actual";
                    }

                    return null;
                  },
                  rightIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              obscureCurrentPassword = !obscureCurrentPassword;
                            });
                          },
                    icon: Icon(
                      obscureCurrentPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: TColor.gris,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                EditTextField(
                  controller: newPasswordController,
                  hintText: "Nueva contraseña",
                  icon: "assets/img/lock.png",
                  obscureText: obscureNewPassword,
                  validator: _validatePassword,
                  rightIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                    icon: Icon(
                      obscureNewPassword
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
                  hintText: "Repetir nueva contraseña",
                  icon: "assets/img/lock.png",
                  obscureText: obscureNewPassword,
                  validator: _validateConfirmPassword,
                  rightIcon: IconButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            setState(() {
                              obscureNewPassword = !obscureNewPassword;
                            });
                          },
                    icon: Icon(
                      obscureNewPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: TColor.gris,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                botonredondo(
                  title: isLoading ? "Actualizando..." : "Cambiar contraseña",
                  onPressed: isLoading ? () {} : _changePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
