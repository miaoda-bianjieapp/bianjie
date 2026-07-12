package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.ai.AiGateway;
import com.bianjie.ai.api.modules.ai.AiGatewayArtifact;
import com.bianjie.ai.api.modules.ai.AiGatewayMessage;
import com.bianjie.ai.api.modules.ai.AiGatewayRequest;
import com.bianjie.ai.api.modules.ai.AiGatewayResponse;
import com.bianjie.ai.api.modules.tools.ToolDto;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 50)
public class PromptTemplateToolExecutor implements ToolExecutor {

    private static final String EXECUTOR_ID = "llm-template";
    private static final String DEFAULT_MODEL_ID = "glm-5v-turbo";
    private static final String DEFAULT_MODEL_NAME = "GLM-5V Turbo";
    private static final Set<String> TECHNICAL_PARAMETERS = Set.of(
            "executionType",
            "source",
            "toolConfigVersion",
            "modelId",
            "modelName"
    );

    private final AiGateway aiGateway;

    public PromptTemplateToolExecutor(AiGateway aiGateway) {
        this.aiGateway = aiGateway;
    }

    @Override
    public boolean supports(ToolDto tool) {
        return EXECUTOR_ID.equals(stringConfig(tool, "executor"));
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        List<AiGatewayMessage> messages = new ArrayList<>();
        String systemPrompt = stringConfig(context.tool(), "systemPrompt");
        if (!systemPrompt.isBlank()) {
            messages.add(new AiGatewayMessage("SYSTEM", systemPrompt));
        }
        messages.add(new AiGatewayMessage("USER", userPrompt(context)));

        AiGatewayResponse response = aiGateway.complete(new AiGatewayRequest(
                "tool-run-" + context.tool().id(),
                context.userId(),
                parameter(context, "modelId", DEFAULT_MODEL_ID),
                parameter(context, "modelName", DEFAULT_MODEL_NAME),
                "",
                "single_turn_prompt_template",
                messages,
                List.of()
        ));

        Map<String, Object> output = Map.of(
                "result", response.content(),
                "finishReason", response.finishReason(),
                "tokenEstimate", response.tokenEstimate(),
                "model", parameter(context, "modelName", DEFAULT_MODEL_NAME),
                "tool", context.tool().name(),
                "artifacts", artifacts(response.artifacts())
        );
        if ("GATEWAY_ERROR".equalsIgnoreCase(response.finishReason())) {
            return ToolExecutionResult.failed("工具执行失败", output);
        }
        return ToolExecutionResult.completed("工具执行完成", output);
    }

    private String userPrompt(ToolExecutionContext context) {
        StringBuilder prompt = new StringBuilder();
        appendSection(prompt, "任务要求", stringConfig(context.tool(), "taskPrompt"));
        appendSection(prompt, "用户主要输入", context.input());

        Map<String, String> labels = fieldLabels(context.tool());
        Map<String, Object> businessParameters = new LinkedHashMap<>();
        context.parameters().forEach((name, value) -> {
            if (!TECHNICAL_PARAMETERS.contains(name) && value != null && !value.toString().isBlank()) {
                businessParameters.put(labels.getOrDefault(name, name), value);
            }
        });
        if (!businessParameters.isEmpty()) {
            prompt.append("\n补充参数：\n");
            businessParameters.forEach((label, value) -> prompt
                    .append("- ")
                    .append(label)
                    .append("：")
                    .append(formatValue(value))
                    .append('\n'));
        }

        appendSection(prompt, "输出要求", stringConfig(context.tool(), "outputInstruction"));
        return prompt.toString().trim();
    }

    private void appendSection(StringBuilder prompt, String title, String content) {
        if (content == null || content.isBlank()) {
            return;
        }
        if (!prompt.isEmpty()) {
            prompt.append('\n');
        }
        prompt.append(title).append("：\n").append(content.trim()).append('\n');
    }

    private Map<String, String> fieldLabels(ToolDto tool) {
        Object fieldsValue = tool.config().get("fields");
        if (!(fieldsValue instanceof List<?> fields)) {
            return Map.of();
        }
        Map<String, String> labels = new LinkedHashMap<>();
        for (Object fieldValue : fields) {
            if (!(fieldValue instanceof Map<?, ?> field)) {
                continue;
            }
            String name = value(field.get("name"));
            String label = value(field.get("label"));
            if (!name.isBlank()) {
                labels.put(name, label.isBlank() ? name : label);
            }
        }
        return labels;
    }

    private String formatValue(Object value) {
        if (value instanceof List<?> list) {
            return list.stream().map(this::formatValue).reduce((left, right) -> left + "、" + right).orElse("");
        }
        return value.toString();
    }

    private List<Map<String, Object>> artifacts(List<AiGatewayArtifact> artifacts) {
        if (artifacts == null || artifacts.isEmpty()) {
            return List.of();
        }
        return artifacts.stream()
                .map(artifact -> Map.<String, Object>of(
                        "id", artifact.id(),
                        "name", artifact.name(),
                        "kind", artifact.kind(),
                        "type", artifact.type(),
                        "mimeType", artifact.mimeType(),
                        "size", artifact.size(),
                        "status", artifact.status(),
                        "url", artifact.url() == null ? "" : artifact.url(),
                        "base64Data", artifact.base64Data() == null ? "" : artifact.base64Data()
                ))
                .toList();
    }

    private String parameter(ToolExecutionContext context, String name, String fallback) {
        Object value = context.parameters().get(name);
        if (value == null || value.toString().isBlank()) {
            return fallback;
        }
        return value.toString().trim();
    }

    private String stringConfig(ToolDto tool, String name) {
        return value(tool.config().get(name));
    }

    private String value(Object value) {
        return value == null ? "" : value.toString().trim();
    }
}
