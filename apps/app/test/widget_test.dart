import 'package:bianjie_ai_app/app/app.dart';
import 'package:bianjie_ai_app/core/theme/app_colors.dart';
import 'package:bianjie_ai_app/core/theme/app_theme_provider.dart';
import 'package:bianjie_ai_app/features/home/presentation/home_page.dart';
import 'package:bianjie_ai_app/features/profile/presentation/settings_page.dart';
import 'package:bianjie_ai_app/features/tool_runner/presentation/tool_runner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows home tab on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BianjieAiApp()));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.dark,
    );

    expect(find.text('首页'), findsWidgets);
    expect(find.text('功能'), findsOneWidget);
    expect(find.text('股票'), findsOneWidget);
    expect(find.text('智能体'), findsOneWidget);
    expect(find.text('写作'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
  });

  testWidgets('switches between night and signal themes',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const BianjieAiApp(),
      ),
    );
    await tester.pumpAndSettle();

    container.read(appVisualThemeProvider.notifier).state =
        AppVisualTheme.signal;
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.light,
    );
    expect(
      Theme.of(tester.element(find.byType(HomePage))).colorScheme.primary,
      const Color(0xFF1597A6),
    );
    expect(
      Theme.of(tester.element(find.byType(HomePage))).colorScheme.onPrimary,
      Colors.white,
    );
    expect(
      Theme.of(tester.element(find.byType(HomePage))).scaffoldBackgroundColor,
      const Color(0xFFFAFBFA),
    );
    expect(
      Theme.of(tester.element(find.byType(HomePage)))
          .textTheme
          .titleLarge
          ?.fontWeight,
      FontWeight.w600,
    );
    expect(
      Theme.of(tester.element(find.byType(HomePage)))
          .chipTheme
          .labelStyle
          ?.fontWeight,
      FontWeight.w500,
    );
    expect(
      Theme.of(tester.element(find.byType(HomePage)))
          .navigationBarTheme
          .indicatorColor,
      Colors.transparent,
    );
    expect(find.byType(NavigationDestination), findsNWidgets(6));

    container.read(appVisualThemeProvider.notifier).state =
        AppVisualTheme.night;
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(HomePage))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('settings switch selects signal theme',
      (WidgetTester tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(container.read(appVisualThemeProvider), AppVisualTheme.night);
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    expect(container.read(appVisualThemeProvider), AppVisualTheme.signal);
  });

  testWidgets('renders dynamic tool parameters', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ToolRunnerPage(toolId: 'pdf-convert'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('PDF 转换'), findsWidgets);
    expect(find.text('运行参数'), findsOneWidget);
    expect(find.text('输出格式 *'), findsOneWidget);
    expect(find.text('扫描件 OCR'), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('输入附件'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('输入附件'), findsOneWidget);
  });

  testWidgets('renders protocol v2 segmented and slider fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ToolRunnerPage(toolId: 'document-to-ppt'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('输出语言'), findsOneWidget);
    expect(find.byType(SegmentedButton<String>), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    await tester.dragUntilVisible(
      find.text('输入附件'),
      find.byType(ListView),
      const Offset(0, -300),
    );
    expect(find.text('输入附件'), findsOneWidget);
  });

  testWidgets('home sends chat message and renders assistant reply',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomePage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      '帮我写一段产品介绍',
    );
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    expect(find.text('帮我写一段产品介绍'), findsWidgets);
    expect(find.textContaining('本地 mock 回复'), findsOneWidget);
    expect(find.text('新对话'), findsOneWidget);
  });
}
