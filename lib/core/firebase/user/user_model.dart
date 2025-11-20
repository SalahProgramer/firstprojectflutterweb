class UserItem {
  final String id;
  final String token;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String city;
  final String area;
  final String address;
  final String gender;
  final String birthdate;

  UserItem({
    required this.id,
    required this.token,
    required this.name,
    required this.gender,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
    required this.area,
    required this.address,
    required this.birthdate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'name': name,
      'birthdate': birthdate,
      'gender': gender,
      'email': email,
      'password': password,
      'phone': phone,
      'city': city,
      'area': area,
      'address': address,
    };
  }

  factory UserItem.fromMap(Map<String, dynamic>? map) {
    return UserItem(
      id: map?['id'] ?? '',
      token: map?['token'] ?? '',
      name: map?['name'] ?? '',
      birthdate: map?['birthdate'] ?? '',
      gender: map?['gender'] ?? '',
      email: map?['email'] ?? '',
      password: map?['password'] ?? "",
      phone: map?['phone'] ?? "",
      city: map?['city'] ?? "",
      area: map?['area'] ?? "",
      address: map?['address'] ?? "",
    );
  }
}
