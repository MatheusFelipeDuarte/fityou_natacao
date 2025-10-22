class UserAccount {
  final String id; // uid
  final String email;
  final List<String> roles;

  UserAccount({required this.id, required this.email, required this.roles});

  factory UserAccount.fromMap(String id, Map<String, dynamic> data) {
    final roles = (data['roles'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
    return UserAccount(
      id: id,
      email: (data['email'] ?? '') as String,
      roles: roles,
    );
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'roles': roles,
      };
}
