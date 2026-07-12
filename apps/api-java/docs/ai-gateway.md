# AI Gateway 接入说明

当前对话回复通过 `AiGateway` 统一生成，默认实现是 `MockAiGateway`。

## 当前结构

- `AiGateway`: 统一模型网关接口
- `AiGatewayRequest`: 会话、模型、上下文摘要、最近消息、附件占位信息
- `AiGatewayResponse`: 回复文本、token 估算、结束原因、元数据
- `MockAiGateway`: 默认 mock 实现

## 默认配置

```yaml
bianjie:
  ai:
    gateway:
      provider: mock
      base-url:
      api-key:
      default-model:
      timeout-seconds: 60
```

也支持多模型配置。配置了 `models` 后，前端传来的 `modelId` 会用于选择对应模型：

```yaml
bianjie:
  ai:
    gateway:
      provider: openai-compatible
      default-model-id: glm-5v-turbo
      timeout-seconds: 60
      models:
        - id: glm-5v-turbo
          name: GLM-5V Turbo
          description: 当前真实接入的 GLM 多模态模型。
          provider: glm
          base-url: https://open.bigmodel.cn/api/paas/v4
          api-key: 你的 GLM API Key
          model: glm-5v-turbo
          default-model: true
          sort-order: 1
        - id: deepseek-chat
          name: DeepSeek Chat
          description: OpenAI-compatible 示例。
          provider: openai-compatible
          base-url: https://api.deepseek.com/v1
          api-key: 你的 DeepSeek API Key
          model: deepseek-chat
          sort-order: 2
```

## 后续接真实模型

已经内置 `OpenAiCompatibleGateway` 骨架，可接兼容 `/chat/completions` 的服务。

## GLM 配置

当前项目已经内置 GLM 的默认接入地址：

```text
https://open.bigmodel.cn/api/paas/v4
```

在 IDEA 的后端运行配置里添加环境变量即可，不要把 API Key 写入仓库：

```text
GLM_API_KEY=你的 GLM API Key
GLM_MODEL=glm-5v-turbo
```

只要检测到 `GLM_API_KEY`，后端会自动使用 GLM，并复用 OpenAI-compatible 的 `/chat/completions` 请求结构。

### 本地开发推荐方式

不建议频繁修改 Windows 系统环境变量。推荐在本机创建一个不会提交到仓库的文件：

```text
src/main/resources/application-local.yml
```

内容示例：

```yaml
bianjie:
  ai:
    gateway:
      provider: openai-compatible
      default-model-id: glm-5v-turbo
      timeout-seconds: 60
      models:
        - id: glm-5v-turbo
          name: GLM-5V Turbo
          provider: glm
          base-url: https://open.bigmodel.cn/api/paas/v4
          api-key: 你的 GLM API Key
          model: glm-5v-turbo
          default-model: true
          sort-order: 1
```

然后在 IDEA 的后端运行配置里，把 Active profiles 填成：

```text
local
```

`application-local.yml` 已加入 `.gitignore`，可以放你的本地 key；仓库里只保留 `application-local.example.yml` 模板。

## 查看当前接入状态

启动后可以打开 Swagger 或直接访问：

```text
GET /api/v1/ai-gateway/status
```

返回内容会包含：

- `provider`: 当前提供方，例如 `mock` 或 `openai-compatible`
- `ready`: 当前配置是否足够发起调用
- `baseUrlConfigured`: 是否配置了 base url
- `apiKeyConfigured`: 是否配置了 api key
- `baseUrl`: 当前 base url，方便本地排查
- `defaultModelId`: 当前默认模型 id
- `defaultModel`: 默认模型
- `timeoutSeconds`: HTTP 连接和读取超时时间
- `models`: 每个模型的 provider、baseUrl 是否配置、apiKey 是否配置、ready 状态

接口不会返回 API Key 明文。

### OpenAI-compatible 配置

推荐用环境变量，不要把 key 写进仓库：

```powershell
$env:BIANJIE_AI_GATEWAY_PROVIDER="openai-compatible"
$env:BIANJIE_AI_GATEWAY_BASE_URL="https://example.com/v1"
$env:BIANJIE_AI_GATEWAY_API_KEY="你的 API Key"
$env:BIANJIE_AI_GATEWAY_DEFAULT_MODEL="deepseek-chat"
```

### DeepSeek 示例

```powershell
$env:BIANJIE_AI_GATEWAY_PROVIDER="openai-compatible"
$env:BIANJIE_AI_GATEWAY_BASE_URL="https://api.deepseek.com/v1"
$env:BIANJIE_AI_GATEWAY_API_KEY="你的 DeepSeek API Key"
$env:BIANJIE_AI_GATEWAY_DEFAULT_MODEL="deepseek-chat"
$env:BIANJIE_AI_GATEWAY_TIMEOUT_SECONDS="60"
```

或在本地开发 yml 中配置：

```yaml
bianjie:
  ai:
    gateway:
      provider: openai-compatible
      base-url: https://example.com/v1
      api-key: ${BIANJIE_AI_GATEWAY_API_KEY}
      default-model: deepseek-chat
```

真实请求路径会拼成：

```text
{base-url}/chat/completions
```

如果网关未配置或调用失败，后端会返回一条 assistant 错误消息并入库，App 不会崩溃。

### 新增其他供应商

新增一个实现类，例如 `CustomAiGateway`，实现：

```java
AiGatewayResponse complete(AiGatewayRequest request)
```

建议真实接入时保留当前上下文策略：

- 完整消息永久入库
- 模型调用时使用 `summary + 最近 N 条消息`
- 附件先通过 `attachments` 传结构，真实文件内容由文件解析服务补充

不要在 `ChatService` 里直接写模型 HTTP 调用，保持它只负责编排会话和消息入库。
