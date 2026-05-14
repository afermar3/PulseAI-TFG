import 'package:flutter/material.dart';

class TColor {
  // Colores principales en rojo
  static Color get primaryColor1 => const Color(0xffD00000);
  static Color get primaryColor2 => const Color(0xff7A0000);

  static Color get secondaryColor1 => const Color(0xffFF4D4D);
  static Color get secondaryColor2 => const Color(0xffB00000);

  static List<Color> get primaryG => [
        primaryColor2,
        primaryColor1,
      ];

  static List<Color> get secondaryG => [
        secondaryColor2,
        secondaryColor1,
      ];

  static Color get black => const Color(0xff1D1617);
  static Color get gray => const Color(0xff786F72);
  static Color get white => Colors.white;
  static Color get lightGray => const Color(0xffF7F8F8);

  // Alias en español, por si tu código usa nombres antiguos
  static Color get rojo => primaryColor1;
  static Color get negro => black;
  static Color get gris => gray;
  static Color get blanco => white;
  static Color get grisClaro => lightGray;

  static Color get primerColor1 => primaryColor1;
  static Color get primerColor2 => primaryColor2;
  static Color get segundoColor1 => secondaryColor1;
  static Color get segundoColor2 => secondaryColor2;

  static List<Color> get primerG => primaryG;
  static List<Color> get segundoG => secondaryG;
}
