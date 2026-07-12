package com.bianjie.ai.api.modules.tools;

import java.util.List;
import java.util.Map;

public record ToolDto(
        String id,
        String name,
        String description,
        String categoryId,
        String tab,
        String icon,
        List<String> tags,
        String route,
        boolean enabled,
        int sortOrder,
        boolean requiresLogin,
        boolean requiresVip,
        ToolExecutionType executionType,
        Map<String, Object> config
) {
}

