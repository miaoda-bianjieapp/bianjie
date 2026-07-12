# 边界 AI App Demo

Flutter 移动端 demo 工程，当前阶段聚焦六个核心 Tab、统一主题、路由骨架和后续 mock/API 接入边界。

## 运行前置

1. 安装 Flutter SDK，并在 Android Studio 中配置 Flutter 插件。
2. 在本目录执行 `flutter pub get`。
3. 手机连接电脑并开启 USB 调试后，执行 `flutter run`。

## Windows 中文路径说明

当前仓库路径包含中文目录名，Android/Flutter 的部分构建工具在 Windows 下会把路径编码成乱码。建议开发和运行时使用虚拟盘符打开工程：

```powershell
subst B: E:\边界app
cd B:\code\apps\app
flutter pub get
flutter run
```

Android Studio 也建议打开 `B:\code\apps\app`。

已验证 `flutter analyze`、`flutter test` 和 `flutter build apk --debug` 可通过。
