# 后端第一阶段架构说明

## 目标

当前 Java 后端先作为 App demo 的配置中心和任务入口，不直接实现真实 AI、PDF、PPT、股票行情等重能力。

第一阶段职责：

- 工具目录配置。
- 分类、Prompt、模型、Agent 模板、股票快捷能力。
- 用户与会员 mock 状态。
- 通用任务与工具执行记录。
- ToolExecutor 扩展机制。

## 路径

```text
code/apps/app       # Flutter App
code/apps/api-java  # Java 后端
```

## 模块

```text
common        统一响应、异常处理
config        Swagger/OpenAPI 配置
catalog       第一阶段 mock 数据聚合服务
health        健康检查
tools         工具目录
categories    工具分类
prompts       推荐 Prompt
models        AI 模型
agents        Agent 模板
stock         股票工作台 mock
users         用户信息与签到
membership    会员占位
tasks         通用任务
toolruns      工具执行记录
executors     工具执行器注册机制
```

## 开闭原则

工具执行统一经过：

```text
ToolRunController
  -> ToolRunService
    -> ToolExecutorRegistry
      -> ToolExecutor
```

后续新增真实能力时，优先新增 executor：

```text
PdfSummaryExecutor
PptGenerateExecutor
ImageGenerateExecutor
StockAnalyzeExecutor
```

不要把具体功能写成 controller 里的 `if toolId == ...` 分支。

## 当前验证

```powershell
cd E:\边界app\code\apps\api-java
mvn test
```

## 阶段 2 数据库化

阶段 2 已将阶段 1 的内存 mock 数据迁移到 H2/JPA：

```text
Entity
  -> Repository
  -> CatalogSeedRunner
  -> Catalog service
  -> Controller
```

当前开发期使用：

```yaml
spring.datasource.url: jdbc:h2:mem:bianjie_ai
spring.jpa.hibernate.ddl-auto: update
```

后续切 PostgreSQL 时，优先替换 datasource 配置，并将 `StringListConverter` 里的逗号分隔字段升级为 JSONB 或独立关联表。

接口文档：

```text
http://localhost:8080/swagger-ui.html
```
