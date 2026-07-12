package com.bianjie.ai.api.modules.toolruns;

import java.time.Instant;
import java.util.Map;

public record ToolRunDto(
        String id,
        String toolId,
        String status,
        String input,
        Map<String, Object> parameters,
        Map<String, Object> output,
        Instant createdAt,
        Instant updatedAt
) {
}

