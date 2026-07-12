package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.tools.ToolDto;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 100)
public class DocumentProcessingToolExecutor implements ToolExecutor {

    private static final String EXECUTOR_ID = "document-processing";

    @Override
    public boolean supports(ToolDto tool) {
        return EXECUTOR_ID.equals(config(tool, "executor"));
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        String operation = config(context.tool(), "operation");
        String outputFormat = parameter(context, "outputFormat", firstOutputFormat(context.tool()));
        Map<String, Object> output = new LinkedHashMap<>();
        output.put("taskId", "task-" + UUID.randomUUID());
        output.put("executor", EXECUTOR_ID);
        output.put("operation", operation);
        output.put("status", "QUEUED");
        output.put("sourceFileCount", context.attachments().size());
        output.put("targetFormat", outputFormat);
        output.put("ocrEnabled", booleanParameter(context, "ocrEnabled"));
        output.put("parameters", context.parameters());
        output.put("artifacts", List.of());
        output.put("next", "协议校验已完成，等待接入对应的文档处理引擎。");
        return ToolExecutionResult.queued(
                "文档处理任务已创建",
                output
        );
    }

    private String firstOutputFormat(ToolDto tool) {
        Object value = tool.config().get("outputFormats");
        if (value instanceof List<?> values && !values.isEmpty()) {
            return values.get(0).toString();
        }
        return "file";
    }

    private String parameter(ToolExecutionContext context, String name, String fallback) {
        Object value = context.parameters().get(name);
        return value == null || value.toString().isBlank() ? fallback : value.toString();
    }

    private boolean booleanParameter(ToolExecutionContext context, String name) {
        Object value = context.parameters().get(name);
        return value instanceof Boolean bool ? bool : Boolean.parseBoolean(String.valueOf(value));
    }

    private String config(ToolDto tool, String name) {
        Object value = tool.config().get(name);
        return value == null ? "" : value.toString().trim();
    }
}
