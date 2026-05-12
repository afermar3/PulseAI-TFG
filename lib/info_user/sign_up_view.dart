import 'package:afermar3_tf_ipc/info_user/login_view.dart';
import 'package:afermar3_tf_ipc/info_user/politica_privacidad.dart';
import 'package:afermar3_tf_ipc/info_user/info_register_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpView();
}

class _SignUpView extends State<SignUp> {
  bool isCheck = false;
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 28),

                Text(
                  "Bienvenido,",
                  style: TextStyle(color: TColor.gris, fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  "Crear cuenta",
                  style: TextStyle(
                    color: TColor.negro,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                SizedBox(height: media.height * 0.045),

                const EditTextField(
                  hintText: "Nombre",
                  icon: "assets/img/user_text.png",
                  validator: validateName,
                ),
                const SizedBox(height: 16),

                const EditTextField(
                  hintText: "Apellidos",
                  icon: "assets/img/user_text.png",
                  validator: validateapellido,
                ),
                const SizedBox(height: 16),

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
                      color: TColor.negro,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isCheck,
                      activeColor: TColor.rojo,
                      onChanged: (value) {
                        setState(() {
                          isCheck = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: GestureDetector(
                          onTap: _showMyAlert,
                          child: Text(
                            "Acepto la Política de Privacidad y los Términos de uso",
                            style: TextStyle(
                              color: TColor.gris,
                              fontSize: 12,
                              height: 1.35,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                botonredondo(
                  title: "Registrarme",
                  onPressed: () {
                    if (_formKey.currentState!.validate() && isCheck) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CompleteProfileView(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isCheck
                                ? 'Por favor completa todos los campos.'
                                : 'Debes aceptar la Política de Privacidad y los Términos de uso.',
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
                      onTap: () {},
                    ),
                    const SizedBox(width: 18),
                    _SocialButton(
                      image: "assets/img/facebook.png",
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: "¿Ya tienes una cuenta? ",
                      style: TextStyle(
                        color: TColor.negro,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Inicia sesión",
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
    );
  }

  void _showMyAlert() async {
    final content =
        await rootBundle.loadString('assets/texto/Politica_privacidad.txt');

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return MyAlert(content: content);
      },
    );

    setState(() {
      isCheck = result == 'Aceptar';
    });
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

String? validateName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Introduce un nombre';
  }
  return null;
}

String? validateapellido(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Introduce un apellido';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || !value.contains('@')) {
    return 'Introduce un correo válido';
  }
  return null;
}

String? validatecontra(String? value) {
  if (value == null || value.isEmpty) {
    return 'Introduce una contraseña válida';
  }
  if (value.length < 8) {
    return 'La contraseña debe tener al menos 8 caracteres';
  }
  return null;
}