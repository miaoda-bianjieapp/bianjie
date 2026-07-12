package com.bianjie.ai.api.modules.chat;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

@Entity
@Table(name = "chat_messages")
public class ChatMessageEntity {

    @Id
    private String id;

    private String sessionId;

    private String role;

    private String messageType = "TEXT";

    @Column(columnDefinition = "TEXT")
    private String content;

    private String modelId;

    private String modelName;

    @Column(columnDefinition = "TEXT")
    private String attachmentsJson;

    private int tokenEstimate;

    private Instant createdAt;

    protected ChatMessageEntity() {
    }

    public ChatMessageEntity(
            String id,
            String sessionId,
            String role,
            String messageType,
            String content,
            String modelId,
            String modelName,
            String attachmentsJson,
            int tokenEstimate,
            Instant createdAt
    ) {
        this.id = id;
        this.sessionId = sessionId;
        this.role = role;
        this.messageType = messageType == null || messageType.isBlank() ? "TEXT" : messageType;
        this.content = content;
        this.modelId = modelId;
        this.modelName = modelName;
        this.attachmentsJson = attachmentsJson;
        this.tokenEstimate = tokenEstimate;
        this.createdAt = createdAt;
    }

    public String getId() {
        return id;
    }

    public String getSessionId() {
        return sessionId;
    }

    public String getRole() {
        return role;
    }

    public String getMessageType() {
        return messageType == null || messageType.isBlank() ? "TEXT" : messageType;
    }

    public String getContent() {
        return content;
    }

    public String getModelId() {
        return modelId;
    }

    public String getModelName() {
        return modelName;
    }

    public String getAttachmentsJson() {
        return attachmentsJson;
    }

    public int getTokenEstimate() {
        return tokenEstimate;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
