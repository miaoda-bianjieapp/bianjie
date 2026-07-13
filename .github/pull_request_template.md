## Scope / 开发范围

- Task Issue / 任务 Issue: Closes #
- Developer / 开发者:
- Branch / 个人分支:
- Tab and category / Tab 与分类:
- Tools and `toolId` / 工具与 ID:
- Executor and operations / 执行器与 operation:
- Capability status / 能力状态: real / partial / placeholder

## Reference Screenshots / 对标截图

- Reference screenshots / 对标截图:
- Implemented interactions / 已实现交互:
- Intentional differences / 主动调整及原因:

## Changes / 修改内容

- Flutter:
- Backend:
- API contract and mocks / API 契约与 mock:
- History and artifacts / 历史记录与附件:

## Database / 数据库

- Schema or data migration required / 是否涉及迁移: no / yes
- Flyway file / Flyway 文件:
- Tables, columns, indexes, constraints / 表、字段、索引、约束:
- Existing migrations modified / 是否修改旧迁移: no

## Verification / 验证

- [ ] `mvn test`
- [ ] `mvn package`
- [ ] `dart format --output=none --set-exit-if-changed lib test`
- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Android Studio USB device test / Android Studio 真机测试

Device scenarios / 真机场景：

- Success / 成功:
- Failure or boundary / 失败或边界:
- Copy, artifact, and history replay / 复制、附件、历史回看:
- Existing feature regression / 原有功能回归:

## Security / 安全

- [ ] No API keys, passwords, tokens, local configuration, Base64 payloads, or user data are included.
- [ ] No generated files, APKs, `build/`, `target/`, or IDE metadata are included.
- [ ] External calls have timeout and safe error handling where applicable.

## Limitations / 剩余限制

- Remaining work / 后续工作:
- Known limitations / 已知限制:

## Administrator Checklist / 管理员检查

- [ ] Task is registered in the administrator's shared tool development table.
- [ ] `toolId`, executor/operation, and shared-file ownership match the approved Issue.
- [ ] Branch is synchronized with the latest `main` after earlier PRs were merged.
- [ ] Required CI checks pass after the final synchronization.
- [ ] Flyway filename/version is approved and no locked migration changed.
- [ ] Core workflow was reviewed or sampled on a device.
