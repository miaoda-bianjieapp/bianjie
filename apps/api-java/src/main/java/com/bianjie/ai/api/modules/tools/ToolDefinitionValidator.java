package com.bianjie.ai.api.modules.tools;

import com.bianjie.ai.api.modules.executors.ToolExecutorRegistry;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Component
public class ToolDefinitionValidator {

    private static final Set<String> FIELD_TYPES = Set.of(
            "text", "textarea", "number", "select", "chips", "segmented", "slider", "boolean"
    );
    private static final Set<String> OPERATION_EXECUTORS = Set.of(
            "image-generation", "document-processing", "ppt-generation", "workflow", "external-api"
    );

    private final ToolExecutorRegistry executorRegistry;

    public ToolDefinitionValidator(ToolExecutorRegistry executorRegistry) {
        this.executorRegistry = executorRegistry;
    }

    public void validate(ToolDto tool) {
        Map<String, Object> config = tool.config() == null ? Map.of() : tool.config();
        validateFields(config);

        String executor = stringValue(config.get("executor"));
        if (tool.enabled() && tool.executionType() != ToolExecutionType.PLACEHOLDER && executor.isBlank()) {
            throw new IllegalArgumentException("可运行工具必须配置 executor");
        }
        if (OPERATION_EXECUTORS.contains(executor) && stringValue(config.get("operation")).isBlank()) {
            throw new IllegalArgumentException(executor + " 必须配置 operation");
        }
        if (tool.enabled()) {
            try {
                executorRegistry.resolve(tool);
            } catch (IllegalStateException exception) {
                throw new IllegalArgumentException("没有可处理 executor 的后端执行器: " + executor, exception);
            }
        }
    }

    private void validateFields(Map<String, Object> config) {
        Object value = config.get("fields");
        if (value != null && !(value instanceof List<?>)) {
            throw new IllegalArgumentException("fields 必须是数组");
        }
        Set<String> names = new HashSet<>();
        for (Object item : value instanceof List<?> values ? values : List.of()) {
            if (!(item instanceof Map<?, ?> field)) {
                throw new IllegalArgumentException("fields 中的字段必须是对象");
            }
            String name = stringValue(field.get("name"));
            String type = stringValue(field.get("type"));
            if (name.isBlank()) {
                throw new IllegalArgumentException("字段 name 不能为空");
            }
            if (!names.add(name)) {
                throw new IllegalArgumentException("字段 name 不能重复: " + name);
            }
            if (!FIELD_TYPES.contains(type)) {
                throw new IllegalArgumentException("不支持的字段类型: " + type);
            }
            if (Set.of("select", "chips", "segmented").contains(type)) {
                Object options = field.get("options");
                if (!(options instanceof List<?> optionValues) || optionValues.isEmpty()) {
                    throw new IllegalArgumentException(name + " 必须配置非空 options");
                }
            }
        }
    }

    private String stringValue(Object value) {
        return value == null ? "" : value.toString().trim();
    }
}
