import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';

final appVisualThemeProvider = StateProvider<AppVisualTheme>(
  (ref) => AppVisualTheme.night,
);
