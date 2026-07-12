# 边界 AI 工具协作开发规范 / Bianjie AI Tool Collaboration Guidelines

> 适用对象：参与本项目工具开发的开发者、AI 编码助手和自动化代理。
>
> Audience: developers, AI coding assistants, and automation agents contributing tools to this project.

本文件是整个工作区的 AI 工具协作规范，专门约束“功能工具”和“写作工具”的开发。若子目录存在更具体的 `AGENTS.md`，则其规则适用于对应子目录；任何情况下都应以仓库实际代码和最新明确需求为准。

This file is the workspace-wide AI collaboration guide for feature tools and writing tools. A more specific `AGENTS.md` in a subdirectory governs that subtree. In all cases, follow the actual repository code and the latest explicit requirement.

多人协作时，开发者和 AI 在开始编码前还必须读取并更新根目录 `TOOL_DEVELOPMENT_BOARD.md`。未登记 `toolId`、负责人、个人分支、executor/operation 和公共文件占用的任务不得开始开发。

During multi-developer collaboration, developers and AI agents MUST also read and update the root `TOOL_DEVELOPMENT_BOARD.md` before coding. Work must not start until the tool ID, owner, personal branch, executor/operation, and shared-file ownership are registered.

规范中的关键词含义如下：

- **必须 / MUST**：不可省略，未满足时不得提交。
- **禁止 / MUST NOT**：任何 AI 或开发者不得执行。
- **应该 / SHOULD**：默认执行，只有明确、可说明的理由才能偏离。
- **可以 / MAY**：根据任务实际情况选择。

Normative keywords:

- **MUST**: mandatory; the change must not be submitted if unmet.
- **MUST NOT**: prohibited for both humans and AI agents.
- **SHOULD**: expected by default; deviations require a concrete reason.
- **MAY**: optional based on the task.

---

## 1. 工具开发架构规范（最高优先级） / Tool Architecture Rules (Highest Priority)

### 1.1 基本原则 / Core Principle

新增工具时，必须优先采用“统一工具协议 + 能力族执行器 + 数据库配置”的方式。禁止默认按“一个工具一套 Controller、Service、Entity、页面”的方式复制代码。

New tools MUST use the "unified tool protocol + capability-family executor + database configuration" model first. Do not default to copying a dedicated Controller, Service, Entity, and page for every tool.

统一调用链如下：

```text
PostgreSQL tools configuration
        -> Flutter dynamic tool page
        -> input / parameters / attachments
        -> ToolProtocolValidator
        -> ToolExecutorRegistry
        -> capability-family ToolExecutor
        -> ToolExecutionResult / artifacts
        -> tool_runs history
```

工具必须复用以下公共能力：

- 工具目录、分类、排序和启停状态。
- 动态表单渲染和前后端字段协议。
- 输入参数与附件校验。
- 执行器注册与解析。
- 运行状态、结果、附件和历史记录。
- 统一 API 响应结构和错误处理。

Every tool MUST reuse the common catalog, dynamic form contract, request validation, executor registry, run status, artifacts, history, response envelope, and error handling.

### 1.2 开发前先判断能力类型 / Classify the Capability Before Coding

开始编码前，AI 必须明确回答：该工具属于现有能力族，还是需要新的能力族。未完成分类前不得创建新执行器。

Before coding, the AI MUST state whether the tool belongs to an existing capability family or requires a new one. Do not create an executor before this classification.

当前能力族及对应执行器：

| 配置 `executor` | 后端执行器 | 适用范围 |
|---|---|---|
| `llm-template` | `PromptTemplateToolExecutor` | 写作、文案、总结、脚本、报告等纯文本生成 |
| `image-generation` | `QwenImageToolExecutor` | 生图、参考图改写、海报、封面、卡片 |
| `document-processing` | `DocumentProcessingToolExecutor` | PDF、电子书、文档转换、合并、分割、压缩 |
| `ppt-generation` | `PptGenerationToolExecutor` | 文档转 PPT、主题生成 PPT、Markdown 转 PPT |
| `external` / `external-api` | 外部能力执行器 | 已有第三方服务或外部页面 |
| `workflow` | 后续工作流执行器 | 多步骤、长耗时、多个模型或引擎协作 |
| 占位 | `PlaceholderExecutor` | 仅展示、尚未实现的工具 |

Current capability families and executors are listed above. Reuse them whenever their underlying capability matches the new tool.

