package com.bianjie.ai.api.modules.prompts;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "prompt_suggestions")
public class PromptSuggestionEntity {

    @Id
    private String id;

    private String text;

    private String target;

    private String icon;

    private String scenario;

    private int sortOrder;

    protected PromptSuggestionEntity() {
    }

    public PromptSuggestionEntity(String id, String text, String target, String icon, String scenario, int sortOrder) {
        this.id = id;
        this.text = text;
        this.target = target;
        this.icon = icon;
        this.scenario = scenario;
        this.sortOrder = sortOrder;
    }

    public PromptSuggestionDto toDto() {
        return new PromptSuggestionDto(id, text, target, icon, scenario);
    }
}

