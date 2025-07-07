class Usuario {
  String username;
  String password;
  String rol;
  int? idDoctor;
  Map<String, dynamic>? doctor;

  Usuario({
    required this.username,
    this.password = '',
    this.rol = '',
    this.idDoctor,
    this.doctor,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    username: json['username'],
    rol: json['rol'],
    idDoctor: json['id_doctor'],
    doctor: json['doctor'],
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}
