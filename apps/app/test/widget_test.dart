import 'package:bianjie_ai_app/app/app.dart';
import 'package:bianjie_ai_app/features/home/presentation/home_page.dart';
import 'package:bianjie_ai_app/features/tool_runner/presentation/tool_runner_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('shows home tab on launch', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BianjieAiApp()));
    await tester.pumpAndSettle();

    expect(find.text('首页'), findsWidgets);
    expect(find.text('功能'), findsOneWidget);
    expect(find.text('股票'), findsOneWidget);
    expect(find.text('智能体'), findsOneWidget);
    expect(find.text('写作'), findsOneWidget);
    expect(find.text('我的'), findsOneWidget);
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