判断规则：

1. 只改变提示词、表单字段、输入限制、输出格式或 operation 时，必须复用现有执行器。
2. 只有底层处理机制发生变化，例如首次接入 PDF 引擎、OCR 引擎、PPTX 渲染引擎时，才允许新增或扩展执行器。
3. 同一能力族的多个工具应通过 `operation` 区分，不得通过大量 `if (toolId.equals(...))` 堆叠业务。
4. 只有页面交互确实无法由动态表单表达时，才允许增加专用 Flutter 页面，并在提交说明中解释原因。

Classification rules:

1. If only prompts, fields, limits, output formats, or operation change, reuse an existing executor.
2. Add or extend an executor only when the underlying processing mechanism is genuinely new.
3. Tools in one family SHOULD be distinguished by `operation`, not by a growing chain of tool-ID conditionals.
4. Add a dedicated Flutter page only when the dynamic form cannot represent the required interaction, and explain why in the submission.

### 1.3 新增工具的标准步骤 / Standard Workflow for Adding a Tool

每个新工具必须按以下顺序开发：

1. 确定稳定且唯一的 `toolId`，使用小写英文、数字和连字符，例如 `xiaohongshu-cover`。一经合并不得随意修改。
2. 确定所属 Tab 和分类，当前允许开发的 Tab 见第 6 节。
3. 确定已有 `executor` 和具体 `operation`；如无法复用，先写清新能力族设计。
4. 在 PostgreSQL `tools` 中新增或更新工具定义。开发环境优先使用工具管理 API，不以修改 `CatalogSeedRunner` 作为日常配置方式。
5. 配置动态输入：`primaryInput`、`fields`、`inputModes`、附件限制和输出格式。
6. 同步 Flutter mock/fixture，确保断网测试和真实 API 的字段一致。
7. 如协议字段变化，同步后端 DTO、Flutter model/repository、测试和文档。
8. 实现或扩展执行器，返回统一 `ToolExecutionResult`。
9. 确认输出文本和生成附件都能进入 `tool_runs` 历史记录并可再次打开。
10. 完成自动测试和人工功能测试后再提交。

Every new tool MUST follow these steps in order: choose a stable ID, assign a permitted tab/category, select an executor and operation, persist the definition in PostgreSQL, configure dynamic inputs, synchronize Flutter mocks, update shared contracts, implement the capability, verify history/artifacts, and test before submission.

### 1.4 工具配置约束 / Tool Configuration Constraints

可运行工具必须至少提供协议版本、执行器、输入模式、输出格式和字段定义；需要区分底层动作的能力族还必须提供 `operation`：

```json
{
  "version": "tool-protocol-v2",
  "executor": "llm-template",
  "inputModes": ["text"],
  "outputFormats": ["markdown"],
  "fields": []
}
```

例如 `image-generation`、`document-processing` 和 `ppt-generation` 必须配置 `operation`；当前 `llm-template` 通过提示词配置区分工具，可以不配置 `operation`。

约束如下：

- `version` 必须使用当前协议版本，不得写无意义的 `demo`。
- `executor` 必须能被 `ToolExecutorRegistry` 解析。
- 需要 operation 的能力族必须填写稳定的英文 `operation`。
- `fields[].name` 必须使用英文且在单个工具内唯一。
- 支持的字段类型仅限：`text`、`textarea`、`number`、`select`、`chips`、`segmented`、`slider`、`boolean`。
- `select`、`chips`、`segmented` 必须提供非空 `options`。
- 必填、默认值、最小值、最大值、长度和附件限制必须同时由后端验证，不能只依赖前端。
- 工具配置的数据库管理方式和 API 示例见 `apps/api-java/docs/tool-catalog-admin.md`。
- `CatalogSeedRunner` 只负责空数据库首次引导，禁止用它覆盖已有数据库工具配置。

Runnable tools MUST use the current protocol version, a resolvable executor, stable English operation and field names, supported field types, valid options, and server-side validation. `CatalogSeedRunner` is only for empty-database bootstrap and MUST NOT overwrite database-owned tool definitions.

### 1.5 新执行器的代码约束 / Rules for New Executors

只有确认现有能力族无法支持时，才可以新增执行器。新执行器必须：

