# Backend Stage 4

## Goal

Stage 4 makes every tool execution go through one backend entry point and leaves a queryable run record.

## Delivered

- `POST /api/v1/tools/{toolId}/runs`
- `GET /api/v1/tool-runs/{runId}`
- `POST /api/v1/tasks`
- `GET /api/v1/tasks/{taskId}`
- `ToolExecutor`
- `ToolExecutorRegistry`
- `PlaceholderExecutor`
- `ChatMockExecutor`
- `TaskMockExecutor`
- `ExternalMockExecutor`
- JPA persistence for tool runs and tasks

## Design

Controllers only create or read records. Actual tool behavior is selected by `ToolExecutorRegistry`.

To add a new ability later:

1. Add or update a tool with a matching `executionType`.
2. Implement a new `ToolExecutor`.
3. Register it as a Spring component.

No controller changes are needed for normal extension.

## Current Limits

- Executors still return mock results.
- Long-running jobs are represented as `QUEUED`, but no real background worker is attached yet.
- Output and payload are stored as JSON text for quick iteration. This can later move to JSONB in PostgreSQL.
