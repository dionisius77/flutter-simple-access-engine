import 'package:flutter/widgets.dart';

import '../utils/permissions.dart';
import 'abac_scope.dart';

class AbacProvider extends StatelessWidget {
  const AbacProvider({
    super.key,
    required this.permissions,
    required this.child,
  });

  final Map<String, List<String>>? permissions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final normalizedPermissions = normalizePermissions(permissions);

    return AbacScope(
      permissions: normalizedPermissions,
      isReady: permissions != null,
      child: child,
    );
  }
}
