package com.bianjie.ai.api.modules.ai;

import java.util.List;

public record AiGatewayRequest(
        String sessionId,
        String userId,
        String modelId,
        String modelName,
        String summary,
        String contextPolicy,
        List<AiGatewayMessage> messages,
        List<AiGatewayAttachment> attachments
) {
}
