# Stage 3 API Integration

The Flutter app still uses local mock data by default. Stage 3 adds the remote API client, JSON parsing, and Riverpod providers so screens can be migrated one by one.

## Default

No backend is required:

```text
BIANJIE_USE_REMOTE_API=false
```

## Enable Remote API

When running on a physical Android phone, use the LAN IP address of your computer, not `localhost`.

Example:

```powershell
flutter run --dart-define=BIANJIE_USE_REMOTE_API=true --dart-define=BIANJIE_API_BASE_URL=http://192.168.1.10:8080
```

When running on the Android emulator, this default usually works:

```text
http://10.0.2.2:8080
```

## Added Files

```text
lib/core/config/api_config.dart
lib/shared/data/remote_catalog_repository.dart
lib/shared/providers/remote_data_providers.dart
```
