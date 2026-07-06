import 'package:flutter/widgets.dart';

import '../provider/abac.dart';

extension BuildContextAbacExtension on BuildContext {
  bool can(String feature, String action) => Abac.of(this).can(feature, action);
}
