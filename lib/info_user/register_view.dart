import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/funcionalidad/objetivo.dart';
import 'package:afermar3_tf_ipc/widgets/campostexto.dart';
import 'package:afermar3_tf_ipc/widgets/boton.dart';
import 'package:flutter/material.dart';

enum Genero { Hombre, Mujer, Otro }

class CompleteProfileView extends StatefulWidget {
  const CompleteProfileView({super.key});

  @override
  State<CompleteProfileView> createState() => _CompleteProfileViewState();
}

class _CompleteProfileViewState extends State<CompleteProfileView> {
  TextEditingController txtDate = TextEditingController();
  TextEditingController txtpeso = TextEditingController();
  TextEditingController txtaltura = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isCheck = false;
  Genero _selectedHouse = Genero.Otro;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Completa tu perfil'), // Set your desired title
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: TColor.blanco,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/img/tu propio gym_completar.png",
                    width: media.width,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Text(
                    "Vamos a acabar de completar el perfil",
                    style: TextStyle(
                        color: TColor.negro,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "Necesitamos saber mas de ti!",
                    style: TextStyle(color: TColor.gris, fontSize: 12),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: TColor.rojo,
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Container(
                                  alignment: Alignment.center,
                                  width: 50,
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: Image.asset(
                                    "assets/img/gender.png",
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.contain,
                                    color: TColor.blanco,
                                  )),
                              Expanded(
                                child: DropdownButtonFormField<Genero>(
                                  value: _selectedHouse,
                                  items: Genero.values
                                      .map((Genero h) =>
                                          DropdownMenuItem<Genero>(
                                            value: h,
                                            child: Text(h.name),
                                          ))
                                      .toList(),
                                  onSaved: (house) =>
                                      _selectedHouse = house ?? Genero.Otro,
                                  onChanged: (house) =>
                                      setState(() => _selectedHouse = house!),
                                  validator: (house) => null,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: TColor.blanco),
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: TColor.blanco),
                                    ),
                                  ),
                                  style: TextStyle(
                                      color: TColor
                                          .blanco), // Establecer el color del texto aquí
                                  dropdownColor: TColor.rojo,
                                ),
                              ),
                              const SizedBox(
                                width: 8,
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        EditTextField(
                          controller: txtDate,
                          hintText: "Fecha de nacimiento",
                          icon: "assets/img/date.png",
                          validator: validatefecha,
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        Row(
                          children: [
                            //ya que tenemos el txtpeso que es la informacion del campo de texto del peso comprobar si se ha escrito algo
                            Expanded(
                              child: EditTextField(
                                controller: txtpeso,
                                hintText: "PESO",
                                icon: "assets/img/weight.png",
                                validator: validatepeso,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: TColor.segundoG,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                "KG",
                                style: TextStyle(
                                    color: TColor.blanco, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.04,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: EditTextField(
                                controller: txtaltura,
                                hintText: "ALTURA",
                                icon: "assets/img/hight.png",
                                validator: validateAltura,
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: TColor.segundoG,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                "CM",
                                style: TextStyle(
                                    color: TColor.blanco, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.07,
                        ),
                        botonredondo(
                          title: "Siguiente",
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
                                  content: Text(
                                      'Por favor completa todos los campos.'),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
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

String? validateAltura(String? value) {
  if (value == null || value.isEmpty) {
    return 'Introduce tu altura en cm';
  }

  try {
    double height = double.parse(value);
    if (height <= 0) {
      return 'Debe ser un numero positivo';
    }
    return null;
  } catch (e) {
    return 'No puede ser una letra, sino un numero';
  }
}

String? validatepeso(String? value) {
  if (value == null || value.isEmpty) {
    return 'Introduce tu peso en kg';
  }

  try {
    double weight = double.parse(value);
    if (weight <= 0) {
      return 'Debe ser un numero positivo.';
    }
    return null;
  } catch (e) {
    return 'No puede ser una letra, sino un numero';
  }
}

String? validatefecha(String? value) {
  if (value == null || value.isEmpty) {
    return 'Introduce tu fecha de cumpleaños';
  }

  try {
    DateTime birthday = DateTime.parse(value);
    DateTime today = DateTime.now();

    if (birthday.isAfter(today)) {
      return 'La fecha no puede ser de futuro';
    }

    return null;
  } catch (e) {
    return 'Formato incorrecto. Utiliza el formato AÑO-MES-DIA';
  }
}