1. 实现 `ToolExecutor` 并使用 Spring `@Component` 注册。
2. `supports(ToolDto tool)` 优先根据 `config.executor` 判断，不得只依赖固定 `toolId`。
3. 只处理一个清晰的能力族，不得做成包含无关功能的万能类。
4. 使用 `ToolExecutionContext` 获取输入、参数和附件，不得从 Controller 绕过统一协议。
5. 返回 `ToolExecutionResult`，状态只能使用项目认可的 `QUEUED`、`RUNNING`、`COMPLETED`、`FAILED`、`CANCELLED`。
6. 文件或媒体输出必须转换为统一 artifact，不得只返回开发机绝对路径。
7. 外部模型、第三方 API 和文件引擎必须配置超时、错误映射和必要的重试边界。
8. 禁止在执行器常量中写 API Key、账号、开发机路径或环境专属 URL。
9. 禁止在长时间外部调用期间持有数据库事务。
10. `@Order` 只在多个执行器可能同时匹配时使用，并必须有测试证明不会被 fallback 抢占。
11. 至少添加：`supports` 路由测试、成功结果测试、非法输入测试和外部失败测试。

A new executor MUST implement `ToolExecutor`, resolve by configured executor, own one capability family, consume `ToolExecutionContext`, return approved statuses and normalized artifacts, define timeout/error behavior, contain no secrets or machine paths, avoid long transactions, and include focused routing/success/validation/failure tests.

### 1.6 文本、图片、文件和异步任务 / Text, Image, File, and Async Rules

- 文本类工具应优先使用 `llm-template`，不同工具通过系统提示词、任务提示词、输出要求和 fields 区分。
- 图片类工具必须同时验证 MIME、扩展名、数量、大小和模型是否支持参考图。
- 禁止在日志、测试、提交或文档中输出完整 Base64、用户文件内容和模型密钥。
- Base64 JSON 只可作为当前开发阶段的小文件兼容方案；大文件和正式文档工具应使用 multipart/对象存储并在 PostgreSQL 保存元数据。
- 预计超过普通 HTTP 请求时间的 PDF、PPT、OCR、视频类任务必须设计为异步任务，不得让移动端无限等待。
- 异步任务必须可查询状态，失败必须保留可理解的错误，成功必须提供可重新下载或打开的 artifact。
- 占位工具不得伪装成已实现。占位输出和 UI 必须明确表示尚未接入真实能力。

Text tools SHOULD use `llm-template`. Media and file tools MUST validate MIME, extension, count, size, and provider capability. Never log full Base64, user files, or secrets. Long-running tools MUST be asynchronous and expose queryable status and durable artifacts. Placeholders must never pretend to be complete.

### 1.7 对标产品截图驱动开发 / Reference-Product Screenshot Guidance

开发者通常会把对标产品的工具详情页以一张或多张截图提供给 AI，作为功能设计、参数设计、交互流程和页面布局的开发导向。AI 必须认真查看所有截图，但不得把截图当成可以不加分析地逐像素复制的最终规格。

Developers will commonly provide one or more screenshots of a reference product's tool detail page as guidance for feature design, parameters, interaction flow, and layout. The AI MUST inspect every screenshot carefully, but MUST NOT treat screenshots as an unquestionable pixel-for-pixel specification.

收到截图后，AI 在编码前必须完成以下拆解：

1. 确认截图对应的工具名称、所属 Tab、分类和目标用户任务。
2. 列出可见输入项：主输入、文本框、下拉选项、标签、分段控件、滑块、开关、附件和文件限制。
3. 识别必填标记、默认值、选项内容、数值范围、单位、按钮文案和提交条件。
4. 识别附件来源、允许格式、数量、大小、预览、删除和重新选择行为。
5. 识别执行过程中的加载、进度、取消、失败、重试和额度提示。
6. 识别结果形态：文本、图片、PDF、PPTX、其他文件、复制、预览、保存和历史回看。
7. 区分三类信息：**截图明确展示的事实**、**基于现有项目的合理推断**、**截图无法确定且需要确认的内容**。
8. 将截图字段映射为现有工具协议中的 `primaryInput`、`fields`、`inputModes`、附件限制、`outputFormats`、`executor` 和 `operation`。

Before coding from screenshots, the AI MUST identify the tool/tab/category and user goal; enumerate visible inputs, controls, defaults, ranges, units, attachments, actions, states, and outputs; distinguish observed facts from reasonable inferences and unresolved questions; and map the result to the existing tool protocol.

