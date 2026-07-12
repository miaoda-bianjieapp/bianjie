package com.bianjie.ai.api.modules.agents;

public record AgentTemplateDto(
        String id,
        String title,
        String coverIcon,
        String category,
        String prompt,
        String description
) {
}

