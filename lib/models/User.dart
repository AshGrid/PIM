class User {
  final String id;
  final String name;
  final String email;
  final String image;
  final String password;
  final String passwordConfirmation;


  User({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.password,
    required this.passwordConfirmation,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      image: json['image'] as String,
      passwordConfirmation: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'image': image,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }
}
