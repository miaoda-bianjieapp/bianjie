package com.bianjie.ai.api.modules.models;

public record AiModelDto(
        String id,
        String name,
        String description,
        boolean isDefault
) {
}

