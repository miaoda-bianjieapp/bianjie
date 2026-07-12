import '../models/ai_model.dart';

const mockModels = [
  AiModel(
    id: 'glm-5v-turbo',
    name: 'GLM-5V Turbo',
    description: '当前真实接入的 GLM 多模态模型。',
    isDefault: true,
  ),
  AiModel(
    id: 'deepseek-r1',
    name: 'DeepSeek-R1 联网满血版',
    description: '适合写作、推理和复杂任务拆解。',
    isDefault: false,
  ),
  AiModel(
    id: 'stock-pro-flash',
    name: '股票 1.6 Pro Flash',
    description: '面向股票频道的快速分析模型。',
    isDefault: false,
  ),
  AiModel(
    id: 'agent-worker',
    name: 'AI-Agent 助手',
    description: '适合模板化任务和多步骤执行。',
    isDefault: false,
  ),
];
