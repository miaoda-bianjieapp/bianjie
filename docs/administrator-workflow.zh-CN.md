# GitHub 仓库管理员完整协作流程

本文面向边界 AI 仓库管理员、项目负责人和被授权的代码审查者，说明从邀请协作者、批准工具任务，到审查 Pull Request（PR）、合并代码和处理异常的完整流程。

开发者操作见 `docs/developer-tool-workflow.zh-CN.md`；架构、安全和测试的强制规则以根目录 `AGENTS.md` 为准。本文不会替代 GitHub 权限控制、Required checks 或正式代码审查。

## 一、管理员的职责边界

管理员不是只负责点击 `Squash and merge`。管理员需要对以下结果负责：

1. 需求范围明确，一次 AI 任务不超过 3 个同能力族工具。
2. `toolId`、executor、operation、公共文件和 Flyway 不与其他任务冲突。
3. 开发者只在个人分支工作，不能直接修改 `main`。
4. PR 的实际代码与批准的 Issue 一致，没有悄悄扩大范围。
5. CI、代码审查、数据库检查和必要的真机抽测都完成。
6. 密钥、用户数据、本地配置和构建产物没有进入 Git。
7. 合并顺序可控，合并后 `main` 仍然可运行。
8. 任务看板、Issue、PR 和实际代码状态一致。

管理员不应替开发者完成以下责任：

- 替开发者编造测试结果或勾选未执行的测试。
- 在没有需求确认时替开发者直接编码。
- 因赶进度绕过失败的 CI、未解决的审查意见或数据库风险。
- 把普通 PR 模板复选框当成真正的权限控制。

## 二、先理解 GitHub 中的对象

| 对象 | 表示什么 | 管理员动作 |
|---|---|---|
| Organization | 团队成员和仓库的上层组织 | 邀请成员、控制角色 |
| Repository | 前后端 monorepo | 设置规则、Actions 和合并方式 |
| Issue | 开发前的任务申请 | 澄清、批准、分配任务 ID |
| `TOOL_DEVELOPMENT_BOARD.md` | 仓库内任务与共享资源台账 | 管理员维护 |
| Branch | 一项任务的独立代码线 | 检查命名、来源和同步状态 |
| Pull Request | 从个人分支申请合并到 `main` | 审查、要求修改、批准、合并 |
| GitHub Actions | 自动格式、测试、安全和迁移检查 | 查看失败原因，不手工伪造通过 |
| Review | GitHub 正式代码审查结论 | `Comment`、`Approve` 或 `Request changes` |
| Ruleset | 对 `main` 的强制保护 | 禁止直接 push，要求 PR 和 CI |

Issue 回答“准备做什么”，PR 回答“实际做了什么”，Actions 回答“自动检查是否通过”，Review 回答“管理员是否同意”，Ruleset 决定“是否允许合并”。

## 三、一次性配置 GitHub 仓库

详细初始设置见 `docs/github-collaboration-setup.md`。管理员至少要确认以下配置。

### 3.1 邀请组织成员

进入组织页面：

```text
GitHub 右上角头像
-> Your organizations
-> miaoda-bianjieapp
-> People
-> Invite member
```

输入同事 GitHub 用户名或邮箱，邀请其加入组织。权限遵循最小化原则：

- 普通开发者只需要能读取仓库、推送个人分支和创建 PR。
- Reviewer 需要能够审查 PR。
- 仓库管理员和组织 Owner 只分配给少数负责人。
- 不要为了方便给所有同事 Admin 或 Owner。

邀请后，让开发者确认能打开仓库、创建个人分支和 Issue，但不能直接 push `main`。

### 3.2 确认 main 保护规则

进入：

```text
Repository
-> Settings
-> Rules
-> Rulesets
-> protect-main
```

确认：

- `Enforcement status` 为 `Active`。
- Target 包含默认分支 `main`。
- 禁止删除和 force push。
- 必须通过 Pull Request 合并。
- 团队协作后 `Required approvals` 至少为 `1`。
- 开启新提交后撤销旧审批（Dismiss stale approvals）。
- 开启解决全部对话后才允许合并。
- 开启 Required status checks，并包含：

```text
Backend CI result
Flutter CI result
Secrets, generated files, and Flyway rules
```

