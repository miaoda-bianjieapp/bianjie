package com.bianjie.ai.api.modules.stock;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "stock_capabilities")
public class StockCapabilityEntity {

    @Id
    private String id;

    private String title;

    @Column(length = 1000)
    private String prompt;

    private String icon;

    private boolean opensPage;

    private int sortOrder;

    protected StockCapabilityEntity() {
    }

    public StockCapabilityEntity(
            String id,
            String title,
            String prompt,
            String icon,
            boolean opensPage,
            int sortOrder
    ) {
        this.id = id;
        this.title = title;
        this.prompt = prompt;
        this.icon = icon;
        this.opensPage = opensPage;
        this.sortOrder = sortOrder;
    }

    public StockCapabilityDto toDto() {
        return new StockCapabilityDto(id, title, prompt, icon, opensPage);
    }
}

