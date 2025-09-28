import 'package:firebase_auth/firebase_auth.dart';

class RoleService {
  const RoleService();

  /// Retorna o conjunto de roles do usuário atual, ex.: {'admin', 'professor'}
  Future<Set<String>> getRoles({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};
    final token = await user.getIdTokenResult(forceRefresh);
    final claims = token.claims ?? {};

    // Preferimos uma claim 'roles': ['admin', 'professor']
    final raw = claims['roles'];
    if (raw is List) {
      return raw.map((e) => e.toString()).toSet();
    }

    // Fallback para flags booleanas
    final roles = <String>{};
    if (claims['admin'] == true) roles.add('admin');
    if (claims['professor'] == true) roles.add('professor');
    return roles;
  }
}
