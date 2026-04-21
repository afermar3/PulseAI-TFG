import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:afermar3_tf_ipc/widgets/user.dart';
import 'package:flutter/material.dart';

class EditTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String hintText;
  final String icon;
  final Widget? rightIcon;
  final bool obscureText;
  final EdgeInsets? margin;
  final String? Function(String?)? validator;

  const EditTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.controller,
    this.margin,
    this.keyboardType,
    this.obscureText = false,
    this.rightIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
          color: TColor.rojo, borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        style: TextStyle(color: TColor.blanco),
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
          suffixIcon: rightIcon,
          prefixIcon: Container(
              alignment: Alignment.center,
              width: 20,
              height: 20,
              child: Image.asset(
                icon,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                color: TColor.blanco,
              )),
          hintStyle: TextStyle(color: TColor.blanco, fontSize: 12),
          errorStyle: TextStyle(color: TColor.blanco),
        ),
        validator: validator,
      ),
    );
  }
}
