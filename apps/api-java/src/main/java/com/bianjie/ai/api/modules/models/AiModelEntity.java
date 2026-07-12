package com.bianjie.ai.api.modules.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "ai_models")
public class AiModelEntity {

    @Id
    private String id;

    private String name;

    @Column(length = 1000)
    private String description;

    private boolean defaultModel;

    private int sortOrder;

    protected AiModelEntity() {
    }

    public AiModelEntity(String id, String name, String description, boolean defaultModel, int sortOrder) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.defaultModel = defaultModel;
        this.sortOrder = sortOrder;
    }

    public AiModelDto toDto() {
        return new AiModelDto(id, name, description, defaultModel);
    }
}

