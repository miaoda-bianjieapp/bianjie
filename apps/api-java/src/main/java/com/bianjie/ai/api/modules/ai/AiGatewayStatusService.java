package com.bianjie.ai.api.modules.ai;

import org.springframework.stereotype.Service;

@Service
public class AiGatewayStatusService {

    private final AiGatewayProperties properties;

    public AiGatewayStatusService(AiGatewayProperties properties) {
        this.properties = properties;
    }

    public AiGatewayStatusDto status() {
        AiGatewayProperties.ModelConfig defaultModel = properties.selectModel(properties.getDefaultModelId());
        String provider = normalized(defaultModel.getProvider(), "mock");
        boolean baseUrlConfigured = hasText(defaultModel.getBaseUrl());
        boolean apiKeyConfigured = hasText(defaultModel.getApiKey());
        boolean ready = isReady(defaultModel);

        return new AiGatewayStatusDto(
                provider,
                ready,
                baseUrlConfigured,
                apiKeyConfigured,
                safeDisplayBaseUrl(defaultModel.getBaseUrl()),
                normalized(defaultModel.getId(), ""),
                normalized(defaultModel.getModel(), ""),
                Math.max(1, properties.getTimeoutSeconds()),
                properties.effectiveModels()
                        .stream()
                        .map(this::toStatus)
                        .toList()
        );
    }

    private AiGatewayModelStatusDto toStatus(AiGatewayProperties.ModelConfig model) {
        return new AiGatewayModelStatusDto(
                model.getId(),
                model.getName(),
                model.getProvider(),
                model.isDefaultModel(),
                isReady(model),
                hasText(model.getBaseUrl()),
                hasText(model.getApiKey()),
                safeDisplayBaseUrl(model.getBaseUrl()),
                model.getModel()
        );
    }

    private boolean isReady(AiGatewayProperties.ModelConfig model) {
        return switch (normalized(model.getProvider(), "mock")) {
            case "mock" -> true;
            case "openai-compatible", "glm" -> hasText(model.getBaseUrl()) && hasText(model.getApiKey());
            default -> false;
        };
    }

    private String normalized(String value, String fallback) {
        if (value == null || value.isBlank()) {
            return fallback;
        }
        return value.trim();
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }

    private String safeDisplayBaseUrl(String value) {
        if (!hasText(value)) {
            return "";
        }
        return value.trim();
    }
}
