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
public class PptGenerationToolExecutor implements ToolExecutor {

    private static final String EXECUTOR_ID = "ppt-generation";

    @Override
    public boolean supports(ToolDto tool) {
        return EXECUTOR_ID.equals(config(tool, "executor"));
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        Map<String, Object> output = new LinkedHashMap<>();
        output.put("taskId", "task-" + UUID.randomUUID());
        output.put("executor", EXECUTOR_ID);
        output.put("operation", config(context.tool(), "operation"));
        output.put("status", "QUEUED");
        output.put("sourceFileCount", context.attachments().size());
        output.put("slideCount", context.parameters().getOrDefault("slideCount", 12));
        output.put("language", context.parameters().getOrDefault("language", "中文"));
        output.put("style", context.parameters().getOrDefault("style", "商务简洁"));
        output.put("audience", context.parameters().getOrDefault("audience", "通用受众"));
        output.put("parameters", context.parameters());
        output.put("artifacts", List.of());
        output.put("next", "协议校验已完成，等待接入文档解析、页面编排和 PPTX 导出工作流。");
        return ToolExecutionResult.queued(
                "PPT 生成任务已创建",
                output
        );
    }

    private String config(ToolDto tool, String name) {
        Object value = tool.config().get(name);
        return value == null ? "" : value.toString().trim();
    }
}
