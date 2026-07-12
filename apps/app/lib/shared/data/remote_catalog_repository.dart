import '../../core/network/api_client.dart';
import '../models/agent_template.dart';
import '../models/ai_model.dart';
import '../models/prompt_suggestion.dart';
import '../models/stock_capability.dart';
import '../models/stock_stat.dart';
import '../models/tool.dart';
import '../models/tool_category.dart';
import '../models/user_profile.dart';

class RemoteCatalogRepository {
  RemoteCatalogRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Tool>> getTools() {
    return _getList('/tools', Tool.fromJson);
  }

  Future<List<ToolCategory>> getCategories() {
    return _getList('/tool-categories', ToolCategory.fromJson);
  }

  Future<List<PromptSuggestion>> getPrompts(String scenario) {
    return _getList(
      '/prompts',
      PromptSuggestion.fromJson,
      queryParameters: {'scenario': scenario},
    );
  }

  Future<List<AgentTemplate>> getAgentTemplates() {
    return _getList('/agents/templates', AgentTemplate.fromJson);
  }

  Future<List<StockStat>> getStockStats() {
    return _getList('/stock/stats', StockStat.fromJson);
  }

  Future<List<StockCapability>> getStockCapabilities() {
    return _getList('/stock/capabilities', StockCapability.fromJson);
  }

  Future<List<AiModel>> getModels() {
    return _getList('/models', AiModel.fromJson);
  }

  Future<UserProfile> getUser() async {
    final json = await _getData('/me');
    return UserProfile.fromJson(json as Map<String, dynamic>);
  }

  Future<UserProfile> checkIn() async {
    final response = await _apiClient.dio.post<Object?>('/check-in');
    final json = _readResponseData(response.data);
    return UserProfile.fromJson(json as Map<String, dynamic>);
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic> json) fromJson, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final json = await _getData(path, queryParameters: queryParameters);
    final items = json as List<dynamic>;
    return items
        .map((item) => fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Object?> _getData(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.dio.get<Object?>(
      path,
      queryParameters: queryParameters,
    );
    return _readResponseData(response.data);
  }

  Object? _readResponseData(Object? responseData) {
    final envelope = responseData as Map<String, dynamic>;
    if (envelope['success'] != true) {
      throw RemoteApiException(
        envelope['code'] as String? ?? 'REMOTE_ERROR',
        envelope['message'] as String? ?? 'Remote API request failed',
      );
    }
    return envelope['data'];
  }
}

class RemoteApiException implements Exception {
  RemoteApiException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'RemoteApiException($code): $message';
}
