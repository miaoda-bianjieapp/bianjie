# 工具开发者完整协作流程

本文面向参与“功能”和“写作”工具开发的同事，说明从获取项目到发起 Pull Request（PR）的完整流程。架构约束以根目录 `AGENTS.md` 为准；本文负责说明实际操作方法和可直接交给 AI 的提示词。

仓库管理员的 Issue 审批、任务登记、PR Review、CI、Flyway、真机抽测和合并流程见 `docs/administrator-workflow.zh-CN.md`。
## 一、先理解四个协作对象

| 对象 | 用途 | 谁负责 |
|---|---|---|
| `AGENTS.md` | AI 和开发者必须遵守的架构、测试、安全和 Git 规范 | 所有人阅读，管理员维护 |
| Tool Development Request Issue | 开发前的任务申请和架构预分析结果 | 开发者创建，管理员批准 |
| `TOOL_DEVELOPMENT_BOARD.md` | 已批准任务、负责人、分支和公共文件占用登记 | 管理员维护 |
| Pull Request | 开发完成后的代码审查、CI 和合并申请 | 开发者创建，管理员审查合并 |

Issue 是“准备开发什么”，PR 是“实际完成了什么”。两者不能互相替代。

## 二、首次获取项目

每台开发电脑只需要克隆一次：

```powershell
git clone https://github.com/miaoda-bianjieapp/bianjie.git
cd bianjie
git status
```

开发者还需要自行准备以下本地环境：

- Flutter `3.24.5` 和配套 Dart `3.5.x`。
- Android Studio、Android SDK 35，以及可通过 USB 运行 App 的手机。
- JDK 17 和 Maven 3.9.x。
- PostgreSQL 16.x（工具确实需要数据库联调时）。
- 本机忽略的 `application-local.yml`，其中配置个人数据库和模型密钥。

禁止通过聊天、Issue、PR 或 Git 提交 API Key、密码和 `application-local.yml`。

## 三、每个新任务先同步 main

已经克隆过项目时，不要重复克隆。开始每个新任务前执行：

```powershell
git switch main
git pull --ff-only origin main
git status
```

此时先不要创建功能分支，也不要让 AI 编码。先完成需求和架构预分析。

如果 `git status` 显示未提交修改，停止切换和拉取操作，先确认这些修改属于谁。禁止使用 `git reset --hard` 清除不明改动。

## 四、把截图和需求交给 AI 做预分析

开发者不需要一开始就知道 executor、operation、公共文件和 Flyway。正确流程是：让 AI 读取截图、`AGENTS.md` 和实际代码，只做分析并生成 Issue 草稿；管理员负责最终确认。

将对标产品详情页截图放入 AI 对话，并使用下面的提示词：

```text
你正在协助开发边界 AI 项目的新工具。请先读取仓库根目录 AGENTS.md、
TOOL_DEVELOPMENT_BOARD.md，以及与工具目录、动态表单、ToolExecutor、
ToolExecutorRegistry、历史记录和附件相关的现有代码。

我提供了对标产品截图。本阶段只做需求拆解和架构预分析，禁止修改文件、
禁止编码、禁止创建提交。

请完成：
1. 区分截图明确事实、合理推断和仍需确认的问题；
2. 列出工具名称、目标 Tab、分类、输入字段、参数、附件限制、输出和状态；
3. 判断复用哪个现有能力族 executor，还是确实需要新能力族，并说明依据；
4. 为每个工具建议稳定 toolId 和 operation；
5. 列出预计修改的前端、后端、协议、历史附件和公共文件；
6. 判断是否需要数据库结构或配置数据迁移；
7. 给出可测试的验收标准和风险；
8. 按 GitHub “工具开发申请 / Tool Development Request”表单字段，输出一份
   可以直接填写的中文 Issue 草稿。

不知道的内容必须写“待 AI/管理员确认”，不得编造。一次最多分析 3 个同能力族工具。
```