管理员自己发起的演示 PR 可能因为权限或 bypass 设置仍能看到合并按钮。是否看到按钮不等于流程已经完成，应以 Required checks、Review 和团队规则为准。

### 3.3 确认 Actions

进入仓库顶部：

```text
Actions
```

左侧应看到：

- `Backend CI`
- `Flutter CI`
- `Repository Rules`

PR 创建或更新后会自动运行，不需要开发者手动开启。普通文档 PR 中后端和 Flutter 的重任务显示 `Skipped` 是正常的，只要三个最终 Required result 都通过。

### 3.4 确认合并方式

进入：

```text
Repository
-> Settings
-> General
-> Pull Requests
```

建议：

- 开启 `Allow squash merging`。
- 关闭普通 merge commit，减少历史噪声。
- 团队不熟悉 rebase 时关闭 rebase merging。
- 开启 `Automatically delete head branches`。

Squash Merge 会把个人分支中的多个开发提交整理成 `main` 上的一个提交。删除已合并的远程个人分支不会删除进入 `main` 的代码和 PR 历史。

### 3.5 创建协作标签

进入：

```text
Repository
-> Issues
-> Labels
-> New label
```

建议建立：

```text
tool-request
architecture-review
database-migration
changes-requested
ready-to-merge
blocked
```

标签用于筛选，不替代 Issue 状态、看板记录或 GitHub Review。

## 四、收到工具开发 Issue 后怎么处理

### 4.1 打开并初筛 Issue

进入：

```text
Repository
-> Issues
-> 打开 [Tool] 开头的 Issue
```

先检查：

1. 是否只涉及允许开发的功能、写作或首页范围。
2. 是否包含 1 到 3 个工具，且适合放在同一能力族和同一 PR。
3. 是否提供对标截图、目标用户任务和可观察的验收标准。
4. 截图是否遮挡账号、手机号、Key、订单和用户隐私。
5. AI 是否区分截图事实、推断和待确认问题。
6. `toolId` 是否稳定、唯一并符合小写英文加连字符格式。
7. executor/operation 是否有代码依据，而不是仅凭工具名称猜测。
8. 是否可能影响公共执行器、协议、历史附件或数据库。

Issue 中填写“待 AI/管理员确认”是允许的。管理员应做架构判断，而不是要求普通开发者盲填。

### 4.2 使用 AI 辅助架构审查

管理员可以把 Issue、截图和代码仓库交给 AI，使用下面的提示词：

```text
你作为边界 AI 仓库的架构审查助手，请读取 AGENTS.md、
TOOL_DEVELOPMENT_BOARD.md、GitHub Issue #<编号>、全部参考截图，
以及工具目录、动态表单、ToolExecutorRegistry、相关 executor、
tool_runs、artifact、Flutter repository/provider/page 和 Flyway 代码。

本阶段禁止修改文件和编码。请审查：
1. 是否超过 3 个工具，是否属于同一能力族；
2. 每个 toolId 是否唯一稳定；
3. 应复用哪个 executor，operation 如何命名，是否真的需要新执行器；
4. 动态工具页面能否表达，是否真的需要专用页面；
5. 输入、参数、附件、输出、历史记录和失败状态是否完整；
6. 前后端协议、mock 和数据库分别可能修改什么；
7. 是否需要 Flyway，是否存在共享文件冲突；
8. 验收标准是否可测试，缺少哪些成功、失败和边界场景；
9. 列出必须向开发者确认的问题；
10. 最后给出“批准 / 补充信息后批准 / 拆分 / 拒绝”的建议和理由。

不得把截图表现当成后台能力已经存在，不得编造代码现状。
```

AI 只能辅助，最终批准由管理员负责。管理员至少应抽查 AI 引用的执行器、配置协议和数据表是否真实存在。

### 4.3 检查冲突和唯一性

在 GitHub 搜索或本地执行：

```powershell
git switch main
git pull --ff-only origin main
rg "建议的-tool-id|建议的-operation" .
```

同时查看 `TOOL_DEVELOPMENT_BOARD.md`：

- 是否已有相同 `toolId`。
- 是否有人占用同一 executor 或共享 Flutter 页面。
- 是否有尚未合并的数据库迁移。
- 是否两个同事正在修改同一协议 DTO。

