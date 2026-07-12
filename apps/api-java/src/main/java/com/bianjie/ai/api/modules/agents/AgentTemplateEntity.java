package com.bianjie.ai.api.modules.agents;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "agent_templates")
public class AgentTemplateEntity {

    @Id
    private String id;

    private String title;

    private String coverIcon;

    private String category;

    @Column(length = 1000)
    private String prompt;

    @Column(length = 1000)
    private String description;

    private int sortOrder;

    protected AgentTemplateEntity() {
    }

    public AgentTemplateEntity(
            String id,
            String title,
            String coverIcon,
            String category,
            String prompt,
            String description,
            int sortOrder
    ) {
        this.id = id;
        this.title = title;
        this.coverIcon = coverIcon;
        this.category = category;
        this.prompt = prompt;
        this.description = description;
        this.sortOrder = sortOrder;
    }

    public AgentTemplateDto toDto() {
        return new AgentTemplateDto(id, title, coverIcon, category, prompt, description);
    }
}

