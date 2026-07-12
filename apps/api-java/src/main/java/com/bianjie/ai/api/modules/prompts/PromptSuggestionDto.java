package com.bianjie.ai.api.modules.prompts;

public record PromptSuggestionDto(
        String id,
        String text,
        String target,
        String icon,
        String scenario
) {
}