同一共享文件并非绝对不能并行修改，但管理员必须明确合并顺序和后同步者，避免两人各自扩展出冲突设计。

### 4.4 决定 Issue 结果

管理员可以做四种决定：

- **批准**：范围、架构和验收均明确。
- **补充信息后批准**：缺截图、参数、输出或模型能力证明。
- **拆分**：超过 3 个工具、跨多个能力族或改动过大。
- **拒绝/暂缓**：属于禁止范围、底层能力不存在或当前优先级不合适。

批准评论可以使用：

```markdown
## 管理员批准

- Task ID: `TOOL-<编号>`
- Owner: `@开发者`
- Tools: `<工具名和 toolId>`
- Tab/category: `<Tab / 分类>`
- Executor: `<executor>`
- Operations: `<operation>`
- Branch: `dev/<姓名>/<主题>`
- Shared ownership: `<公共文件或无>`
- Database/Flyway: `<不涉及 / 迁移目的，最终版本待审查>`
- Acceptance additions: `<管理员补充场景>`

请从最新 `main` 创建上述个人分支。只允许开发本评论批准的范围；架构或数据库需求变化时先在本 Issue 重新确认，不得自行扩大。
```

尚未批准时添加 `architecture-review` 或 `blocked` 标签；批准后保持 `tool-request`，并在 Issue 评论中写清分支名和约束。

## 五、管理员如何登记任务看板

`TOOL_DEVELOPMENT_BOARD.md` 由管理员维护。由于 `main` 受保护，看板修改也应通过一个小型管理员 PR 合并，不能直接 push。

### 5.1 创建看板管理分支

```powershell
git switch main
git pull --ff-only origin main
git switch -c admin/<姓名>/assign-tool-<编号>
```

在当前任务表新增一行，至少填写：

- Task ID
- Owner
- 工具、Tab、分类
- `toolId`
- executor/operation
- 开发者个人分支
- 公共文件占用
- 数据库/Flyway 目的
- Issue 链接
- 状态“需求确认”或“开发中”
- 更新时间

如果涉及数据库，在 Flyway 迁移占用表登记迁移目的，但不要过早分配短版本 `V3`、`V4`。

提交、推送并建立一个只修改看板的小 PR：

```powershell
git add TOOL_DEVELOPMENT_BOARD.md
git commit -m "chore(board): assign TOOL-<编号>"
git push -u origin admin/<姓名>/assign-tool-<编号>
```

管理员自己的看板 PR 同样等待 Required checks。合并后在 Issue 中通知开发者可以开始编码。

多人任务较多时，可以把同一批已批准任务合并成一个小型看板 PR，但不得让开发者在登记合并前开始占用同一 `toolId` 或共享文件。

## 六、开发期间管理员怎么管理

管理员不需要每天拉取每个人的完整项目副本。Git 分支共享同一个 `.git` 对象库，切换分支只改变当前工作区内容，不会复制出多套同样文件。

开发期间应关注：

1. Issue 中是否出现架构变更请求。
2. 两个开发者是否开始修改同一公共执行器或协议。
3. 是否新增未登记的数据表、字段或外部依赖。
4. 是否有更早的 PR 合并，导致后续分支落后于 `main`。
5. 开发者是否把“占位”误称为“真实可用”。

如果需求变化，要求开发者先在原 Issue 说明：变化原因、新文件、新数据库影响和验收变化。管理员批准后再更新看板；不要通过聊天口头扩大范围而不留下记录。

## 七、PR 到达后的 GitHub 页面操作

### 7.1 打开 PR 并确认基本信息

进入：

```text
Repository
-> Pull requests
-> 打开目标 PR
```

顶部应显示：

```text
开发者 wants to merge <提交数> commits into main from <个人分支>
```

确认：

- `base` 是 `main`。
- `head` 是批准的个人分支，不是其他共享分支。
- PR 标题准确，例如 `feat(tools): add pdf merge operation`。
- PR 描述使用模板并通过 `Closes #<Issue编号>` 关联正确 Issue。
- 工具、`toolId`、executor/operation 与批准评论一致。
- 测试只勾选真实执行的项目，未执行项有解释。
- 开发者没有勾选或冒充管理员正式审批。

