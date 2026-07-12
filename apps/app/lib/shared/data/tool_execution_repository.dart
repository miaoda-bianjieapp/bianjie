import '../../core/network/api_client.dart';
import '../models/chat_attachment.dart';
import '../models/task.dart';
import '../models/tool_run.dart';

abstract class ToolExecutionRepository {
  Future<ToolRun> createToolRun(
    String toolId, {
    required String input,
    Map<String, dynamic> parameters = const {},
    List<ChatAttachment> attachments = const [],
  });

  Future<List<ToolRun>> listToolRuns();

  Future<ToolRun> getToolRun(String runId);

  Future<Task> createTask({
    required String type,
    required String title,
    Map<String, dynamic> payload = const {},
  });

  Future<Task> getTask(String taskId);
}

class MockToolExecutionRepository implements ToolExecutionRepository {
  const MockToolExecutionRepository();

  @override
  Future<ToolRun> createToolRun(
    String toolId, {
    required String input,
    Map<String, dynamic> parameters = const {},
    List<ChatAttachment> attachments = const [],
  }) async {
    final now = DateTime.now();
    return ToolRun(
      id: 'local-run-${now.microsecondsSinceEpoch}',
      toolId: toolId,
      status: 'COMPLETED',
      input: input,
      parameters: parameters,
      output: _mockOutput(toolId, input, parameters),
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<ToolRun>> listToolRuns() async {
    return const [];
  }

  Map<String, dynamic> _mockOutput(
    String toolId,
    String input,
    Map<String, dynamic> parameters,
  ) {
    if (toolId == 'video-script') {
      return {
        'result': '''
标题选项：
1. $input，普通人也能 60 秒看懂
2. 别再踩坑了，$input这样做更有效
3. 一个视频讲清楚：$input

开头 3 秒钩子：
如果你正在做“$input”，先别急着开始，下面这 3 个步骤能帮你少走很多弯路。

分镜脚本：
镜头 1：问题抛出，快速展示痛点。
镜头 2：给出核心方法，用字幕列出 3 个步骤。
镜头 3：展示结果或对比，强化可信度。
镜头 4：总结行动建议，引导收藏/评论。

发布文案：
把复杂问题拆成可执行步骤，今天先从第一步开始。#效率 #AI工具 #实用技巧
''',
        'model': parameters['modelName'] ?? '本地 Demo',
      };
    }
    if (toolId == 'polish-copy') {
      return {
        'result': '''
润色后文案：
$input

优化版本：
我们把关键步骤整理得更清晰，让你可以更快理解重点、判断价值，并直接开始行动。

可选标题：
1. 把复杂问题讲清楚
2. 更高效的解决方式
3. 现在就能用的实操方案

修改说明：
- 强化了句子的行动感
- 减少空泛表达
- 保留原意，并提升阅读节奏
''',
        'model': parameters['modelName'] ?? '本地 Demo',
      };
    }
    return {
      'summary': '本地 Demo 已通过统一工具执行入口生成结果。',
      'parameters': parameters,
    };
  }

  @override
  Future<ToolRun> getToolRun(String runId) {
    throw UnsupportedError('Mock tool run lookup is not persisted.');
  }

  @override
  Future<Task> createTask({
    required String type,
    required String title,
    Map<String, dynamic> payload = const {},
  }) async {
    final now = DateTime.now();
    return Task(
      id: 'local-task-${now.microsecondsSinceEpoch}',
      type: type,
      title: title,
      status: 'QUEUED',
      payload: payload,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<Task> getTask(String taskId) {
    throw UnsupportedError('Mock task lookup is not persisted.');
  }
}

class RemoteToolExecutionRepository implements ToolExecutionRepository {
  RemoteToolExecutionRepository(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<ToolRun> createToolRun(
    String toolId, {
    required String input,
    Map<String, dynamic> parameters = const {},
    List<ChatAttachment> attachments = const [],
  }) async {
    final response = await _apiClient.dio.post<Object?>(
      '/tools/$toolId/runs',
      data: {
        'input': input,
        'parameters': parameters,
        'attachments': attachments.map((item) => item.toJson()).toList(),
      },
    );
    return ToolRun.fromJson(_readMap(response.data));
  }

  @override
  Future<List<ToolRun>> listToolRuns() async {
    final response = await _apiClient.dio.get<Object?>('/tool-runs');
    final items = _readData(response.data) as List<dynamic>;
    return items
        .map((item) => ToolRun.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<ToolRun> getToolRun(String runId) async {
    final response = await _apiClient.dio.get<Object?>('/tool-runs/$runId');
    return ToolRun.fromJson(_readMap(response.data));
  }

  @override
  Future<Task> createTask({
    required String type,
    required String title,
    Map<String, dynamic> payload = const {},
  }) async {
    final response = await _apiClient.dio.post<Object?>(
      '/tasks',
      data: {
        'type': type,
        'title': title,
        'payload': payload,
      },
    );
    return Task.fromJson(_readMap(response.data));
  }

  @override
  Future<Task> getTask(String taskId) async {
    final response = await _apiClient.dio.get<Object?>('/tasks/$taskId');
    return Task.fromJson(_readMap(response.data));
  }

  Map<String, dynamic> _readMap(Object? responseData) {
    return _readData(responseData) as Map<String, dynamic>;
  }

  Object? _readData(Object? responseData) {
    final envelope = responseData as Map<String, dynamic>;
    if (envelope['success'] != true) {
      throw ToolExecutionException(
        envelope['code'] as String? ?? 'REMOTE_ERROR',
        envelope['message'] as String? ?? 'Remote API request failed',
      );
    }
    return envelope['data'];
  }
}

class ToolExecutionException implements Exception {
  ToolExecutionException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'ToolExecutionException($code): $message';
}
