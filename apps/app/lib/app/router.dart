import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/agents/presentation/agents_page.dart';
import '../features/agents/presentation/agent_template_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/profile/presentation/settings_page.dart';
import '../features/stock/presentation/stock_capability_page.dart';
import '../features/stock/presentation/stock_page.dart';
import '../features/tool_runner/presentation/tool_runner_page.dart';
import '../features/tools/presentation/tools_page.dart';
import '../features/writing/presentation/writing_page.dart';
import '../shared/widgets/static_pages.dart';
import 'app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorToolsKey = GlobalKey<NavigatorState>(debugLabel: 'tools');
final _shellNavigatorStockKey = GlobalKey<NavigatorState>(debugLabel: 'stock');
final _shellNavigatorAgentsKey =
    GlobalKey<NavigatorState>(debugLabel: 'agents');
final _shellNavigatorWritingKey =
    GlobalKey<NavigatorState>(debugLabel: 'writing');
final _shellNavigatorProfileKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _shellNavigatorHomeKey,
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomePage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorToolsKey,
          routes: [
            GoRoute(
              path: '/tools',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ToolsPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorStockKey,
          routes: [
            GoRoute(
              path: '/stock',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: StockPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorAgentsKey,
          routes: [
            GoRoute(
              path: '/agents',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AgentsPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorWritingKey,
          routes: [
            GoRoute(
              path: '/writing',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: WritingPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _shellNavigatorProfileKey,
          routes: [
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfilePage(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) => '/home',
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/tool/:toolId',
      builder: (context, state) => ToolRunnerPage(
        toolId: state.pathParameters['toolId'] ?? '',
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/stock/:capabilityId',
      builder: (context, state) => StockCapabilityPage(
        capabilityId: state.pathParameters['capabilityId'] ?? '',
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/agents/template/:templateId',
      builder: (context, state) => AgentTemplatePage(
        templateId: state.pathParameters['templateId'] ?? '',
      ),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/models',
      builder: (context, state) => const ModelsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/membership',
      builder: (context, state) => const MembershipPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/placeholder/:type',
      builder: (context, state) => GenericPlaceholderPage(
        type: state.pathParameters['type'] ?? 'unknown',
      ),
    ),
  ],
);