PR 正文中的 `Administrator Checklist` 只是协作记录，PR 作者也能编辑。真正有效的审批是 GitHub Review、Required approvals、Required checks 和 Ruleset。

### 7.2 理解 PR 的四个主要区域

PR 页面通常包含：

1. **Conversation**：PR 描述、讨论、CI 汇总、审批和合并区域。
2. **Commits**：该分支相对 `main` 的提交列表。
3. **Checks**：每个 GitHub Actions 任务及完整日志。
4. **Files changed**：最终代码差异和逐行审查入口。

管理员不能只看 Conversation 的绿色结果。必须进入 `Files changed` 查看实际差异。

### 7.3 先审查提交范围

在 `Files changed` 顶部查看变更文件数量和增删行数，重点检查是否出现：

- 与工具无关的页面或模块。
- `application-local.yml`、`.env`、Key、密码或真实连接信息。
- `build/`、`target/`、APK、IDE 文件或本地数据库。
- 对旧 Flyway `V1/V2` 的修改。
- SDK、JDK、Gradle、Spring Boot 或主要依赖升级。
- 股票、智能体、登录、积分、支付或 VIP 改动。
- 大量格式化导致的无关文件变化。

出现范围污染时先 `Request changes`，不要一边审查一边替开发者在 `main` 修补。

### 7.4 逐层审查代码

建议按以下顺序：

1. **配置层**：工具配置、字段、inputModes、outputFormats、operation。
2. **协议层**：后端 DTO 与 Flutter model/repository/mock 是否同步。
3. **路由层**：`supports()` 是否按 executor 匹配，是否会被 fallback 抢占。
4. **执行层**：输入校验、附件、超时、错误映射、重试和 artifact。
5. **持久化层**：`tool_runs`、历史回看、附件是否可重新打开。
6. **数据库层**：Entity、Repository、Flyway、索引和兼容性。
7. **UI 层**：动态页面复用、加载/失败/空状态、窄屏和中文长文本。
8. **测试层**：路由、成功、非法输入、供应商失败和回归测试。
9. **安全层**：密钥、日志、用户文件、SSRF、Base64 和内部错误泄漏。

对每个问题，点击对应代码行旁边的 `+` 添加评论。多条问题应先使用 `Start a review`，全部写完后统一提交 Review，避免开发者收到大量零散通知。

### 7.5 使用 GitHub Review

在 `Files changed` 右上角点击：

```text
Review changes
```

选择：

- `Comment`：只是讨论，不阻止合并。
- `Approve`：确认当前版本可以合并。
- `Request changes`：存在必须修改的问题，阻止合并。

Review 总结应明确：

- 阻塞问题是什么。
- 为什么会产生错误或风险。
- 期望行为和验收方式是什么。
- 哪些是建议优化但不阻塞本次合并。

不要只写“这里不对”或让开发者猜解决目标。

作者不能用自己的 Approve 满足“至少一名其他审查者批准”。管理员自己发起 PR 时，可由另一名管理员审查；团队只有一人时只能暂时将 Required approvals 设为 0，但不能关闭 Required checks。

## 八、如何判断 CI 结果

在 PR 的 Conversation 底部或 `Checks` 页面查看：

- 绿色：通过。
- 红色：失败，必须打开日志定位。
- 黄色圆点：正在运行，等待完成。
- 灰色 Skipped：路径不相关或可选任务被跳过。

项目要求三个最终结果通过：

```text
Backend CI result
Flutter CI result
Secrets, generated files, and Flyway rules
```

后端 PR 中 Flutter 重任务可能跳过，文档 PR 中后端和 Flutter 重任务都可能跳过，这是路径检测的设计结果。最终 result 必须为绿色。

CI 失败时：

1. 点击失败检查名称。
2. 点击左侧失败 Job。
3. 展开带红叉的 Step。
4. 找到第一处真实报错，不要只看最后的 `exit code 1`。
5. 把日志链接或必要片段发给开发者。
6. 开发者在同一个个人分支修复、commit、push。
7. PR 自动更新并重新运行，不需要创建新 PR。

只有网络抖动、GitHub runner 临时故障等非代码问题才使用 `Re-run failed jobs`。代码错误不能靠重复运行碰运气。

管理员 AI 辅助诊断提示词：

