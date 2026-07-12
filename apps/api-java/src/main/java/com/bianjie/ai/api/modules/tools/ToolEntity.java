package com.bianjie.ai.api.modules.tools;

import com.bianjie.ai.api.common.persistence.StringListConverter;
import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.util.List;
import java.util.Map;

@Entity
@Table(name = "tools")
public class ToolEntity {

    @Id
    private String id;

    private String name;

    @Column(length = 1000)
    private String description;

    private String categoryId;

    @Column(name = "tab_key")
    private String tab;

    private String icon;

    @Convert(converter = StringListConverter.class)
    @Column(length = 1000)
    private List<String> tags;

    private String route;

    private boolean enabled;

    private int sortOrder;

    private boolean requiresLogin;

    private boolean requiresVip;

    @Enumerated(EnumType.STRING)
    private ToolExecutionType executionType;

    @Column(columnDefinition = "TEXT")
    private String configJson;

    protected ToolEntity() {
    }

    public ToolEntity(
            String id,
            String name,
            String description,
            String categoryId,
            String tab,
            String icon,
            List<String> tags,
            String route,
            boolean enabled,
            int sortOrder,
            boolean requiresLogin,
            boolean requiresVip,
            ToolExecutionType executionType,
            String configJson
    ) {
        this.id = id;
        this.name = name;
        this.description = description;
        this.categoryId = categoryId;
        this.tab = tab;
        this.icon = icon;
        this.tags = tags;
        this.route = route;
        this.enabled = enabled;
        this.sortOrder = sortOrder;
        this.requiresLogin = requiresLogin;
        this.requiresVip = requiresVip;
        this.executionType = executionType;
        this.configJson = configJson;
    }

    public String getId() {
        return id;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public String getConfigJson() {
        return configJson;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public ToolDto toDto(Map<String, Object> config) {
        return new ToolDto(
                id,
                name,
                description,
                categoryId,
                tab,
                icon,
                tags == null ? List.of() : tags,
                route,
                enabled,
                sortOrder,
                requiresLogin,
                requiresVip,
                executionType,
                config == null ? Map.of() : config
        );
    }
}

