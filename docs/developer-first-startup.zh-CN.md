# 开发者首次拉取项目与本地启动指南

本文面向第一次参与边界 AI 项目的开发者，说明从 GitHub 拉取代码、准备环境、配置 PostgreSQL、启动 Spring Boot 后端，到使用 Android Studio 通过 USB 启动 Flutter App 的完整流程。

后端不要求使用 IDEA。可以只使用 PowerShell、JDK 和 Maven 启动；Android Studio 是移动端开发和真机运行的统一工具。

## 一、项目结构

~~~text
E:\bianjie-workspace
├─ apps/api-java    Spring Boot Java 后端
├─ apps/app         Flutter Android 移动端
├─ docs             项目和协作文档
├─ AGENTS.md        AI 和开发者必须遵守的规范
└─ TOOL_DEVELOPMENT_BOARD.md    共享表字段模板/离线参考
~~~

前后端在同一个仓库中，但需要分别启动。

## 二、准备环境

### 2.1 版本基线

| 软件 | 版本要求 |
|---|---|
| JDK | Java 17 |
| Maven | 3.9.x，项目基线为 3.9.4 |
| Flutter | 3.24.5 stable |
| Dart | Flutter 自带 3.5.x |
| Android Studio | 安装 Flutter 和 Dart 插件 |
| Android SDK | compileSdk 35 |
| PostgreSQL | 16.x |

不要在首次启动时顺手升级 JDK、Flutter、Gradle、Kotlin、Spring Boot 或 Maven。版本升级必须单独提交任务。

### 2.2 检查命令行工具

打开 PowerShell：

~~~powershell
git --version
java -version
mvn -version
flutter --version
adb version
~~~

确认 Java 和 Maven 使用 Java 17，Flutter 是 3.24.x stable。若命令找不到，先配置 PATH，不要修改项目代码绕过环境问题。

## 三、第一次从 GitHub 拉取

### 3.1 克隆仓库

~~~powershell
git clone https://github.com/miaoda-bianjieapp/bianjie.git E:\bianjie-workspace
cd E:\bianjie-workspace
git status
~~~

如果目录已经存在，不要再次 clone：

~~~powershell
cd E:\bianjie-workspace
git switch main
git pull --ff-only origin main
git status
~~~

工作区应当干净。看到未提交修改时，先确认属于谁，禁止使用 git reset --hard 清除不明改动。

### 3.2 必读文档

~~~text
AGENTS.md
docs/developer-first-startup.zh-CN.md
docs/developer-tool-workflow.zh-CN.md
docs/administrator-workflow.zh-CN.md
共享工具开发表（链接由管理员提供）
~~~

首次启动验证可以暂时停留在 main，但不要在 main 修改业务代码或提交。正式开发工具前必须有 GitHub Issue、管理员批准和个人分支。

## 四、配置 PostgreSQL

### 4.1 创建数据库

使用 pgAdmin、DataGrip、psql 或其他 PostgreSQL 工具执行：

~~~sql
CREATE DATABASE bianjie;
~~~

连接信息通常是：

~~~text
主机：localhost
端口：5432
数据库：bianjie
用户名：你的 PostgreSQL 用户名
密码：你的 PostgreSQL 密码
~~~

不要把真实密码写入 GitHub、Issue、PR、截图或日志。

### 4.2 创建本地配置

~~~powershell
cd E:\bianjie-workspace\apps\api-java\src\main\resources
Copy-Item application-local.example.yml application-local.yml
~~~

只编辑本机的 application-local.yml。它已被 Git 忽略，不会提交到仓库。

至少确认以下内容：

~~~yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/bianjie
    username: 你的 PostgreSQL 用户名
    password: 你的 PostgreSQL 密码
  jpa:
    hibernate:
      ddl-auto: validate
  flyway:
    enabled: true

bianjie:
  catalog:
    admin-enabled: true
  ai:
    gateway:
      default-model-id: glm-5v-turbo
      models:
        - id: glm-5v-turbo
          api-key: 你的 GLM API Key
        - id: qwen-image-2.0
          api-key: 你的 DashScope API Key