```text
请分析 PR #<编号> 的 CI 失败。读取 AGENTS.md、PR 相对 origin/main 的 diff、
工作流 YAML 和我提供的完整失败日志。本阶段不要修改文件。

请指出第一处根因、为什么本机可能没有复现、影响范围、最小修复方案和应新增的
回归验证。区分代码错误、缺失跟踪文件、CI 配置错误和 runner 临时故障。
不要只复述最后一行 exit code。
```

## 九、数据库和 Flyway 的管理员审查

涉及数据库的 PR 需要额外执行：

1. 对照 Issue 和看板确认数据库变化已提前登记。
2. 确认没有修改、重命名或删除已经执行的迁移。
3. 确认新 SQL 在固定目录：

```text
apps/api-java/src/main/resources/db/migration/postgresql/
```

4. 文件名使用管理员最终确认的 14 位 UTC 时间戳。
5. 检查表、列、索引、约束、默认值和数据回填是否安全。
6. 检查 JPA Entity、DTO、Repository 和测试是否同步。
7. 要求开发者说明备份、兼容性和必要的回滚/修复策略。
8. 破坏性删除或大规模数据改写必须单独批准。

如果两个待合并 PR 都包含迁移：

1. 管理员决定先合并哪个。
2. 先合并 PR A。
3. 要求 PR B 同步最新 `main`。
4. 重新检查迁移顺序和依赖。
5. 尚未进入任何共享数据库时，PR B 可以按管理员要求改用更晚时间戳。
6. 已在共享数据库执行的迁移禁止改名，只能新增修复迁移。

## 十、管理员如何在本地审查同事分支

GitHub 网页适合代码阅读，但真机和完整运行需要本地检出分支。先保护当前工作区：

```powershell
git status
git fetch origin
git switch -c review/<开发者>-<主题> --track origin/dev/<开发者>/<主题>
```

这不会复制一套项目文件；所有本地分支共享同一个 Git 仓库。审查结束切回：

```powershell
git switch main
```

PR 合并后可删除本地审查分支：

```powershell
git branch -D review/<开发者>-<主题>
```

执行 `-D` 前必须先确认对应 PR 已经合并或本地审查分支已经不再需要。由于项目采用 Squash Merge，审查分支的原提交不会原样成为 `main` 的祖先，`git branch -d` 可能拒绝删除；`-D` 只能用于已经核实可以丢弃的本地审查分支，不能用于未合并开发成果。每个远程开发分支应使用独立的本地审查分支。不要让一个本地审查分支反复 `--track` 多个开发分支，这会混淆上游关系。

管理员本地至少应按风险选择执行：

- 后端：`mvn test`、`mvn package`。
- Flutter：格式检查、`flutter analyze`、`flutter test`。
- 数据库：在隔离测试库验证迁移，不使用生产库。
- 手机：IDEA 启动后端，Android Studio 通过 USB 运行 App。

普通 Dart/Java 改动不需要额外构建 APK。涉及原生插件、权限、Manifest、Gradle 或资源时，使用 Android Studio 完整重新 Run。

## 十一、真机抽测应该测什么

管理员不一定重复开发者全部用例，但核心链路必须抽查：

1. 工具位于正确 Tab、分类和排序。
2. 主输入、参数、默认值、必填和附件限制正确。
3. 至少一次真实成功调用，结果不是 mock 或占位。
4. 至少一次非法输入或供应商失败，提示可理解且不泄漏内部信息。
5. 文本结果可复制。
6. 图片或文件 artifact 可预览、打开和保存。
7. 退出页面后能从历史记录回看输入、输出和附件。
8. 首页对话和至少一个既有工具没有明显回归。
9. 窄屏手机、中文长文本、加载和失败状态没有重叠。

如果模型调用需要开发者个人 Key，管理员可以让开发者现场演示，或使用管理员自己的本地忽略配置。禁止把 Key 放进 PR、Actions 日志或测试代码。

## 十二、PR 落后 main 或发生冲突时

当另一个 PR 先合并后，当前 PR 可能显示 `This branch is out-of-date` 或冲突。

没有冲突且 GitHub 显示 `Update branch` 时，可以要求开发者点击该按钮；团队更推荐开发者本地执行并验证：

