# 共享工具开发表字段模板 / Shared Tool Development Table Template

本文件是管理员共享工具开发表的字段模板和离线备份参考。团队日常以腾讯文档、企业微信在线表格、QQ/微信共享 Excel 或其他管理员指定的实时共享表为准，不要求每次状态变化都修改本文件并创建 Git PR。它定义任务表和 Flyway 迁移占用表的统一字段，避免重复开发、`toolId` 冲突、执行器冲突和迁移版本冲突。开发者先通过 GitHub 的“工具开发申请”Issue 模板提交信息，管理员确认后更新共享表；普通开发者不应直接修改共享表的结构或删除记录。

This file is the field template and offline backup reference for the administrator-owned shared tool development table. The team may use a Tencent document, WeCom online sheet, shared QQ/WeChat spreadsheet, or another approved real-time sheet as the daily source of truth. Developers submit a GitHub Tool Development Request Issue first; after approval, the administrator updates the shared table. Developers must not change the table schema or delete records directly.

> 开发前必须同时阅读根目录 `AGENTS.md`。每次 AI 任务最多开发 3 个工具。
>
> Read the root `AGENTS.md` before development. One AI task may implement at most three tools.

### GitHub 协作入口 / GitHub Collaboration Entry Points

```text
GitHub Issue（开发者填写需求申请）
    -> 共享工具开发表（管理员登记和分配资源）
    -> 个人分支开发
    -> Pull Request（开发者提交交付说明）
    -> GitHub Actions（自动检查）
    -> 管理员审查、抽测和合并
```

- **开发者填写**：GitHub Issue 和 PR 模板。
- **管理员维护**：共享表的任务行、状态、公共文件占用和 Flyway 登记；本文件只作为字段模板和必要时的 Git 备份。
- **GitHub Actions 维护**：编译、测试、格式、静态分析、密钥、生成文件和 Flyway 规则检查。

- **Developer-owned**: GitHub Issue and PR forms.
- **Administrator-owned**: the shared table's assignments, statuses, shared ownership, and Flyway registry; this file is its field template and optional Git backup.
- **GitHub Actions-owned**: build, test, format, analysis, secret, generated-file, and Flyway checks.

---

## 1. 当前开发任务 / Active Development Tasks

管理员分配任务后新增一行。一个 PR 可以包含同一能力族的 1 到 3 个工具；若一个任务包含多个工具，将 `toolId` 和 `operation` 用 `<br>` 分行填写。

Add one row after the administrator assigns a task. One PR may contain one to three tools from the same capability family. Use `<br>` to list multiple tool IDs and operations.

| 任务 ID / Task ID | 开发者 / Owner | 工具与 Tab / Tools and Tab | `toolId` | `executor` / `operation` | 分支 / Branch | 公共文件占用 / Shared Ownership | 数据库与 Flyway / DB and Flyway | PR | 状态 / Status | 最后更新 / Updated |
|---|---|---|---|---|---|---|---|---|---|---|
| 示例-001 | 张三 | 功能 > PDF 操作：PDF 合并 | `pdf-merge` | `document-processing` / `pdf-merge` | `dev/zhangsan/pdf-merge` | `DocumentProcessingToolExecutor` | 新增 artifact 表；迁移待编号 | - | 需求确认 | 2026-07-12 |

> 上面的示例行仅演示格式，复制到正式共享表后可以删除。
>
> The sample row only demonstrates the format and may be removed when real tracking begins.

### 字段说明 / Column Definitions

- **任务 ID**：管理员分配的稳定编号，例如 `TOOL-001`。
- **开发者**：唯一负责人；需要协作者时在同一单元格注明 reviewer 或 pair。
- **工具与 Tab**：写明 Tab、分类、工具中文名以及真实可用/占位目标。
- **toolId**：必须在全项目唯一，一经合并不得随意修改。
- **executor / operation**：开工前完成能力分类；未知时标记 `待架构确认`，不得直接新建执行器。
- **分支**：开发者个人分支，不允许填写 `main`。
- **公共文件占用**：登记可能产生多人冲突的执行器、动态表单、协议 DTO、路由或共享组件。
- **数据库与 Flyway**：写明表、字段、索引、数据迁移；开发中可写“需要迁移，待编号”。
- **PR**：PR 编号或链接；未创建时填写 `-`。
- **状态**：只能使用第 3 节定义的状态。
- **最后更新**：每次状态变化都必须更新日期。

