package com.bianjie.ai.api.modules.chat;

import java.time.Instant;

public record ChatSessionDto(
        String id,
        String title,
        String modelId,
        String modelName,
        String summary,
        String contextPolicy,
        int messageCount,
        boolean needsCompression,
        Instant createdAt,
        Instant updatedAt
) {
}
