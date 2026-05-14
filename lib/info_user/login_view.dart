import 'package:afermar3_tf_ipc/Home/pantalla_home.dart';
import 'package:afermar3_tf_ipc/funcionalidad/menu_principal.dart';
import 'package:afermar3_tf_ipc/funcionalidad/objetivo.dart';
import 'package:afermar3_tf_ipc/home/pantalla_home.dart';
import 'package:afermar3_tf_ipc/info_user/sign_up_view.dart';
import 'package:afermar3_tf_ipc/main_tab/main_tab_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginView();
}

class _LoginView extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;

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

                  const EditTextField(
                    hintText: "Correo electrónico",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),

                  const SizedBox(height: 16),

                  EditTextField(
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
                      onPressed: () {
                        // Más adelante aquí pondremos recuperación de contraseña
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
                    title: "Iniciar sesión",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainTabView(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor completa todos los campos.',
                            ),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1,
                          color: TColor.gris.withOpacity(0.3),
                        ),
                      ),
                      Text(
                        "  O  ",
                        style: TextStyle(color: TColor.gris, fontSize: 13),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: TColor.gris.withOpacity(0.3),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialButton(
                        image: "assets/img/google.png",
                        onTap: () {
                          // Más adelante login con Google
                        },
                      ),
                      const SizedBox(width: 18),
                      _SocialButton(
                        image: "assets/img/facebook.png",
                        onTap: () {
                          // Más adelante login con Facebook
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  TextButton(
                    onPressed: () {
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

class _SocialButton extends StatelessWidget {
  final String image;
  final VoidCallback onTap;

  const _SocialButton({
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: TColor.blanco,
          border: Border.all(
            width: 1,
            color: TColor.gris.withOpacity(0.25),
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Image.asset(
          image,
          width: 24,
          height: 24,
        ),
      ),
    );
  }
}