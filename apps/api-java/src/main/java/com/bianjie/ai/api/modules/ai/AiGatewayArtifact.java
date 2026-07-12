package com.bianjie.ai.api.modules.ai;

public record AiGatewayArtifact(
        String id,
        String name,
        String kind,
        String type,
        String mimeType,
        long size,
        String status,
        String url,
        String base64Data
) {
}