~~~

模板已经包含 PostgreSQL、JPA、Flyway、工具目录、GLM 多模态模型和 Qwen Image 2.0 生图模型。不要随意删除 base-url、model、超时和排序字段。

只检查文件存在和是否被忽略，不要输出完整配置：

~~~powershell
Test-Path E:\bianjie-workspace\apps\api-java\src\main\resources\application-local.yml
git check-ignore -v E:\bianjie-workspace\apps\api-java\src\main\resources\application-local.yml
~~~

## 五、不使用 IDEA 启动后端

### 5.1 使用 Maven 启动

打开第一个 PowerShell：

~~~powershell
cd E:\bianjie-workspace\apps\api-java
mvn spring-boot:run "-Dspring-boot.run.profiles=local"
~~~

看到 Started BianjieAiApiApplication 和端口 8080 表示启动成功。第一次启动会执行 PostgreSQL Flyway 迁移，迁移期间不要关闭进程或修改 SQL。

### 5.2 验证接口

打开第二个 PowerShell：

~~~powershell
Invoke-WebRequest http://localhost:8080/api/v1/health
~~~

浏览器地址：

~~~text
健康检查：http://localhost:8080/api/v1/health
Swagger：http://localhost:8080/swagger-ui.html
AI 状态：http://localhost:8080/api/v1/ai-gateway/status
~~~

AI 状态接口不会返回 API Key 明文。

### 5.3 使用 JAR 启动

~~~powershell
cd E:\bianjie-workspace\apps\api-java
mvn package
java -jar target\api-java-0.1.0-SNAPSHOT.jar --spring.profiles.active=local
~~~

普通开发优先使用 mvn spring-boot:run，不需要每次生成 JAR。

### 5.4 其他后端工具

不使用 IDEA 也可以用 PowerShell + Maven、VS Code Java/Spring Boot 扩展、Eclipse Maven 项目或直接运行 JAR。无论工具是什么，都必须使用 profile=local、JDK 17 和端口 8080。

## 六、使用 IDEA 启动后端（可选）

1. 打开 E:\bianjie-workspace\apps\api-java。
2. 等待 Maven 依赖下载完成。
3. 项目 SDK 选择 JDK 17。
4. 运行 BianjieAiApiApplication.java。
5. 在 Run Configuration 的 Active profiles 填 local。

也可以在 VM options 填：

~~~text
-Dspring.profiles.active=local
~~~

如果 IDEA 启动后连接的是 H2，通常是没有激活 local profile。

## 七、使用 Android Studio 启动 Flutter

### 7.1 打开 Flutter 工程

Android Studio 打开：

~~~text
E:\bianjie-workspace\apps\app
~~~

不要只打开 apps/app/android，否则可能被识别成普通 Android 子项目。确认 Flutter/Dart 插件和 Flutter 3.24.5 SDK 后执行：

~~~powershell
cd E:\bianjie-workspace\apps\app
flutter pub get
~~~

### 7.2 连接 USB 手机

手机端打开开发者选项、USB 调试，用数据线连接并允许电脑调试。电脑执行：

~~~powershell
adb devices
~~~

设备状态必须是 device。unauthorized 时在手机上确认授权；没有设备时检查数据线、驱动和 USB 模式。

### 7.3 USB 真机：推荐 adb reverse

~~~powershell
adb reverse tcp:8080 tcp:8080
~~~

这会把手机的 127.0.0.1:8080 转发到电脑 localhost:8080。Android Studio Flutter Run Configuration 的 Additional run args 设置为：

~~~text
--dart-define=BIANJIE_API_BASE_URL=http://127.0.0.1:8080
~~~

也可以直接运行：

~~~powershell
cd E:\bianjie-workspace\apps\app
flutter run --dart-define=BIANJIE_API_BASE_URL=http://127.0.0.1:8080
~~~

普通 Dart/Java 修改不需要手动构建 APK。Android Studio 点击 Run 会自动编译 Debug 版本并安装到手机。

### 7.4 真机通过局域网访问

