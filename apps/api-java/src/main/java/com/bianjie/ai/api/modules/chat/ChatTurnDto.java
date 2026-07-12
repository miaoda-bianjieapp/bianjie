package com.bianjie.ai.api.modules.chat;

public record ChatTurnDto(
        ChatSessionDto session,
        ChatMessageDto userMessage,
        ChatMessageDto assistantMessage
) {
}