- **Task ID**: stable identifier assigned by the administrator, such as `TOOL-001`.
- **Owner**: one accountable developer; note a reviewer or pair when applicable.
- **Tools and Tab**: tab, category, Chinese tool name, and intended capability level.
- **toolId**: globally unique and stable after merge.
- **executor / operation**: classify before coding; use `architecture review required` when unresolved.
- **Branch**: personal development branch, never `main`.
- **Shared Ownership**: executors, protocol DTOs, routing, dynamic forms, or shared widgets likely to conflict.
- **DB and Flyway**: tables, columns, indexes, or data migrations; use `migration required, version pending` during development.
- **PR**: PR number or URL, or `-` before creation.
- **Status**: one of the states defined in Section 3.
- **Updated**: update the date whenever status changes.

---

## 2. Flyway 迁移占用表 / Flyway Migration Registry

只有涉及数据库结构或必要数据迁移的任务才登记。当前已存在 `V1` 和 `V2`，不得修改、重命名或删除。

Register only tasks that change database structure or require controlled data migration. `V1` and `V2` already exist and must never be edited, renamed, or deleted.

| 任务 ID / Task ID | 开发者 / Owner | 迁移目的 / Purpose | 开发阶段文件 / Draft File | 最终 Flyway 文件 / Final Migration | 依赖版本 / Depends On | 是否在共享库执行 / Applied to Shared DB | 状态 / Status |
|---|---|---|---|---|---|---|---|
| 基线 / Baseline | 项目 / Project | 初始结构与工具配置迁移 | - | `V1__initial_schema.sql`<br>`V2__migrate_tool_configs_to_database.sql` | - | 是 / Yes | 已锁定 / Locked |

### 推荐编号方式 / Recommended Versioning

多人协作建议使用 14 位 UTC 时间戳：

```text
VyyyyMMddHHmmss__lowercase_description.sql
```

示例：

```text
V20260712093000__add_tool_artifacts.sql
V20260712101500__add_tool_run_progress.sql
```

For parallel work, use a 14-digit UTC timestamp followed by a lowercase description.

### 开发和合并规则 / Development and Merge Rules

1. 开发者确认需要数据库变更后，先在本表登记目的，不要自行占用 `V3`、`V4` 等短版本。
2. 开发期间 SQL 可以放在个人分支的草稿文件中，例如 `docs/migration-drafts/TOOL-001__add_artifacts.sql`；草稿不得配置为 Flyway 自动执行目录。
3. PR 准备进入最终审查时，开发者先同步最新 `main`。
4. 管理员检查最新迁移列表，并要求开发者用当前 UTC 时间生成最终文件名。
5. 开发者将草稿移动为最终 Flyway 文件，更新本表，运行迁移和完整测试后推送 PR。
6. 管理员按 PR 顺序合并。若另一个 PR 在此期间加入了迁移，尚未执行到共享数据库的 PR 可以重新生成更晚的时间戳。
7. 一旦迁移在任何共享测试库、预发布库或生产库执行，文件立即标记“已锁定”，禁止修改或改名；修复只能新增后续迁移。

1. Register the migration purpose before choosing a final version.
2. During development, keep SQL in a non-Flyway draft path such as `docs/migration-drafts/TOOL-001__add_artifacts.sql`.
3. Synchronize the latest `main` before final review.
4. The administrator checks the latest migrations and asks the developer to generate a current UTC timestamp.
5. Move the draft to the final Flyway path, update this registry, run migrations and full tests, and push the PR.
6. Merge PRs sequentially. A not-yet-shared migration may receive a later timestamp if another migration merges first.
7. Once applied to any shared environment, the migration is locked forever; corrections require a new migration.

PowerShell 生成 UTC 文件名 / Generate a UTC migration name in PowerShell:

```powershell
$timestamp = (Get-Date).ToUniversalTime().ToString('yyyyMMddHHmmss')
$name = 'add_tool_artifacts'
New-Item "apps/api-java/src/main/resources/db/migration/postgresql/V${timestamp}__${name}.sql"
```

---

## 3. 状态流转 / Status Workflow

任务状态只能按以下方向推进：

```text
待分配
  -> 需求确认
  -> 开发中
  -> 开发者自测
  -> PR 审查中
  -> 等待合并
  -> 已合并
  -> 已验收
```

特殊状态：

