package com.bianjie.ai.api.modules.ai;

public record AiGatewayAttachment(
        String id,
        String name,
        String kind,
        String type,
        String mimeType,
        long size,
        String status,
        String base64Data
) {
}
