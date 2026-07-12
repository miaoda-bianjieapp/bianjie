package com.bianjie.ai.api.modules.chat;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

@Entity
@Table(name = "chat_sessions")
public class ChatSessionEntity {

    @Id
    private String id;

    private String userId;

    private String title;

    private String modelId;

    private String modelName;

    @Column(columnDefinition = "TEXT")
    private String summary;

    private String contextPolicy;

    private int messageCount;

    private boolean needsCompression;

    private Instant createdAt;

    private Instant updatedAt;

    protected ChatSessionEntity() {
    }

    public ChatSessionEntity(
            String id,
            String userId,
            String title,
            String modelId,
            String modelName,
            String summary,
            String contextPolicy,
            int messageCount,
            boolean needsCompression,
            Instant createdAt,
            Instant updatedAt
    ) {
        this.id = id;
        this.userId = userId;
        this.title = title;
        this.modelId = modelId;
        this.modelName = modelName;
        this.summary = summary;
        this.contextPolicy = contextPolicy;
        this.messageCount = messageCount;
        this.needsCompression = needsCompression;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public String getModelId() {
        return modelId;
    }

    public String getModelName() {
        return modelName;
    }

    public String getSummary() {
        return summary;
    }

    public String getContextPolicy() {
        return contextPolicy;
    }

    public int getMessageCount() {
        return messageCount;
    }

    public boolean isNeedsCompression() {
        return needsCompression;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void updateModel(String modelId, String modelName) {
        this.modelId = modelId;
        this.modelName = modelName;
    }

    public void updateTitle(String title) {
        this.title = title;
    }

    public void incrementMessageCount(int delta) {
        this.messageCount += delta;
    }

    public void markNeedsCompression(String summary) {
        this.needsCompression = true;
        this.summary = summary;
    }

    public void touch(Instant updatedAt) {
        this.updatedAt = updatedAt;
    }

    public ChatSessionDto toDto() {
        return new ChatSessionDto(
                id,
                title,
                modelId,
                modelName,
                summary,
                contextPolicy,
                messageCount,
                needsCompression,
                createdAt,
                updatedAt
        );
    }
}
