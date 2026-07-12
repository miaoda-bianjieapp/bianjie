package com.bianjie.ai.api.modules.tasks;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

@Entity
@Table(name = "tasks")
public class TaskEntity {

    @Id
    private String id;

    private String type;

    private String title;

    private String status;

    @Column(columnDefinition = "TEXT")
    private String payloadJson;

    private Instant createdAt;

    private Instant updatedAt;

    protected TaskEntity() {
    }

    public TaskEntity(
            String id,
            String type,
            String title,
            String status,
            String payloadJson,
            Instant createdAt,
            Instant updatedAt
    ) {
        this.id = id;
        this.type = type;
        this.title = title;
        this.status = status;
        this.payloadJson = payloadJson;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() {
        return id;
    }

    public String getType() {
        return type;
    }

    public String getTitle() {
        return title;
    }

    public String getStatus() {
        return status;
    }

    public String getPayloadJson() {
        return payloadJson;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
