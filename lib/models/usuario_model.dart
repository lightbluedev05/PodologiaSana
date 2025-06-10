class Usuario {
  String username;
  String password;
  String rol;

  Usuario({
    required this.username,
    this.password = '',
    this.rol = '',
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    username: json['username'],
    rol: json['rol'],
  );

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
  };
}
