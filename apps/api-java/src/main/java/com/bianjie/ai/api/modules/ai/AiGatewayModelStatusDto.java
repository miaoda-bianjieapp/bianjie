package com.bianjie.ai.api.modules.ai;

public record AiGatewayModelStatusDto(
        String id,
        String name,
        String provider,
        boolean defaultModel,
        boolean ready,
        boolean baseUrlConfigured,
        boolean apiKeyConfigured,
        String baseUrl,
        String model
) {
}
