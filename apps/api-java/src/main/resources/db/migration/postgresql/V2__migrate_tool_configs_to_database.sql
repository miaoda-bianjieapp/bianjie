-- Existing PostgreSQL installations previously received these definitions from
-- CatalogSeedRunner on every startup. Apply the last code-owned definitions once;
-- after this migration the tools table is the source of truth.

UPDATE tools
SET config_json = $json$
{
  "version": "tool-protocol-v2",
  "executor": "image-generation",
  "operation": "design-image",
  "inputRequired": true,
  "inputModes": ["text", "image"],
  "acceptedFileTypes": ["jpg", "jpeg", "png", "webp"],
  "maxFiles": 3,
  "maxFileSizeMb": 12,
  "outputFormats": ["png"],
  "primaryInput": {
    "label": "设计需求",
    "placeholder": "描述需要生成的画面、文案、配色和使用场景",
    "required": true,
    "minLines": 5,
    "maxLines": 8,
    "maxLength": 1000
  },
  "fields": [
    {
      "name": "style",
      "label": "设计风格",
      "type": "select",
      "required": false,
      "options": ["清爽科技感", "电商促销", "小红书封面", "教育课件", "商务海报"]
    },
    {
      "name": "size",
      "label": "图片尺寸",
      "type": "segmented",
      "required": false,
      "defaultValue": "1024x1024",
      "options": ["1024x1024", "1024x1536", "1536x1024"]
    }
  ]
}
$json$
WHERE id = 'design-image';

UPDATE tools
SET config_json = $json$
{
  "version": "tool-protocol-v2",
  "executor": "document-processing",
  "operation": "pdf-convert",
  "inputRequired": false,
  "inputModes": ["file"],
  "acceptedFileTypes": ["pdf"],
  "minFiles": 1,
  "maxFiles": 1,
  "maxFileSizeMb": 30,
  "outputFormats": ["docx", "png", "txt"],
  "fields": [
    {
      "name": "outputFormat",
      "label": "输出格式",
      "type": "segmented",
      "required": true,
      "defaultValue": "docx",
      "options": ["docx", "png", "txt"]
    },
    {
      "name": "ocrEnabled",
      "label": "扫描件 OCR",
      "type": "boolean",
      "required": false
    }
  ]
}
$json$
WHERE id = 'pdf-convert';

UPDATE tools
SET config_json = $json$
{
  "version": "tool-protocol-v2",
  "executor": "ppt-generation",
  "operation": "document-to-ppt",
  "inputRequired": false,
  "inputModes": ["file", "text"],
  "acceptedFileTypes": ["docx", "pdf", "txt", "md"],
  "minFiles": 1,
  "maxFiles": 1,
  "maxFileSizeMb": 30,
  "outputFormats": ["pptx"],
  "primaryInput": {
    "label": "补充要求",
    "placeholder": "可选：描述演示目标、重点内容和希望强调的结论",
    "required": false,
    "minLines": 3,
    "maxLines": 5,
    "maxLength": 500
  },
  "fields": [
    {
      "name": "language",
      "label": "输出语言",
      "type": "segmented",
      "required": false,
      "defaultValue": "中文",
      "options": ["中文", "English", "日本語", "한국어"]
    },
    {
      "name": "slideCount",
      "label": "页数",
      "type": "slider",
      "required": false,
      "defaultValue": 20,
      "min": 10,
      "max": 50,
      "divisions": 4
    },
    {
      "name": "detail",
      "label": "内容详细度",
      "type": "select",
      "required": false,
      "defaultValue": "严格按照参考内容",
      "options": ["精炼概括", "严格按照参考内容", "适当扩展内容"]
    },
    {
      "name": "style",
      "label": "场景",
      "type": "select",
      "required": false,
      "defaultValue": "商务简洁",
      "options": ["商务简洁", "分析报告", "教学课件", "商业计划", "演讲报告", "竞品分析"]
    }
  ]
}
$json$
WHERE id = 'document-to-ppt';
