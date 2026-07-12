import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mocks/mock_agent_templates.dart';
import '../mocks/mock_categories.dart';
import '../mocks/mock_models.dart';
import '../mocks/mock_prompts.dart';
import '../mocks/mock_stock.dart';
import '../mocks/mock_tools.dart';
import '../mocks/mock_user.dart';
import '../models/agent_template.dart';
import '../models/ai_model.dart';
import '../models/prompt_suggestion.dart';
import '../models/stock_capability.dart';
import '../models/stock_stat.dart';
import '../models/tool.dart';
import '../models/tool_category.dart';
import '../models/user_profile.dart';
import 'remote_data_providers.dart';

final toolsRepositoryProvider = Provider<ToolsRepository>((ref) {
  return const MockToolsRepository();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return MockUserRepository();
});

final toolsProvider = Provider<List<Tool>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getTools();
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteToolsProvider).valueOrNull ?? fallback;
});

final toolCategoriesProvider = Provider<List<ToolCategory>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getCategories();
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteToolCategoriesProvider).valueOrNull ?? fallback;
});

final homePromptsProvider = Provider<List<PromptSuggestion>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getPrompts('home');
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteHomePromptsProvider).valueOrNull ?? fallback;
});

final stockPromptsProvider = Provider<List<PromptSuggestion>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getPrompts('stock');
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteStockPromptsProvider).valueOrNull ?? fallback;
});

final agentTemplatesProvider = Provider<List<AgentTemplate>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getAgentTemplates();
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteAgentTemplatesProvider).valueOrNull ?? fallback;
});

final stockStatsProvider = Provider<List<StockStat>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getStockStats();
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteStockStatsProvider).valueOrNull ?? fallback;
});

final stockCapabilitiesProvider = Provider<List<StockCapability>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getStockCapabilities();
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteStockCapabilitiesProvider).valueOrNull ?? fallback;
});

final aiModelsProvider = Provider<List<AiModel>>((ref) {
  final fallback = ref.watch(toolsRepositoryProvider).getModels();
  if (!ref.watch(useRemoteApiProvider)) {
    return fallback;
  }
  return ref.watch(remoteAiModelsProvider).valueOrNull ?? fallback;
});

final selectedModelIdProvider = StateProvider<String>((ref) {
  final defaultModel = ref
      .watch(aiModelsProvider)
      .firstWhere((model) => model.isDefault, orElse: () => mockModels.first);
  return defaultModel.id;
});

final selectedModelProvider = Provider<String>((ref) {
  final models = ref.watch(aiModelsProvider);
  final selectedModelId = ref.watch(selectedModelIdProvider);
  final selectedModel = models.firstWhere(
    (model) => model.id == selectedModelId,
    orElse: () => models.isEmpty ? mockModels.first : models.first,
  );
  return selectedModel.name;
});

final selectedAiModelProvider = Provider<AiModel>((ref) {
  final models = ref.watch(aiModelsProvider);
  final selectedModelId = ref.watch(selectedModelIdProvider);
  return models.firstWhere(
    (model) => model.id == selectedModelId,
    orElse: () => models.isEmpty ? mockModels.first : models.first,
  );
});

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref.watch(userRepositoryProvider));
});

abstract class ToolsRepository {
  List<Tool> getTools();
  List<ToolCategory> getCategories();
  List<PromptSuggestion> getPrompts(String scenario);
  List<AgentTemplate> getAgentTemplates();
  List<StockStat> getStockStats();
  List<StockCapability> getStockCapabilities();
  List<AiModel> getModels();
}

class MockToolsRepository implements ToolsRepository {
  const MockToolsRepository();

  @override
  List<Tool> getTools() => mockTools;

  @override
  List<ToolCategory> getCategories() => mockToolCategories;

  @override
  List<PromptSuggestion> getPrompts(String scenario) {
    return mockPrompts
        .where((prompt) => prompt.scenario == scenario)
        .toList(growable: false);
  }

  @override
  List<AgentTemplate> getAgentTemplates() => mockAgentTemplates;

  @override
  List<StockStat> getStockStats() => mockStockStats;

  @override
  List<StockCapability> getStockCapabilities() => mockStockCapabilities;

  @override
  List<AiModel> getModels() => mockModels;
}

abstract class UserRepository {
  UserProfile getUser();
}

class MockUserRepository implements UserRepository {
  @override
  UserProfile getUser() => mockUser;
}

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(UserRepository repository) : super(repository.getUser());

  void checkIn() {
    if (state.checkedInToday) {
      return;
    }

    state = state.copyWith(
      points: state.points + 20,
      checkedInToday: true,
    );
  }
}