```powershell
git fetch origin
git switch dev/<姓名>/<主题>
git merge origin/main
```

解决冲突、重新测试后：

```powershell
git add <已解决文件>
git commit
git push
```

不要由管理员随意使用 `git reset --hard`、强推或覆盖开发者分支。冲突应由最了解该功能的开发者解决，管理员负责确认公共协议和迁移取舍。

分支同步后旧审批可能按规则自动失效。管理员必须审查新增差异并重新 Approve，等待最新一轮 CI 通过。

## 十三、合并前最终检查

管理员在 PR 正文的 `Administrator Checklist` 记录以下事实，但真正的控制仍是 Review 和 Ruleset：

- [ ] Task 已登记到 `TOOL_DEVELOPMENT_BOARD.md`。
- [ ] `toolId`、executor/operation 和公共文件与批准 Issue 一致。
- [ ] PR 已同步最新 `main`，没有未解决冲突。
- [ ] 三个 Required result 在最新提交上通过。
- [ ] 所有 Review 对话已解决，没有有效的 Request changes。
- [ ] Flyway 文件名和顺序已批准，旧迁移未修改。
- [ ] 自动测试结果有记录，没有虚假勾选。
- [ ] 核心成功、失败、附件、历史和回归场景已抽查。
- [ ] PR 中没有密钥、用户数据、生成文件或环境配置。
- [ ] 已知限制可接受，并已记录后续 Issue（如需要）。

可使用 AI 做最终只读审查：

```text
你作为边界 AI 仓库管理员的合并前审查助手，请读取 AGENTS.md、
Issue #<编号>、PR #<编号> 描述、当前 PR 相对 origin/main 的完整 diff、
CI 结果和审查评论。本阶段禁止修改、提交或推送。

请先按严重程度列出会阻止合并的问题，重点核对范围、executor/operation、
前后端契约、Flyway、历史附件、安全、测试和未解决评论。
然后列出管理员仍需人工验证的真机场景。
如果没有阻塞问题，明确给出“可以合并”，并说明剩余风险；不要因为 CI 绿色就默认代码正确。
```

## 十四、在 GitHub 上批准和 Squash Merge

### 14.1 提交正式审批

进入：

```text
PR
-> Files changed
-> Review changes
-> Approve
-> Submit review
```

如果 `Required approvals = 1`，审批人必须是 PR 作者之外、具有审查权限的人。PR 更新代码后，如果旧审批被撤销，应重新检查并 Approve。

### 14.2 执行 Squash Merge

回到 PR 的 Conversation 底部，确认显示：

```text
All checks have passed
No conflicts with base branch
Required approving reviews 已满足
```

点击：

```text
Squash and merge
```

GitHub 会进入确认步骤。检查最终提交标题，建议保持清晰的 Conventional Commit，例如：

```text
feat(tools): add PDF merge and split (#123)
```

提交正文可以保留工具、测试和迁移摘要。然后点击：

```text
Confirm squash and merge
```

这就是合并时的第二次确认，不是创建 PR 时的第二次 `Create pull request`。

如果按钮可点击但审批或抽测尚未完成，不要提前合并。管理员权限不是跳过流程的理由。

## 十五、合并后的管理员动作

### 15.1 查看 main 的合并后 CI

进入：

```text
Repository
-> Actions
```

确认 `main` 上新触发的三个工作流没有失败。PR CI 通过不代表合并后的分支事件一定不会暴露问题。

### 15.2 更新 Issue 和任务看板

如果 PR 描述包含正确的 `Closes #<编号>`，Issue 会在合并后自动关闭。管理员仍应检查：

- Issue 是否关闭。
- PR 是否正确关联。
- 是否需要创建后续限制/缺陷 Issue。
- 看板状态是否从“等待合并”更新为“已合并”或真机集成后“已验收”。
- PR 链接、最终 Flyway 文件和更新时间是否写入看板。

看板更新仍通过小型管理员分支和 PR 完成。为了减少管理 PR 数量，可以按当天或一批合并任务集中更新状态，但不能让看板长期失真。

### 15.3 删除分支和通知团队

若开启自动删除，GitHub 会删除远程个人分支。否则管理员可在已合并 PR 页面点击 `Delete branch`。

通知其他开发者：

