package com.bianjie.ai.api.modules.chat;

public record ChatAttachmentDto(
        String id,
        String name,
        String kind,
        String type,
        String mimeType,
        long size,
        String status,
        String url,
        String base64Data
) {
    public ChatAttachmentDto(
            String id,
            String name,
            String kind,
            String type,
            String mimeType,
            long size,
            String status,
            String base64Data
    ) {
        this(id, name, kind, type, mimeType, size, status, null, base64Data);
    }
}
