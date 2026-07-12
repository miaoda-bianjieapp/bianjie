package com.bianjie.ai.api.modules.categories;

public record ToolCategoryDto(
        String id,
        String name,
        int count,
        String parentId,
        boolean collapsed,
        int sortOrder
) {
}