截图实现规则：

- 截图是产品导向，不自动等于完整需求。截图没有展示的错误态、加载态、空状态、历史记录和附件承接仍必须按本项目规范补齐。
- 优先复用动态工具页面和现有组件。仅因视觉差异不得创建一套专用前后端架构。
- UI 应吸收对标产品的信息层级和交互优点，同时统一到边界 AI 的主题、颜色、间距、图标和文案风格。
- 禁止直接复制对标产品的品牌名称、Logo、商标、受版权保护的图片、专属营销文案和明显品牌化资产。
- 除非负责人明确要求高度还原，否则不得为了像素级模仿破坏手机适配、中文长文本、无障碍和已有设计系统。
- 多张截图应结合起来理解完整流程。截图之间冲突时，以开发者最新说明为准；无法安全判断时必须提出明确问题或在交付中记录假设。
- 截图只能证明界面表现，不能证明后台能力已经存在。AI 必须检查当前执行器、模型和文件引擎，不得把静态页面、mock 或 `QUEUED` 占位描述成真实功能。
- 如果截图展示的功能属于新的能力族，必须先按第 1.2 和 1.5 节评估执行器，不得只完成 UI 后宣称工具完成。
- 截图中出现账号、手机号、订单、文件内容、Key 或其他隐私数据时，不得写入代码、测试、文档、日志或提交说明。
- 交付说明必须记录参考了哪些截图、实现了哪些核心交互，以及因项目架构、移动端适配或版权原因做了哪些调整。

Screenshot implementation rules:

- Screenshots are product guidance, not a complete requirement. Missing loading, error, empty, history, and artifact states still MUST be implemented according to project rules.
- Reuse the dynamic tool page and existing components. Visual differences alone do not justify a separate frontend/backend architecture.
- Adopt useful hierarchy and interactions while conforming to Bianjie AI themes, colors, spacing, icons, and copy style.
- Do not copy reference-product names, logos, trademarks, copyrighted media, proprietary marketing copy, or distinctive branded assets.
- Unless high-fidelity reproduction is explicitly required, do not sacrifice responsiveness, long Chinese text, accessibility, or the design system for pixel-level imitation.
- Combine multiple screenshots into one workflow. If screenshots conflict, follow the developer's latest explanation; ask a focused question or document assumptions when necessary.
- A screenshot proves only visible UI, not backend capability. Inspect executors, models, and file engines, and never present static UI, mocks, or queued placeholders as real functionality.
- A new capability family requires executor analysis under Sections 1.2 and 1.5; UI-only delivery is not a completed tool.
- Never persist private data visible in screenshots into code, tests, docs, logs, or handoffs.
- The handoff MUST identify referenced screenshots, implemented interactions, and intentional deviations for architecture, mobile usability, or copyright reasons.

---

## 2. 单次 AI 开发范围 / Scope Per AI Task

一次 AI 编码任务最多开发 **3 个工具**，包括新增、由占位改成真实功能、或大幅重构的工具。

One AI coding task may implement at most **three tools**, including new tools, placeholder-to-real conversions, or major rewrites.

- 第 4 个工具必须拆分到新的任务、会话或 PR。
- 修复这 3 个工具共同依赖的公共执行器、协议或组件不计为额外工具，但必须保持范围最小。
- AI 在开始前必须列出本次工具清单和共享改动；如果需求超过 3 个，必须主动拆分，不得悄悄扩大范围。
- 一次提交不得混入无关页面美化、股票、智能体、登录或会员功能。

The fourth tool MUST be split into a separate task or PR. Shared infrastructure needed by the selected tools does not count as another tool, but must remain narrowly scoped. The AI MUST state the tool list before coding and split requests that exceed the limit.

---

## 3. 模型与本地配置 / Models and Local Configuration

每位开发者必须自行准备本地模型配置，建议至少包含：

1. 一个支持图片输入的多模态模型，优先使用项目已验证的 GLM 系列。
2. 一个真实生图模型，优先使用项目已验证的 Qwen Image 系列或团队确认的替代模型。

Each developer MUST configure locally at least one multimodal model with image input support, preferably the validated GLM family, and one real image-generation model, preferably the validated Qwen Image family or a team-approved alternative.

模型规则：

