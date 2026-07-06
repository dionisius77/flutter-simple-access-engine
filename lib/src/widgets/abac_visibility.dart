import 'package:flutter/widgets.dart';

import '../provider/abac.dart';

class AbacVisibility extends StatelessWidget {
  const AbacVisibility({
    super.key,
    required this.feature,
    required this.action,
    required this.child,
    this.fallback,
    this.loading,
  });

  final String feature;
  final String action;
  final Widget child;
  final Widget? fallback;
  final Widget? loading;

  @override
  Widget build(BuildContext context) {
    final abac = Abac.of(context);

    if (!abac.isReady) {
      return loading ?? const SizedBox.shrink();
    }

    if (abac.can(feature, action)) {
      return child;
    }

    return fallback ?? const SizedBox.shrink();
  }
}
