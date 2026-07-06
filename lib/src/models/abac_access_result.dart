import '../utils/permissions.dart';

class AbacAccessResult {
  const AbacAccessResult._({required this.isReady, required this.permissions});

  const AbacAccessResult.unavailable()
    : this._(isReady: false, permissions: const <String, List<String>>{});

  const AbacAccessResult.ready(Map<String, List<String>> permissions)
    : this._(isReady: true, permissions: permissions);

  final bool isReady;
  final Map<String, List<String>> permissions;

  bool can(String feature, String action) {
    if (!isReady) {
      return false;
    }

    return hasAccess(permissions, feature, action);
  }
}
