package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.tools.ToolDto;
import com.bianjie.ai.api.modules.tools.ToolExecutionType;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Component
public class TaskMockExecutor implements ToolExecutor {

    @Override
    public boolean supports(ToolDto tool) {
        return tool.executionType() == ToolExecutionType.TASK;
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        if ("pdf-convert".equals(context.tool().id())) {
            return pdfConvertResult(context);
        }
        if ("document-to-ppt".equals(context.tool().id())) {
            return documentToPptResult(context);
        }
        return ToolExecutionResult.queued(
                "Mock 任务已进入队列",
                Map.of(
                        "taskId", "task-" + UUID.randomUUID(),
                        "status", "QUEUED",
                        "next", "后续可接入异步任务表、消息队列、PPT/PDF/OCR 等真实执行能力。"
                )
        );
    }

    private ToolExecutionResult pdfConvertResult(ToolExecutionContext context) {
        String outputFormat = stringParameter(context, "outputFormat", "docx");
        boolean ocrEnabled = booleanParameter(context, "ocrEnabled");
        Map<String, Object> output = new HashMap<>();
        output.put("taskId", "task-" + UUID.randomUUID());
        output.put("status", "QUEUED");
        output.put("targetFormat", outputFormat);
        output.put("ocrEnabled", ocrEnabled);
        output.put("summary", "已创建 PDF 转换任务，目标格式为 " + outputFormat + "。");
        output.put("next", "后续接入文件上传、PDF 解析、OCR 和转换产物下载。");
        return ToolExecutionResult.queued("PDF 转换任务已创建", output);
    }

    private ToolExecutionResult documentToPptResult(ToolExecutionContext context) {
        String style = stringParameter(context, "style", "商务简洁");
        String audience = stringParameter(context, "audience", "通用受众");
        Object slideCount = context.parameters().getOrDefault("slideCount", 12);
        Map<String, Object> output = new HashMap<>();
        output.put("taskId", "task-" + UUID.randomUUID());
        output.put("status", "QUEUED");
        output.put("slideCount", slideCount);
        output.put("style", style);
        output.put("audience", audience);
        output.put("summary", "已创建 " + slideCount + " 页「" + style + "」风格 PPT 生成任务。");
        output.put("next", "后续接入文档解析、大纲生成、版式模板和 PPTX 导出。");
        return ToolExecutionResult.queued("文档生成 PPT 任务已创建", output);
    }

    private String stringParameter(ToolExecutionContext context, String key, String fallback) {
        Object value = context.parameters().get(key);
        if (value == null || value.toString().isBlank()) {
            return fallback;
        }
        return value.toString();
    }

    private boolean booleanParameter(ToolExecutionContext context, String key) {
        Object value = context.parameters().get(key);
        if (value instanceof Boolean booleanValue) {
            return booleanValue;
        }
        return Boolean.parseBoolean(String.valueOf(value));
    }
}
