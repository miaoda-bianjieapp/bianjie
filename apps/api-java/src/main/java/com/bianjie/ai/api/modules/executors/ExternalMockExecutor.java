package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.tools.ToolDto;
import com.bianjie.ai.api.modules.tools.ToolExecutionType;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class ExternalMockExecutor implements ToolExecutor {

    @Override
    public boolean supports(ToolDto tool) {
        return tool.executionType() == ToolExecutionType.EXTERNAL;
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        return ToolExecutionResult.completed(
                "外部工具跳转已生成",
                Map.of("url", context.tool().route())
        );
    }
}
