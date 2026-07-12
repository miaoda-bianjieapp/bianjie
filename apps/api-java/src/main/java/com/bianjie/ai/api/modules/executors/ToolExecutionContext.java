package com.bianjie.ai.api.modules.executors;

import com.bianjie.ai.api.modules.ai.AiGatewayAttachment;
import com.bianjie.ai.api.modules.tools.ToolDto;

import java.util.List;
import java.util.Map;

public record ToolExecutionContext(
        ToolDto tool,
        String userId,
        String input,
        Map<String, Object> parameters,
        List<AiGatewayAttachment> attachments
) {
}

