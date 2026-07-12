package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.tools.ToolDto;
import com.bianjie.ai.api.modules.tools.ToolExecutionType;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class PlaceholderExecutor implements ToolExecutor {

    @Override
    public boolean supports(ToolDto tool) {
        return tool.executionType() == ToolExecutionType.PLACEHOLDER;
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        return ToolExecutionResult.completed(
                "该工具当前为占位能力",
                Map.of(
                        "toolId", context.tool().id(),
                        "toolName", context.tool().name(),
                        "result", "当前 Demo 仅返回占位结果，后续可通过新增 ToolExecutor 扩展真实能力。"
                )
        );
    }
}