不使用 adb reverse 时，手机和电脑必须在同一 Wi-Fi。执行 ipconfig 找到电脑 IPv4，例如 192.168.1.23：

~~~powershell
flutter run --dart-define=BIANJIE_API_BASE_URL=http://192.168.1.23:8080
~~~

失败时检查 server.address: 0.0.0.0、Windows 防火墙 TCP 8080、同一局域网和路由器设备隔离。手机不能使用 localhost，因为那代表手机自己。

### 7.5 Android 模拟器

Android Studio 模拟器访问电脑通常使用：

~~~powershell
flutter run --dart-define=BIANJIE_API_BASE_URL=http://10.0.2.2:8080
~~~

| 运行方式 | API 地址 |
|---|---|
| USB 真机 + adb reverse | http://127.0.0.1:8080 |
| Android Studio 模拟器 | http://10.0.2.2:8080 |
| 真机 + 局域网 | http://电脑局域网IP:8080 |

## 八、第一次完整启动顺序

### 终端 1：后端

~~~powershell
cd E:\bianjie-workspace\apps\api-java
mvn spring-boot:run "-Dspring-boot.run.profiles=local"
~~~

### 终端 2：手机端

~~~powershell
cd E:\bianjie-workspace\apps\app
flutter pub get
adb reverse tcp:8080 tcp:8080
flutter run --dart-define=BIANJIE_API_BASE_URL=http://127.0.0.1:8080
~~~

第一次验证：

- [ ] 后端无数据库连接错误。
- [ ] Flyway 迁移成功。
- [ ] /api/v1/health 返回成功。
- [ ] AI 状态显示期望的默认模型。
- [ ] adb devices 显示 device。
- [ ] App 能安装、打开并加载首页。
- [ ] 能发送一条对话并看到回复。
- [ ] 能进入工具 Tab。
- [ ] 已配置真实模型时，测试附件、历史记录和复制功能。

## 九、常见问题

### 9.1 没有 application-local.yml

~~~powershell
Copy-Item apps\api-java\src\main\resources\application-local.example.yml apps\api-java\src\main\resources\application-local.yml
~~~

填自己的 PostgreSQL 用户名、密码和模型 Key，不要 git add 这个文件。

### 9.2 PostgreSQL 连接失败

检查 PostgreSQL 服务、数据库 bianjie、端口 5432、用户名密码、JDBC URL 和 local profile。不要把 ddl-auto 改成 create 或关闭 Flyway 来绕过错误。

### 9.3 Flyway 校验和错误

不要修改已执行的迁移文件。把完整错误交给管理员确认数据库版本；修复必须新增后续迁移。

### 9.4 AI 状态显示未配置

检查对应模型的 provider、base-url、api-key 和 model。Key 只放在本地配置，不要发给管理员；管理员只需要模型名和成功/失败结果。

### 9.5 手机无法连接后端

先确认电脑端：

~~~powershell
Invoke-WebRequest http://localhost:8080/api/v1/health
~~~

USB 真机重新执行 adb reverse tcp:8080 tcp:8080；模拟器使用 10.0.2.2；局域网真机使用电脑 IPv4 并检查防火墙。

### 9.6 Android Studio 没有设备

~~~powershell
adb kill-server
adb start-server
adb devices
~~~

仍无设备时检查手机授权、USB 调试、驱动和数据线。不要为了绕过设备问题构建发布 APK。

### 9.7 端口 8080 被占用

~~~powershell
Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
~~~

优先关闭旧后端进程。若必须换端口，同时修改 Spring Boot 端口、adb reverse 端口和 Flutter API 地址，并在 Issue/PR 说明。

## 十、启动成功后进入正式开发

启动验证完成不代表工具已经通过业务验收。正式开发必须：

~~~text
同步最新 main
-> 读取 AGENTS.md 和开发者流程
-> 让 AI 根据截图做预分析
-> 创建 Tool Development Request Issue
-> 等管理员批准并登记共享工具开发表
-> 创建个人分支
-> 开发、自动测试和 USB 真机验收
-> 创建 PR
~~~
