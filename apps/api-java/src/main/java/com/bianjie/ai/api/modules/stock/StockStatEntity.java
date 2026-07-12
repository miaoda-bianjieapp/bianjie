package com.bianjie.ai.api.modules.stock;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Column;
import jakarta.persistence.Table;

@Entity
@Table(name = "stock_stats")
public class StockStatEntity {

    @Id
    private String id;

    private String label;

    @Column(name = "stat_value")
    private String value;

    private String unit;

    private int sortOrder;

    protected StockStatEntity() {
    }

    public StockStatEntity(String id, String label, String value, String unit, int sortOrder) {
        this.id = id;
        this.label = label;
        this.value = value;
        this.unit = unit;
        this.sortOrder = sortOrder;
    }

    public StockStatDto toDto() {
        return new StockStatDto(label, value, unit);
    }
}