```text
PR #<编号> 已合并到 main。涉及 <公共执行器/协议/数据库迁移>。
请在继续相关任务前同步最新 main，并检查自己的分支是否需要解决冲突。
```

开发者同步：

```powershell
git switch main
git pull --ff-only origin main
```

## 十六、两个或多个 PR 同时等待合并

管理员不要一次性把多个分支混到本地 `main` 后再统一测试和推送。每个 PR 独立审查、独立 CI、按顺序合并。

推荐流程：

```text
审查 PR A 和 PR B
-> 决定依赖和风险顺序
-> 合并 PR A
-> 等待 main CI
-> 要求 PR B 同步最新 main
-> PR B 重新 CI 和必要审批
-> 再合并 PR B
-> 通知其他相关开发者同步 main
```

若两者完全修改不同模块，仍按顺序合并；第二个 PR 是否必须更新由 Ruleset 和管理员风险判断决定。若涉及相同 executor、协议、工具配置或 Flyway，第二个 PR 必须同步并重新验证。

## 十七、常见异常处理

### 17.1 PR 含有密钥

1. 立即阻止合并。
2. 要求删除密钥并清理分支历史。
3. 立即在供应商后台撤销/轮换密钥，仅删除代码不够。
4. 检查 Actions 日志、Issue 和评论是否也泄漏。
5. 必要时将仓库临时限制访问并记录安全事件。

不要在评论中重复粘贴完整密钥。

### 17.2 开发者误改旧 Flyway

Request changes，要求恢复旧迁移并新增后续迁移。任何共享环境可能执行过的迁移都不能修改校验和。

### 17.3 PR 超出批准范围

要求移除无关改动，或者回到 Issue 重新评审并拆分 PR。不要因为代码已经写完就默认批准扩大范围。

### 17.4 CI 绿色但功能不工作

CI 只覆盖自动测试。管理员应 Request changes，记录真机复现步骤，并要求增加回归测试。禁止仅凭绿色 CI 合并。

### 17.5 开发者长期无响应

在 Issue 和 PR 标记 `blocked`，说明截止时间和缺失内容。确认不再继续后关闭 PR、将看板标为“已取消”，释放 `toolId`、公共文件和未执行的迁移占用。删除分支前先确认没有需要保留的工作。

### 17.6 错误合并进入 main

不要使用 `git reset --hard` 或改写共享 `main` 历史。优先创建新的修复 PR；确需回退时使用 GitHub `Revert` 创建回退 PR，等待 CI 和审查后合并。数据库迁移已经执行时，回退代码不等于回退数据库，必须单独设计前向修复迁移。

## 十八、管理员每周维护

建议每周检查：

- Open Issues 是否有长期未分配或缺少回复的任务。
- Open PRs 是否长期失败、落后 `main` 或等待审查。
- 看板状态是否与 Issue/PR 一致。
- 公共文件和 Flyway 占用是否可以释放。
- Actions 是否出现重复失败或耗时明显增长。
- 组织成员权限是否仍符合职责，离开项目的成员是否已移除。
- 依赖安全告警是否需要独立升级任务。

依赖、SDK、JDK、Gradle 或 Spring Boot 升级必须作为单独任务和 PR，不要混入普通工具开发。

## 十九、管理员最短操作清单

```text
配置成员最小权限、main Ruleset、Actions 和 Squash Merge
-> 查看工具申请 Issue 和截图
-> AI 辅助架构审查，管理员核实代码依据
-> 确认 toolId、executor/operation、公共文件和数据库影响
-> 在 Issue 留批准评论
-> 管理员通过小 PR 登记 TOOL_DEVELOPMENT_BOARD.md
-> 通知开发者从最新 main 创建个人分支
-> 开发期间管理范围变化和共享文件冲突
-> PR 到达后检查描述、Issue 关联和变更范围
-> 查看 Files changed，提交 Comment / Request changes / Approve
-> 检查三个 Required result 和完整失败日志
-> 审查 Flyway，必要时决定多个 PR 的合并顺序
-> 本地检出审查分支，运行测试和 USB 真机抽测
-> 确认最新 main、审批、CI、对话和限制全部满足
-> Approve
-> Squash and merge
-> 检查 main CI
-> 更新看板和 Issue，删除分支，通知其他开发者同步 main
```
