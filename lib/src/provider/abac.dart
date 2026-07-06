import 'package:flutter/widgets.dart';

import '../models/abac_access_result.dart';
import 'abac_scope.dart';

class Abac {
  const Abac._(this._result);

  factory Abac.of(BuildContext context) {
    final scope = AbacScope.maybeOf(context);
    if (scope == null || !scope.isReady) {
      return const Abac._(AbacAccessResult.unavailable());
    }

    return Abac._(AbacAccessResult.ready(scope.permissions));
  }

  final AbacAccessResult _result;

  bool get isReady => _result.isReady;

  bool can(String feature, String action) => _result.can(feature, action);
}
