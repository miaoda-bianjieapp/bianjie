package com.bianjie.ai.api.modules.stock;

public record StockCapabilityDto(
        String id,
        String title,
        String prompt,
        String icon,
        boolean opensPage
) {
}

