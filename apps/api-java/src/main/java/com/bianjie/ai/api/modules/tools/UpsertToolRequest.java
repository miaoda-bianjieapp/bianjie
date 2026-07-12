package com.bianjie.ai.api.modules.tools;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.List;
import java.util.Map;

public record UpsertToolRequest(
        @NotBlank String name,
        @NotBlank String description,
        @NotBlank String categoryId,
        @NotBlank String tab,
        @NotBlank String icon,
        @NotNull List<String> tags,
        @NotBlank String route,
        boolean enabled,
        int sortOrder,
        boolean requiresLogin,
        boolean requiresVip,
        @NotNull ToolExecutionType executionType,
        @NotNull Map<String, Object> config
) {
}
