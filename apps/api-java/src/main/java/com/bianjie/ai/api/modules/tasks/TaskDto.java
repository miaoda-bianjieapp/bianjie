package com.bianjie.ai.api.modules.tasks;

import java.time.Instant;
import java.util.Map;

public record TaskDto(
        String id,
        String type,
        String title,
        String status,
        Map<String, Object> payload,
        Instant createdAt,
        Instant updatedAt
) {
}

