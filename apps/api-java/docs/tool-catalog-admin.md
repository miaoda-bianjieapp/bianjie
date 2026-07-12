# Tool Catalog Management

PostgreSQL `tools` is the source of truth for tool metadata and runtime configuration.
`CatalogSeedRunner` only bootstraps a completely empty database and never overwrites
existing tool rows.

The management endpoints are enabled only when:

```yaml
bianjie:
  catalog:
    admin-enabled: true
```

The local profile enables this setting. Production should keep it disabled until
authentication and authorization are added.

## Create or update a tool

```http
PUT /api/v1/admin/tools/{toolId}
Content-Type: application/json
```

```json
{
  "name": "AI 小红书封面",
  "description": "根据主题和参考图生成小红书封面。",
  "categoryId": "image",
  "tab": "tools",
  "icon": "image",
  "tags": ["图像"],
  "route": "/tool/xiaohongshu-cover",
  "enabled": true,
  "sortOrder": 30,
  "requiresLogin": false,
  "requiresVip": false,
  "executionType": "FORM",
  "config": {
    "version": "tool-protocol-v2",
    "executor": "image-generation",
    "operation": "xiaohongshu-cover",
    "inputRequired": true,
    "inputModes": ["text", "image"],
    "acceptedFileTypes": ["jpg", "jpeg", "png", "webp"],
    "maxFiles": 2,
    "maxFileSizeMb": 12,
    "outputFormats": ["png"],
    "fields": [
      {
        "name": "size",
        "label": "图片尺寸",
        "type": "segmented",
        "required": true,
        "defaultValue": "1024x1365",
        "options": ["1024x1365", "1024x1024"]
      }
    ]
  }
}
```

The API validates the category, field definitions, executor and operation before
writing the row. Updating an existing ID replaces its metadata and config without
deleting tool run history.

## Enable or disable a tool

```http
PATCH /api/v1/admin/tools/{toolId}/status
Content-Type: application/json

{"enabled": false}
```

Enabling a tool validates that a backend executor can resolve its configuration.

## Read tools

The mobile app and management clients use the existing read endpoints:

```http
GET /api/v1/tools
GET /api/v1/tools/{toolId}
```

## Supported fields

- `text`
- `textarea`
- `number`
- `select`
- `chips`
- `segmented`
- `slider`
- `boolean`

Adding another tool in an existing capability family normally requires only a new
database row. A new executor is needed only when the underlying processing capability
does not exist yet.
