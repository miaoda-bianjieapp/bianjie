package com.bianjie.ai.api.modules.categories;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tool_categories")
public class ToolCategoryEntity {

    @Id
    private String id;

    private String name;

    private int count;

    private String parentId;

    private boolean collapsed;

    private int sortOrder;

    protected ToolCategoryEntity() {
    }

    public ToolCategoryEntity(String id, String name, int count, String parentId, boolean collapsed, int sortOrder) {
        this.id = id;
        this.name = name;
        this.count = count;
        this.parentId = parentId;
        this.collapsed = collapsed;
        this.sortOrder = sortOrder;
    }

    public ToolCategoryDto toDto() {
        return new ToolCategoryDto(id, name, count, parentId, collapsed, sortOrder);
    }
}

