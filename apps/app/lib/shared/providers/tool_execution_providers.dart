import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/tool_execution_repository.dart';
import 'remote_data_providers.dart';

final toolExecutionRepositoryProvider =
    Provider<ToolExecutionRepository>((ref) {
  if (ref.watch(useRemoteApiProvider)) {
    return RemoteToolExecutionRepository(ref.watch(apiClientProvider));
  }
  return const MockToolExecutionRepository();
});

final toolRunsHistoryProvider = FutureProvider.autoDispose((ref) {
  return ref.watch(toolExecutionRepositoryProvider).listToolRuns();
});
