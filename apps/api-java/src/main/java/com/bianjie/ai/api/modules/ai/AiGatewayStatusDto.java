package com.bianjie.ai.api.modules.ai;

import java.util.List;

public record AiGatewayStatusDto(
        String provider,
        boolean ready,
        boolean baseUrlConfigured,
        boolean apiKeyConfigured,
        String baseUrl,
        String defaultModelId,
        String defaultModel,
        int timeoutSeconds,
        List<AiGatewayModelStatusDto> models
) {
}
