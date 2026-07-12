package com.bianjie.ai.api.modules.ai;

import java.util.List;
import java.util.Map;

public record AiGatewayResponse(
        String content,
        int tokenEstimate,
        String finishReason,
        Map<String, Object> metadata,
        List<AiGatewayArtifact> artifacts
) {
    public AiGatewayResponse(
            String content,
            int tokenEstimate,
            String finishReason,
            Map<String, Object> metadata
    ) {
        this(content, tokenEstimate, finishReason, metadata, List.of());
    }
}
