import 'package:afermar3_tf_ipc/info_user/politica_privacidad.dart';
import 'package:afermar3_tf_ipc/info_user/login_view.dart';
import 'package:afermar3_tf_ipc/info_user/register_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpView();
}

class _SignUpView extends State<SignUp> {
  bool isCheck = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hola de nuevo,",
                    style: TextStyle(color: TColor.gris, fontSize: 16),
                  ),
                  Text(
                    "Crear cuenta",
                    style: TextStyle(
                        color: TColor.negro,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  const EditTextField(
                    hintText: "Nombre",
                    icon: "assets/img/user_text.png",
                    validator: validateName,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  const EditTextField(
                    hintText: "Apellidos",
                    icon: "assets/img/user_text.png",
                    validator: validateapellido,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  const EditTextField(
                    hintText: "Correo",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    validator: validateEmail,
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  EditTextField(
                    hintText: "Contraseña",
                    icon: "assets/img/lock.png",
                    obscureText: true,
                    validator: validatecontra,
                    rightIcon: TextButton(
                        onPressed: () {},
                        child: Container(
                            alignment: Alignment.center,
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              "assets/img/show_password.png",
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              color: TColor.negro,
                            ))),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _showMyAlert,
                        icon: Icon(
                          isCheck
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: TColor.negro,
                          size: 20,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          "Para continuar debes aceptar la Politica de Privacidad y\nTerminos de uso",
                          style: TextStyle(color: TColor.gris, fontSize: 10),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.4,
                  ),
                  botonredondo(
                    title: "Registrar",
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
                            content: Text(isCheck
                                ? 'Por favor completa todos los campos.'
                                : 'Debes aceptar la Política de Privacidad y los Términos de uso.'),
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                        height: 2,
                        color: TColor.gris.withOpacity(0.5),
                      )),
                      Text(
                        "  O  ",
                        style: TextStyle(color: TColor.negro, fontSize: 12),
                      ),
                      Expanded(
                          child: Container(
                        height: 2,
                        color: TColor.gris.withOpacity(0.5),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: TColor.blanco,
                            border: Border.all(
                              width: 1,
                              color: TColor.gris.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.asset(
                            "assets/img/google.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: media.width * 0.04,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: TColor.blanco,
                            border: Border.all(
                              width: 1,
                              color: TColor.gris.withOpacity(0.4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Image.asset(
                            "assets/img/facebook.png",
                            width: 20,
                            height: 20,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()));
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Ya tienes una cuenta creada? ",
                          style: TextStyle(
                            color: TColor.negro,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Login",
                          style: TextStyle(
                              color: TColor.rojo,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.04,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMyAlert() async {
    // Leer el contenido del archivo
    String content =
        await rootBundle.loadString('assets/texto/Politica_privacidad.txt');

    String result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return MyAlert(content: content);
      },
    );

    setState(() {
      if (result == 'Aceptar') {
        isCheck = true;
      } else if (result == 'Cancelar') {
        isCheck = false;
      }
    });
  }
}

String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return 'Introduce un nombre';
  }
  return null;
}

String? validateapellido(String? value) {
  if (value == null || value.isEmpty) {
    return 'Introduce un apellido';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || !value.contains('@')) {
    return 'Introduce un correo';
  }
  return null;
}

String? validatecontra(String? value) {
  if (value == null || value.isEmpty) {
    return 'Introduce una contraseña valida';
  }
  if (value.length < 8) {
    return 'La contraseña debe tener mas de 8 caracteres';
  }
  return null;
}
