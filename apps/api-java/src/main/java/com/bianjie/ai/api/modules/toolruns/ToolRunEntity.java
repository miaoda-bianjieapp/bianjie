package com.bianjie.ai.api.modules.toolruns;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;

@Entity
@Table(name = "tool_runs")
public class ToolRunEntity {

    @Id
    private String id;

    private String toolId;

    private String status;

    @Column(columnDefinition = "TEXT")
    private String input;

    @Column(columnDefinition = "TEXT")
    private String parametersJson;

    @Column(columnDefinition = "TEXT")
    private String outputJson;

    private Instant createdAt;

    private Instant updatedAt;

    protected ToolRunEntity() {
    }

    public ToolRunEntity(
            String id,
            String toolId,
            String status,
            String input,
            String parametersJson,
            String outputJson,
            Instant createdAt,
            Instant updatedAt
    ) {
        this.id = id;
        this.toolId = toolId;
        this.status = status;
        this.input = input;
        this.parametersJson = parametersJson;
        this.outputJson = outputJson;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public String getId() {
        return id;
    }

    public String getToolId() {
        return toolId;
    }

    public String getStatus() {
        return status;
    }

    public String getInput() {
        return input;
    }

    public String getParametersJson() {
        return parametersJson;
    }

    public String getOutputJson() {
        return outputJson;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
