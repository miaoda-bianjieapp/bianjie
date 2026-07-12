package com.bianjie.ai.api.modules.toolruns;

import com.bianjie.ai.api.modules.chat.ChatAttachmentDto;

import java.util.List;
import java.util.Map;

public record CreateToolRunRequest(
        String input,
        Map<String, Object> parameters,
        List<ChatAttachmentDto> attachments
) {
}