- API Key、账号、签名、私有 URL 只能放在本地忽略文件或环境变量中，禁止提交到 Git。
- `application-local.yml` 可以保存开发者本机明文配置，但必须保持 Git 忽略，禁止复制到示例文件。
- 新配置项必须同步写入 example 配置，使用安全占位符。
- 业务代码必须读取 typed configuration，不得硬编码供应商 URL、Key、模型 ID 和超时。
- 自动测试必须使用 mock/fake，不得依赖真实 Key、真实余额、公共网络或本机 PostgreSQL。
- 真实模型联调属于人工验收，提交说明中只记录成功/失败、模型名和测试场景，不记录密钥或完整原始响应。
- AI 不得自行更换团队默认模型、升级模型版本或修改计费参数，除非需求明确授权。

Secrets MUST remain in ignored local config or environment variables. Example files use placeholders. Production code reads typed configuration. Automated tests use mocks and never depend on real keys, credits, network access, or a developer database. Do not change default models or billing-related parameters without explicit approval.

---

## 4. Git 分支与协作 / Git Branching and Collaboration

### 4.1 分支要求 / Branch Requirements

所有开发者和 AI 开始工作前必须创建个人分支，禁止直接在 `main` 开发或提交。

Every developer and AI agent MUST work on a personal branch. Direct development or commits on `main` are prohibited.

推荐流程：

```powershell
git switch main
git pull --ff-only
git switch -c dev/<name>/<short-topic>
```

推荐分支命名：

- `dev/zhangsan/pdf-tools`
- `dev/lisi/image-cover`
- `fix/zhangsan/tool-history`

规则：

- 开始前执行 `git status`，确认并保护已有未提交改动。
- 禁止使用 `git reset --hard`、强制覆盖或回滚他人改动。
- 提交只能进入个人分支；合并到 `main` 必须通过 PR/MR 和至少一次人工审查。
- 同一个 `toolId`、执行器或 Flyway 版本同时只能由一人负责。开始前应在团队中登记，避免冲突。
- 共享分支不得随意 force-push。需要变基时先与协作者确认。
- 不得提交 `.dart_tool/`、`build/`、`.flutter-plugins*`、`target/`、`data/`、IDE 文件、APK、本地配置和密钥。

Check `git status` before work, preserve existing changes, never hard-reset other work, submit only to personal branches, merge through reviewed PRs, coordinate ownership of tool IDs/executors/Flyway versions, avoid force-pushing shared branches, and exclude generated files and secrets.

### 4.2 提交粒度和信息 / Commit Scope and Messages

- 一个提交应表达一个完整目的，例如“增加 PDF 合并 operation”，不要把三个不相关工具塞进同一提交。
- 标识符和提交信息使用英文，产品文案可以使用中文。
- 推荐格式：`feat(tools): add pdf merge operation`、`fix(history): persist generated artifacts`。
- 数据库迁移、接口契约和对应客户端修改必须在同一 PR 中完整交付，不能只提交一半。
- AI 未经明确要求不得自行执行 `git commit`、`git push`、合并或创建 PR。

Each commit SHOULD represent one coherent purpose and use an English conventional-style message. Database, API, and client contract changes must be delivered together. AI agents MUST NOT commit, push, merge, or open a PR unless explicitly requested.

---

## 5. 数据库和 Flyway / Database and Flyway

任何新表、字段、索引、约束、枚举存储变化或工具配置数据迁移，都必须提供增量 Flyway SQL。

Every new table, column, index, constraint, persisted enum change, or tool configuration data migration MUST include an additive Flyway SQL migration.

迁移目录固定为：

```text
apps/api-java/src/main/resources/db/migration/postgresql/
```

数据库规则：

1. 新迁移必须使用下一个未占用版本，例如 `V3__add_artifact_storage.sql`。
2. 已经执行或可能执行过的 `V1`、`V2` 等迁移禁止修改、重命名或删除。
3. JPA Entity、Repository、DTO、Flyway SQL、H2 测试兼容性必须同步更新。
4. 迁移应尽量向后兼容。删除表/列、大范围改写数据等破坏性操作必须单独获得负责人批准并说明备份/回滚方案。
5. 新增索引必须说明对应查询；禁止无理由为每个字段加索引。
6. 工具配置以 PostgreSQL `tools` 表为准；日常新增工具使用管理 API 或明确的数据迁移，不通过启动代码覆盖。
7. 提交说明必须列出所有新增/修改的表、字段、索引、约束和迁移文件。
8. 禁止提交开发者本机数据库文件、数据库备份或真实业务数据。

