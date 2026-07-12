package com.bianjie.ai.api.modules.chat;

import jakarta.validation.constraints.NotBlank;

import java.util.List;

public record SendChatMessageRequest(
        @NotBlank String content,
        String messageType,
        String modelId,
        String modelName,
        List<ChatAttachmentDto> attachments,
        String source
) {
}
