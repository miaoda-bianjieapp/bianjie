package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.tools.ToolDto;
import com.bianjie.ai.api.modules.tools.ToolExecutionType;
import org.springframework.stereotype.Component;

import java.util.Map;

@Component
public class ChatMockExecutor implements ToolExecutor {

    @Override
    public boolean supports(ToolDto tool) {
        return tool.executionType() == ToolExecutionType.CHAT
                || tool.executionType() == ToolExecutionType.FORM;
    }

    @Override
    public ToolExecutionResult run(ToolExecutionContext context) {
        return ToolExecutionResult.completed(
                "Mock 对话已完成",
                Map.of(
                        "input", context.input(),
                        "parameters", context.parameters(),
                        "summary", "已通过 " + context.tool().name() + " 生成模拟结果，后续可替换为真实 AI Gateway。"
                )
        );
    }
}