Use the next unused migration version and never edit applied migrations. Keep JPA, DTOs, repositories, SQL, and H2 compatibility synchronized. Destructive migrations require explicit approval plus backup/rollback planning. Tool definitions are database-owned and must not be overwritten at startup.

---

## 6. 当前禁止开发的范围 / Temporarily Out-of-Scope Areas

未经项目负责人明确授权，以下范围禁止开发、重构或顺手补全：

The following areas MUST NOT be developed, refactored, or completed without explicit owner approval:

- 股票 Tab 及其真实行情、分析、交易或策略能力。
- 智能体 Tab 及智能体编排、市场和自动执行能力。
- 用户注册、登录、鉴权、账号体系。
- 积分、额度、支付、充值和扣费。
- VIP、会员权益、订阅和权限判断。

- Stock tab and real market/analysis/trading/strategy capabilities.
- Agent tab and agent orchestration/marketplace/autonomous execution.
- Registration, login, authentication, and account systems.
- Points, quotas, payments, top-ups, and charging.
- VIP, membership, subscription, and entitlement logic.

可以保留现有占位 UI、字段和兼容结构，但不得把占位逻辑描述为真实能力，也不得为了工具开发扩大到这些模块。

Existing placeholders and compatibility fields MAY remain, but must not be presented as real functionality or expanded as part of ordinary tool work.

---

## 7. 前后端契约与 UI / Client-Server Contract and UI

- 工具接口必须继续使用 `/api/v1` 和统一 `ApiResponse<T>` envelope。
- 修改 JSON 字段、枚举、状态、时间或空值语义时，必须同步 Flutter model、repository、provider、mock 和测试。
- 优先做向后兼容的字段新增；删除或重命名字段必须提供迁移说明。
- Flutter 工具详情优先使用统一动态页面，不为普通配置差异复制页面。
- UI 必须复用现有主题、间距、按钮、附件卡片、错误态和加载态。
- 所有工具输出必须提供复制能力；附件输出必须能预览/打开并按现有能力保存。
- 主页对话和工具调用都必须进入历史记录；新增工具不得绕开 `tool_runs`。
- 中文长文本、窄屏手机、加载、空数据、失败和重试状态都必须可用。
- 真实 API 出错时禁止静默回退到 mock 数据。

Keep `/api/v1` and `ApiResponse<T>`, synchronize every contract consumer, prefer backward-compatible additions, reuse the dynamic tool page and design system, preserve copy/history/artifact behavior, support narrow screens and explicit states, and never silently fall back to mocks after a real API error.

---

## 8. 测试和人工验收 / Testing and Manual Acceptance

### 8.1 自动测试 / Automated Tests

影响后端时，从 `apps/api-java` 运行：

```powershell
mvn test
mvn package
```

影响 Flutter 时，从 `apps/app` 运行：

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

When backend code changes, run `mvn test` and `mvn package`. When Flutter code changes, run dependency resolution, formatting verification, analysis, and tests from the Flutter build root.

测试最低要求：

- 新工具配置：配置解析和动态字段测试。
- 新执行器：路由、成功、验证失败、供应商失败测试。
- 新接口：Controller/Service 集成测试和 envelope 断言。
- 新数据库结构：Flyway/JPA 集成测试；自动测试不得连接个人数据库。
- Bug 修复：必须增加可以稳定复现问题的回归测试。
- UI 行为变化：增加有意义的 widget test，不测试无价值的内部实现细节。

At minimum, test tool config parsing, executor routing and outcomes, endpoint contracts, migrations/JPA, regressions, and meaningful UI behavior. Automated tests must remain isolated from personal databases and real providers.

### 8.2 开发者必须自己验收 / Developer-Owned Manual Testing

提交前，开发者必须自行启动后端并通过 Android Studio 数据线运行 App，完成真实操作链路。不得只以“代码可编译”或“AI 说完成了”作为验收。

Before submission, the developer MUST start the backend and run the app on a phone through Android Studio/USB, then execute the real workflow. Compilation or an AI completion claim is not acceptance.

人工验收至少包括：

