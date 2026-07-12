import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/api_config.dart';
import '../../core/network/api_client.dart';
import '../data/remote_catalog_repository.dart';
import '../models/agent_template.dart';
import '../models/ai_model.dart';
import '../models/prompt_suggestion.dart';
import '../models/stock_capability.dart';
import '../models/stock_stat.dart';
import '../models/tool.dart';
import '../models/tool_category.dart';
import '../models/user_profile.dart';

final useRemoteApiProvider = Provider<bool>((ref) {
  return ApiConfig.useRemoteApi;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final remoteCatalogRepositoryProvider =
    Provider<RemoteCatalogRepository>((ref) {
  return RemoteCatalogRepository(ref.watch(apiClientProvider));
});

final remoteToolsProvider = FutureProvider<List<Tool>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getTools();
});

final remoteToolCategoriesProvider = FutureProvider<List<ToolCategory>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getCategories();
});

final remoteHomePromptsProvider = FutureProvider<List<PromptSuggestion>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getPrompts('home');
});

final remoteStockPromptsProvider =
    FutureProvider<List<PromptSuggestion>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getPrompts('stock');
});

final remoteAgentTemplatesProvider = FutureProvider<List<AgentTemplate>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getAgentTemplates();
});

final remoteStockStatsProvider = FutureProvider<List<StockStat>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getStockStats();
});

final remoteStockCapabilitiesProvider =
    FutureProvider<List<StockCapability>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getStockCapabilities();
});

final remoteAiModelsProvider = FutureProvider<List<AiModel>>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getModels();
});

final remoteUserProfileProvider = FutureProvider<UserProfile>((ref) {
  return ref.watch(remoteCatalogRepositoryProvider).getUser();
});
