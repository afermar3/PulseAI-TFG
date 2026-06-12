import 'package:afermar3_tf_ipc/info_user/sign_up_view.dart';
import 'package:afermar3_tf_ipc/main_tab/main_tab_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/services/auth_service.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:afermar3_tf_ipc/info_user/forgot_password_view.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginView();
}

class _LoginView extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos.'),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await AuthService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainTabView(),
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

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.blanco,
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
                  const SizedBox(height: 35),

                  Text(
                    "Hola de nuevo,",
                    style: TextStyle(color: TColor.gris, fontSize: 17),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Inicia sesión",
                    style: TextStyle(
                      color: TColor.negro,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  SizedBox(height: media.height * 0.07),

                  EditTextField(
                    controller: emailController,
                    hintText: "Correo electrónico",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),

                  const SizedBox(height: 16),

                  EditTextField(
                    controller: passwordController,
                    hintText: "Contraseña",
                    icon: "assets/img/lock.png",
                    obscureText: obscurePassword,
                    validator: validatecontra,
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

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ForgotPasswordView(),
                                ),
                              );
                            },
                      child: Text(
                        "¿Has olvidado tu contraseña?",
                        style: TextStyle(
                          color: TColor.gris,
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: media.height * 0.22),

                  botonredondo(
                    title: isLoading ? "Entrando..." : "Iniciar sesión",
                    onPressed: isLoading ? () {} : _login,
                  ),

                  const SizedBox(height: 26),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUp(),
                              ),
                            );
                          },
                    child: RichText(
                      text: TextSpan(
                        text: "¿Aún no tienes una cuenta? ",
                        style: TextStyle(
                          color: TColor.negro,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: "Regístrate",
                            style: TextStyle(
                              color: TColor.rojo,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}