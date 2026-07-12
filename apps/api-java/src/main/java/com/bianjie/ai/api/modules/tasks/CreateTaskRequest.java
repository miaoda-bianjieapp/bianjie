package com.bianjie.ai.api.modules.tasks;

import jakarta.validation.constraints.NotBlank;

import java.util.Map;

public record CreateTaskRequest(
        @NotBlank String type,
        @NotBlank String title,
        Map<String, Object> payload
) {
}