- **阻塞**：缺少接口、模型、账号、产品决定或依赖任务。
- **退回修改**：代码审查或测试未通过，开发者继续在原个人分支修复。
- **已取消**：管理员终止任务，并释放 `toolId`、公共文件和迁移占用。

Tasks normally move from assignment through requirement confirmation, development, developer testing, PR review, merge readiness, merged, and accepted. Exceptional states are blocked, changes requested, and cancelled.

| 状态 / Status | 谁负责 / Owner | 进入条件 / Entry Criteria |
|---|---|---|
| 待分配 | 管理员 | 只有产品想法，尚未指定负责人 |
| 需求确认 | 管理员 + 开发者 | 已确定截图、目标、Tab、分类和最多 3 个工具 |
| 开发中 | 开发者 | 已分配 `toolId`、个人分支、executor/operation 和公共文件占用 |
| 开发者自测 | 开发者 | 编码完成，正在运行自动测试和真机测试 |
| PR 审查中 | 管理员/Reviewer | PR 模板填写完整，CI 已启动 |
| 退回修改 | 开发者 | 审查、CI 或人工测试发现问题 |
| 等待合并 | 管理员 | 审批、CI 和抽测均通过，且分支已同步最新 `main` |
| 已合并 | 管理员 | PR 已进入 `main`，远程功能分支可删除 |
| 已验收 | 管理员/产品 | `main` 集成环境或手机上验证完成 |

---

## 4. 管理员操作流程 / Administrator Workflow

### 4.1 收到新需求时 / When a Request Arrives

1. 在“当前开发任务”新增任务行并分配任务 ID。
2. 确认一次不超过 3 个工具，且属于允许开发的 Tab。
3. 分配唯一 `toolId`，确认没有其他人占用。
4. 与开发者确认复用哪个 executor、使用什么 operation。
5. 登记公共文件占用，避免两人同时重构同一个执行器。
6. 如涉及数据库，在 Flyway 表先登记目的，最终版本暂时留空。
7. 要求开发者从最新 `main` 创建个人分支，并由管理员把分支名写入共享表。

### 4.2 PR 到达时 / When a PR Is Opened

1. 将任务状态改为“PR 审查中”，填入 PR 链接。
2. 检查 PR 是否只包含登记范围，是否更新前后端契约、mock、测试和文档。
3. 检查 CI；失败则改为“退回修改”，不得合并。
4. 如有 Flyway，分配或确认最终时间戳，并检查旧迁移没有被修改。
5. 审查代码架构，然后在 PR 分支抽测真实功能。
6. 确认开发者已同步最新 `main`，CI 在同步后仍通过。
7. 改为“等待合并”，按顺序合并一个 PR。
8. 合并后改为“已合并”，再对下一个待合并 PR 重复同步和验证流程。

### 4.3 合并后 / After Merge

1. 在 `main` 或集成环境抽查新工具和关键回归。
2. 通过后将任务改为“已验收”。
3. 删除已合并的远程功能分支，保留 PR 和 Git 历史。
4. 通知仍在开发的成员：`main` 已更新，他们在提交前需要同步并重新测试。
5. 释放公共文件占用；已执行的 Flyway 迁移标记“已锁定”。

The administrator registers and scopes work, allocates unique identifiers and shared ownership, reviews CI/code/functionality, finalizes migrations, merges PRs one at a time, verifies integration, updates status, removes merged branches, and informs active developers of new `main` changes.

---

## 5. 开发者操作流程 / Developer Workflow

### 开始开发 / Start

```powershell
git switch main
git pull --ff-only
git switch -c dev/<name>/<short-topic>
```

然后把分支名告知管理员，由管理员更新共享表中的负责人、分支和状态。把任务 ID、工具清单、截图、共享表批准记录和 `AGENTS.md` 一起交给 AI。

Tell the administrator the branch name; the administrator updates the shared table. Give the AI the task ID, tool list, screenshots, approved shared-table record, and `AGENTS.md`.

### 开发完成 / Complete Development

1. 自己运行自动测试和 Android Studio 真机测试。
2. 通知管理员自测开始，由管理员把共享表状态更新为“开发者自测”。
3. 提交个人分支并创建 PR，完整填写 PR 说明。
4. 把 PR 链接发给管理员，由管理员写入共享表并更新为“PR 审查中”。
5. 管理员要求同步 `main` 时，在个人分支执行：

```powershell
git fetch origin
git merge origin/main
```