1. 工具在正确 Tab 和分类中显示，名称、图标、排序正确。
2. 必填、选项、范围、文件类型、大小和数量校验正确。
3. 成功结果符合业务需求，不只是返回占位文本。
4. 失败时有可理解提示，不泄露 Key、堆栈或供应商敏感响应。
5. 结果可以复制，附件可以打开/保存。
6. 退出后能从历史记录重新查看输入、输出和附件。
7. 至少测试一次边界输入或失败场景。
8. 原有主页对话和已实现工具没有明显回归。

Manual acceptance must verify placement, validation, real results, safe errors, copy/artifacts, history replay, at least one edge/failure case, and regression safety for existing chat and tools.

普通 Dart/Java 工具逻辑修改不需要手动构建 APK。新增 Flutter 原生插件、Android 权限、Manifest、Gradle 或资源时，必须停止旧 App 后从 Android Studio 重新 Run；是否额外执行 APK 构建遵循本规范和当前任务要求。

Ordinary Dart/Java tool changes do not require a manual APK artifact. Native Flutter plugins, Android permissions, Manifest, Gradle, or assets require a full Android Studio Run after stopping the old app; additional APK verification follows this guide and the current task.

---

## 9. 提交和交付说明 / Submission and Handoff

每次提交或 PR 必须清楚说明：

Every commit handoff or PR MUST state:

- 本次开发了哪些工具，分别位于哪个 Tab 和分类。
- 每个工具是占位、部分可用还是真实可用。
- 复用了哪个 executor，新增了哪些 operation；如新增执行器，说明原因。
- 前端、后端、数据库和 API 分别修改了什么。
- 是否新增表、字段、索引或 Flyway 文件。
- 使用了哪些模型或外部引擎，但不得包含密钥。
- 执行了哪些自动测试，结果是什么。
- 在手机上人工测试了哪些成功和失败场景。
- 尚存限制、已知问题和下一步工作。
- 涉及 UI 时提供必要截图；截图不得包含密钥、用户隐私或真实业务数据。

Do not use vague statements such as “feature completed” without listing the exact tools, capability status, executor/operation, affected layers, migrations, models, automated tests, device scenarios, limitations, and safe screenshots when relevant.

推荐交付模板 / Recommended handoff template:

```markdown
## Scope
- Tab/category:
- Tools:
- Executor/operations:

## Changes
- Flutter:
- Backend:
- Database/API:

## Verification
- Automated tests:
- Device scenarios:

## Database
- Migration:
- Tables/columns/indexes:

## Limitations
- Remaining work:
```

---

## 10. 工具链和版本基线 / Toolchain and Version Baseline

所有协作者必须使用兼容版本。未经单独任务和团队确认，不得顺手升级 SDK、JDK、Gradle、Kotlin、Spring Boot 或主要依赖。

All contributors MUST use compatible versions. Do not opportunistically upgrade SDKs, JDK, Gradle, Kotlin, Spring Boot, or major dependencies without a dedicated task and team approval.

当前基线 / Current baseline:

| 组件 / Component | 版本 / Version |
|---|---|
| Flutter SDK | `3.24.5` stable（项目最低 `>=3.24.0`） |
| Dart SDK | Flutter 随附 `3.5.x`（lock 要求 `>=3.5.0 <4.0.0`） |
| Android compileSdk | `35` |
| Android Gradle Plugin | `8.1.0` |
| Gradle Wrapper | `8.3` |
| Kotlin Android Plugin | `1.8.22` |
| Backend JDK | Java `17`（本机验证 Temurin `17.0.15`） |
| Spring Boot | `3.3.6` |
| Maven | `3.9.4` |
| PostgreSQL | `16.x`（本机验证 `16.8`） |

注意：Android 模块当前字节码兼容配置为 Java 8，这是 Android 编译目标；Spring Boot 后端仍必须使用 JDK 17，二者不可混淆。

Note: the Android module currently targets Java 8 bytecode compatibility, while the Spring Boot backend requires JDK 17. These are separate settings and must not be confused.

版本变更必须单独提交，并包含：兼容性影响、迁移步骤、依赖锁文件变化、完整测试结果和回退方案。

Version changes require a dedicated submission with compatibility impact, migration steps, lockfile changes, full verification, and a rollback plan.

---

## 11. 安全、隐私和日志 / Security, Privacy, and Logging

