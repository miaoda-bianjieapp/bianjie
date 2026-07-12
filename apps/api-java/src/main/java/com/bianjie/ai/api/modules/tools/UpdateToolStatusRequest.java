package com.bianjie.ai.api.modules.tools;

import jakarta.validation.constraints.NotNull;

public record UpdateToolStatusRequest(@NotNull Boolean enabled) {
}