6. 自己解决冲突、重新测试并推送同一个个人分支；PR 会自动更新。
7. PR 合并后，开始下一项任务前重新从最新 `main` 创建新分支。

Developers test their own work, open a complete PR, keep the board current, merge the latest remote `main` into their personal branch when requested, resolve conflicts, retest, and start future work from a fresh branch based on updated `main`.

---

## 6. 管理员审查分支操作 / Administrator Review Branch Commands

### 重要概念 / Important Concept

一个本地审查分支只能关联一个远程分支。不要让同一个 `review/current` 反复 track 不同开发者分支，否则容易把提交关系和 push 目标弄乱。

One local review branch tracks one remote branch. Do not repeatedly repoint a shared `review/current` branch to different developers; it makes commit ancestry and push targets unsafe.

建议每个 PR 建一个临时本地审查分支：

```powershell
git fetch origin
git switch -c review/TOOL-001 --track origin/dev/zhangsan/pdf-merge
```

这里不会创建第二套项目，只是在当前目录切换到这个分支的文件版本。

This does not create a second project; it switches the current working directory to that branch's file version.

审查完成后切回 `main`：

```powershell
git switch main
git pull --ff-only
```

确认不再需要本地审查分支后删除：

```powershell
git branch -d review/TOOL-001
```

如果 PR 尚未合并而 `-d` 拒绝删除，可以保留审查分支；不要轻易使用 `-D`。同事更新 PR 后，再次进入审查分支并拉取：

```powershell
git switch review/TOOL-001
git pull --ff-only
```

审查同事 2 时，创建另一个分支：

```powershell
git switch main
git switch -c review/TOOL-002 --track origin/dev/lisi/image-cover
```

### 工作区有未提交改动时 / When the Working Tree Is Dirty

不要强行切换，也不要清理或覆盖自己的改动。可以先提交到自己的个人分支，或使用独立 worktree：

```powershell
git fetch origin
git worktree add ..\review-TOOL-001 origin/dev/zhangsan/pdf-merge
```

审查结束并确认目录不再需要后：

```powershell
git worktree remove ..\review-TOOL-001
```

Worktrees create an additional checkout directory while sharing Git history. Use them when your main working directory contains active work.

---

## 7. 每周维护 / Weekly Maintenance

管理员每周至少检查一次：

- 超过 3 个工作日未更新的“开发中”任务。
- 长期阻塞但没有明确下一步的任务。
- 重复或冲突的 `toolId`、operation 和公共文件占用。
- 已合并但未验收的任务。
- 已合并但未删除的远程功能分支。
- 已执行但未标记锁定的 Flyway 迁移。
- PR 中尚未解决的评论和失败 CI。

The administrator SHOULD review stale tasks, blockers, identifier and ownership conflicts, unaccepted merges, obsolete branches, unlocked applied migrations, unresolved comments, and failing CI at least weekly.

---

## 8. 实际任务登记示例 / Worked Example

场景：同事 1 开发 PDF 合并，同事 2 开发小红书封面。

| 任务 ID | 开发者 | 工具与 Tab | `toolId` | executor / operation | 分支 | 公共文件占用 | 数据库与 Flyway | PR | 状态 | 最后更新 |
|---|---|---|---|---|---|---|---|---|---|---|
| `TOOL-001` | 同事 1 | 功能 > PDF：PDF 合并 | `pdf-merge` | `document-processing` / `pdf-merge` | `dev/user1/pdf-merge` | `DocumentProcessingToolExecutor` | artifact 表；待编号 | `#21` | PR 审查中 | 2026-07-12 |
| `TOOL-002` | 同事 2 | 功能 > 图像：小红书封面 | `xiaohongshu-cover` | `image-generation` / `xiaohongshu-cover` | `dev/user2/image-cover` | `QwenImageToolExecutor` | 无 | `#22` | 开发者自测 | 2026-07-12 |

管理员先审查并合并 `#21`。之后同事 2 在 `dev/user2/image-cover` 执行：

```powershell
git fetch origin
git merge origin/main
```

同事 2 解决冲突并重新测试，`#22` 的 CI 重新通过后，管理员再审查和合并 `#22`。最后两位同事开始新任务前都从最新 `main` 创建新个人分支。

The administrator reviews and merges PR `#21` first. Developer 2 then merges the latest `origin/main` into their existing feature branch, resolves conflicts, retests, and waits for CI before PR `#22` is reviewed and merged. Both developers start future tasks from fresh branches based on the updated `main`.
