import 'package:flutter/widgets.dart';

class AbacScope extends InheritedWidget {
  const AbacScope({
    super.key,
    required this.permissions,
    required this.isReady,
    required super.child,
  });

  final Map<String, List<String>> permissions;
  final bool isReady;

  static AbacScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AbacScope>();
  }

  @override
  bool updateShouldNotify(covariant AbacScope oldWidget) {
    return oldWidget.isReady != isReady ||
        !_samePermissions(oldWidget.permissions, permissions);
  }

  bool _samePermissions(
    Map<String, List<String>> left,
    Map<String, List<String>> right,
  ) {
    if (left.length != right.length) {
      return false;
    }

    for (final entry in left.entries) {
      final otherActions = right[entry.key];
      if (otherActions == null) {
        return false;
      }

      if (entry.value.length != otherActions.length) {
        return false;
      }

      for (var index = 0; index < entry.value.length; index++) {
        if (entry.value[index] != otherActions[index]) {
          return false;
        }
      }
    }

    return true;
  }
}
