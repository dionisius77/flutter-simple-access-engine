import 'package:flutter/material.dart';

import '../provider/abac.dart';

class AbacPage extends StatelessWidget {
  const AbacPage({
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
      return loading ?? const Center(child: CircularProgressIndicator());
    }

    if (abac.can(feature, action)) {
      return child;
    }

    return fallback ?? const _ForbiddenWidget();
  }
}

class _ForbiddenWidget extends StatelessWidget {
  const _ForbiddenWidget();

  @override
  Widget build(BuildContext context) {
    return const Material(child: Center(child: Text('403 Forbidden')));
  }
}