- 禁止提交或输出 API Key、Token、密码、数据库连接密码和私有签名。
- 禁止把用户上传文件、聊天原文、生成附件 Base64 或隐私数据写入普通日志。
- 错误响应不得直接返回供应商完整响应、堆栈或内部路径。
- 文件名、MIME、扩展名、大小和内容都必须在服务端验证；不能信任前端声明。
- 第三方 URL 下载必须考虑 SSRF、超时、大小限制和内容类型。
- 提示词中不得拼接未经边界处理的系统机密；工具输出不得泄漏系统提示词和配置。
- 引入新依赖前必须说明用途，优先使用成熟维护库，并检查许可证和已知安全风险。

Never commit or emit secrets. Do not log user files, raw conversations, Base64 artifacts, or private data. Sanitize errors, validate file content server-side, protect third-party downloads against SSRF/time/size/type risks, prevent prompt/config leakage, and review the maintenance, license, and security posture of new dependencies.

---

## 12. AI 编码助手专用行为 / AI-Agent-Specific Behavior

AI 在本项目中开发工具时必须遵循以下行为：

AI agents working on tools MUST follow these behaviors:

1. 先阅读代码和规范，再提出或执行实现；不得只根据截图猜测架构。
2. 开始前报告当前分支、计划开发的工具（最多 3 个）、复用执行器和预计影响层。
3. 发现不在个人分支时，不得提交；如果用户要求提交，先提醒并协助创建个人分支。
4. 发现工作区已有改动时必须保护，禁止回滚不属于当前任务的内容。
5. 先复用现有代码、协议和组件，确认无法复用后才新增抽象或依赖。
6. 不得把 placeholder、mock 返回或仅创建 `QUEUED` 记录宣称为真实功能完成。
7. 不得为了通过测试删除断言、降低校验、跳过失败测试或把异常吞掉。
8. 不得修改已执行的 Flyway 文件，不得直接操作用户数据完成自动测试。
9. 不得在没有测试输出的情况下声称“测试通过”。无法测试时必须明确说明原因和风险。
10. 完成后必须列出修改、测试、数据库变化、真实可用程度和剩余限制。

AI agents must inspect before coding, report scope and branch, preserve existing changes, reuse architecture, distinguish mocks from real functionality, never weaken tests or migrations, never claim unrun verification, and provide an honest structured handoff.

---

## 13. 完成检查清单 / Definition-of-Done Checklist

提交前逐项确认 / Confirm every item before submission:

- [ ] 当前处于个人分支，不是 `main`。
- [ ] 本次工具数量不超过 3 个。
- [ ] 已明确 Tab、分类、`toolId`、executor 和 operation。
- [ ] 优先复用了已有执行器和动态工具页面。
- [ ] PostgreSQL 工具配置、Flutter mock 和客户端契约一致。
- [ ] 输入、参数、附件和输出均有服务端校验。
- [ ] 结果、附件和历史记录链路完整。
- [ ] 新表/字段/索引提供了新的 Flyway SQL，且未修改旧迁移。
- [ ] 未开发股票、智能体、登录、积分或 VIP 禁区。
- [ ] 未提交生成文件、本地配置、密钥、Base64 或用户数据。
- [ ] 后端相关测试通过；如影响后端，完成 `mvn test` 和 `mvn package`。
- [ ] Flutter 格式化、分析和测试通过；涉及原生集成时完成 Android Studio 真机 Run。
- [ ] 开发者已亲自测试成功、失败、历史记录和附件场景。
- [ ] 提交说明包含工具、Tab、执行器、数据库变化、测试结果和限制。

- [ ] Work is on a personal branch, not `main`.
- [ ] No more than three tools are included.
- [ ] Tab, category, tool ID, executor, and operation are explicit.
- [ ] Existing executors and the dynamic tool page were reused first.
- [ ] PostgreSQL definitions, Flutter mocks, and contracts are synchronized.
- [ ] Server-side validation covers inputs, parameters, attachments, and outputs.
- [ ] Results, artifacts, and history are complete.
- [ ] Schema changes have a new Flyway migration and no old migration was edited.
- [ ] Out-of-scope stock, agent, auth, points, and VIP areas were untouched.
- [ ] No generated files, local config, secrets, Base64, or user data are included.
- [ ] Backend and Flutter verification commands pass as applicable.
- [ ] Native changes were tested through a full Android Studio device run.
- [ ] The developer manually tested success, failure, history, and artifacts.
- [ ] The handoff lists scope, executors, database changes, verification, and limitations.