AI 的结论只是建议，不是批准。如果 AI 判断需要新执行器、新表、共享协议变化或专用 Flutter 页面，Issue 中必须醒目标注，等待管理员审查。

## 五、创建工具申请 Issue

进入 GitHub 仓库：

```text
Issues -> New issue -> 工具开发申请 / Tool Development Request
```

把 AI 生成的草稿填写进去，并上传已遮挡账号、手机号、Key 和隐私内容的截图。字段填写原则：

- 能确定的 `toolId`、executor 和 operation 填 AI 建议值。
- 无法确定的架构字段填“待 AI/管理员确认”，不要猜。
- 验收标准必须描述可观察结果，例如附件能打开、保存、历史回看，而不是只写“功能完成”。
- Issue 创建后不得立即编码，等待管理员回复批准结果。

管理员会确认任务范围，并在 `TOOL_DEVELOPMENT_BOARD.md` 登记任务 ID、负责人、个人分支、executor/operation、公共文件和 Flyway 占用。管理员可能要求补充截图、拆分超过 3 个工具的范围或调整架构。

## 六、管理员批准后创建个人分支

管理员在 Issue 中给出分支名后执行：

```powershell
git switch main
git pull --ff-only origin main
git switch -c dev/<姓名>/<简短主题>
git status
```

例如：

```powershell
git switch -c dev/zhangsan/pdf-tools
```

一个任务使用一个个人分支。禁止在 `main` 上开发或提交。

## 七、让 AI 按批准后的 Issue 开发

把 Issue 链接、截图和管理员批准意见交给 AI，使用下面的提示词：

```text
请开发 GitHub Issue #<编号> 中已由管理员批准的工具。

开始前必须：
1. 读取 AGENTS.md、该 Issue 的最终内容和管理员批准意见；
2. 检查当前 Git 分支，确认不是 main；
3. 检查 git status，保护已有修改；
4. 对照 TOOL_DEVELOPMENT_BOARD.md，确认 toolId、负责人、分支、
   executor/operation 和公共文件占用一致；
5. 先向我汇报本次最多 3 个工具的清单、复用能力族和预计共享修改。

实现时优先复用统一工具协议、动态工具页面、现有 executor、tool_runs、
artifact 和历史记录。不得为普通配置差异复制 Controller、Service、Entity 或页面。
不得开发股票、智能体、登录、积分、支付或 VIP。不得提交密钥、本地配置、
构建产物和用户数据。

完成后运行 AGENTS.md 要求的相关自动测试，但不要构建 APK；由我通过
Android Studio 和 USB 手机完成人工验收。不要自行 commit、push 或创建 PR，
除非我明确授权。
```

开发过程中，AI 如果发现批准的 executor/operation 不适用、必须新增表或需要占用未登记的公共文件，应停止扩大范围，在原 Issue 中请求管理员重新确认。

## 八、开发者自己验收

AI 完成后，开发者不能只看“编译通过”。至少检查：

1. `git diff` 只包含本任务内容，没有密钥和本机文件。
2. 后端变更运行 `mvn test` 和 `mvn package`。
3. Flutter 变更运行格式检查、`flutter analyze` 和 `flutter test`。
4. 在 IDEA 启动后端，在 Android Studio 通过 USB 启动 App。
5. 验证正确 Tab、字段校验、成功结果、失败提示和边界输入。
6. 验证文本可复制，附件可打开/保存，退出后可从历史记录回看。
7. 验证首页对话和其他已实现工具没有明显回归。

可让 AI 做提交前审查：

```text
请对当前未提交改动进行提交前审查，不要修改文件。
以 AGENTS.md 和已批准的 Issue #<编号> 为准，重点检查：
- 是否超出批准范围或超过 3 个工具；
- executor/operation 和统一协议是否正确复用；
- 前后端字段、mock、历史记录和 artifact 是否一致；
- 数据库变化是否有新的 Flyway 迁移，是否误改旧迁移；
- 是否包含密钥、本地配置、Base64、build、target、APK 或 IDE 文件；
- 自动测试和手机人工验收还缺什么。
先按严重程度列出问题；无问题时明确说明剩余风险。
```

