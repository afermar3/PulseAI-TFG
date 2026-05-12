enum Genero { hombre, mujer, otro }

class UserProfile {
  String? name;
  String? apellidos;
  String? email;
  String? password;

  Genero genero;
  String? fechaNacimiento;
  double? peso;
  double? altura;
  String? objetivo;

  bool perfilCompletado;

  UserProfile({
    this.name,
    this.apellidos,
    this.email,
    this.password,
    this.genero = Genero.otro,
    this.fechaNacimiento,
    this.peso,
    this.altura,
    this.objetivo,
    this.perfilCompletado = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "apellidos": apellidos,
      "email": email,
      "password": password,
      "genero": genero.name,
      "fechaNacimiento": fechaNacimiento,
      "peso": peso,
      "altura": altura,
      "objetivo": objetivo,
      "perfilCompletado": perfilCompletado,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json["name"],
      apellidos: json["apellidos"],
      email: json["email"],
      password: json["password"],
      genero: Genero.values.firstWhere(
        (g) => g.name == json["genero"],
        orElse: () => Genero.otro,
      ),
      fechaNacimiento: json["fechaNacimiento"],
      peso: json["peso"] != null ? (json["peso"] as num).toDouble() : null,
      altura: json["altura"] != null ? (json["altura"] as num).toDouble() : null,
      objetivo: json["objetivo"],
      perfilCompletado: json["perfilCompletado"] ?? false,
    );
  }
}
