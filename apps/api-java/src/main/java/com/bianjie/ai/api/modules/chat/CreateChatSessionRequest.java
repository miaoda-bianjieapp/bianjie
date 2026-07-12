package com.bianjie.ai.api.modules.chat;

public record CreateChatSessionRequest(
        String modelId,
        String modelName,
        String source
) {
}