## 九、提交并推送个人分支

确认改动后执行：

```powershell
git status
git diff
git add <本任务文件>
git diff --cached
git commit -m "feat(tools): add <工具能力>"
git push -u origin dev/<姓名>/<简短主题>
```

不要习惯性使用 `git add .`。应明确暂存本任务文件，并在提交前查看 `git diff --cached`。

如果开发期间其他 PR 已合并，管理员可能要求先同步最新 `main`。此时按照管理员指定方式处理冲突，不要自行强推共享分支。

## 十、创建 Pull Request

推送后，GitHub 通常会显示 `Compare & pull request`。也可以进入：

```text
Pull requests -> New pull request
base: main
compare: 你的个人分支
```

选择好两个分支后，点击 `Create pull request` 进入真正的 PR 编辑页。此时描述框才会自动出现 `.github/pull_request_template.md` 的内容。

PR 模板与 Issue 模板不同：它不会显示成一个单独可选的“合并申请模板”入口。如果只是打开 Pull requests 列表，或者尚未选择 base/compare 分支，就看不到模板。

PR 标题建议使用：

```text
feat(tools): add PDF merge and split
```

让 AI 根据真实改动生成 PR 描述时，可以使用：

```text
请读取 GitHub Issue #<编号>、AGENTS.md、当前分支相对 origin/main 的完整 diff
和测试结果。不要修改代码。

请严格按照 .github/pull_request_template.md 生成中文 PR 描述：
- 准确填写工具、Tab、分类、toolId、executor 和 operation；
- 分别说明 Flutter、后端、API、历史附件和数据库变化；
- 只勾选确实执行并通过的测试，未执行的保持未勾选并说明原因；
- 写明 Android Studio USB 真机的成功、失败和回归场景；
- 列出 Flyway 文件、限制和后续工作；
- 使用 Closes #<编号> 关联并在合并后关闭 Issue；
- 不得包含密钥、隐私数据、完整供应商响应或 Base64。
```

## 十一、等待 CI 和处理审查

PR 创建后 GitHub 自动运行：

- `Backend CI result`
- `Flutter CI result`
- `Secrets, generated files, and Flyway rules`

红色表示必须修复，黄色表示运行中，绿色表示通过。开发者应在同一个个人分支修复、提交并 push，PR 会自动更新，不要重复创建 PR。

管理员会审查架构、代码、数据库和验收结果。收到修改意见后，在同一分支继续修改；不要点击关闭 PR，也不要直接向 `main` 推送。

## 十二、合并后的动作

管理员在审批和 CI 全部通过后执行 Squash Merge。GitHub 可自动删除远程个人分支。开发者开始下一个任务前执行：

```powershell
git switch main
git pull --ff-only origin main
git branch -D dev/<姓名>/<已合并主题>
```

执行 `-D` 前必须先在 GitHub 确认 PR 状态为 `Merged`，并确认最新 `main` 已包含该 PR。项目采用 Squash Merge，原个人分支提交不会原样成为 `main` 的祖先，因此安全删除参数 `-d` 可能拒绝删除；这里的 `-D` 只用于删除已经确认合并的本地旧分支，不会删除 `main` 中的代码、远程仓库内容或 GitHub PR 历史。未合并或无法确认的分支禁止强制删除。下一个任务重新从最新 `main` 创建新分支，不复用旧分支。

## 十三、最短流程清单

```text
同步 main
-> AI 读取截图、规范和代码，只生成架构预分析与 Issue 草稿
-> 创建 Tool Development Request Issue
-> 管理员批准并登记 Board
-> 从最新 main 创建个人分支
-> AI 按批准范围开发
-> 自动测试 + 开发者 USB 真机测试
-> 提交并推送个人分支
-> 创建 PR（描述框自动加载 PR 模板）
-> CI + 管理员审查
-> 修复仍推送同一分支
-> 管理员 Squash Merge
-> 所有人同步最新 main
```
