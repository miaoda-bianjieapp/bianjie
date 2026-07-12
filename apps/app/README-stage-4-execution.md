# Stage 4 Tool Execution

The Flutter app now has a unified execution repository.

## Default Behavior

By default, the app still runs without the backend and creates local mock tool-run results.

```text
BIANJIE_USE_REMOTE_API=false
```

## Remote Behavior

When remote API is enabled, the tool runner page calls:

```text
POST /api/v1/tools/{toolId}/runs
```

The returned run is displayed with:

```text
run id
tool name
status
output
```

## Files

```text
lib/shared/models/tool_run.dart
lib/shared/models/task.dart
lib/shared/data/tool_execution_repository.dart
lib/shared/providers/tool_execution_providers.dart
lib/features/tool_runner/presentation/tool_runner_page.dart
```
