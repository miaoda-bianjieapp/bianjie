package com.bianjie.ai.api.modules.chat;

import java.time.Instant;
import java.util.List;

public record ChatMessageDto(
        String id,
        String sessionId,
        String role,
        String messageType,
        String content,
        String modelId,
        String modelName,
        List<ChatAttachmentDto> attachments,
        int tokenEstimate,
        Instant createdAt
) {
}
