import 'package:afermar3_tf_ipc/funcionalidad/objetivo.dart';
import 'package:afermar3_tf_ipc/info_user/register_view.dart';
import 'package:afermar3_tf_ipc/info_user/sign_up_view.dart';
import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginView();
}

class _LoginView extends State<Login> {
  bool isCheck = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.blanco,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
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
                    "Logeate",
                    style: TextStyle(
                        color: TColor.negro,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
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
                              color: TColor.gris,
                            ))),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Has olvidado tu constraseña?",
                        style: TextStyle(
                            color: TColor.gris,
                            fontSize: 10,
                            decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                  const Spacer(), //falta controlador para campo de texto
                  botonredondo(
                    title: "Login",
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const objetivo(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Por favor completa todos los campos.'),
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
                        height: 1,
                        color: TColor.gris.withOpacity(0.5),
                      )),
                      Text(
                        "  O  ",
                        style: TextStyle(color: TColor.negro, fontSize: 12),
                      ),
                      Expanded(
                          child: Container(
                        height: 1,
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
                      Navigator.pop(context);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Aun no tienes una cuenta creada? ",
                          style: TextStyle(
                            color: TColor.negro,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Registrar",
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
}
