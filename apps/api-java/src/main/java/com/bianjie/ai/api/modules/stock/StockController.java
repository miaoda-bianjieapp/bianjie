package com.bianjie.ai.api.modules.stock;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/stock")
public class StockController {

    private final CatalogService catalogService;

    public StockController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping("/stats")
    public ApiResponse<List<StockStatDto>> listStats() {
        return ApiResponse.ok(catalogService.getStockStats());
    }

    @GetMapping("/capabilities")
    public ApiResponse<List<StockCapabilityDto>> listCapabilities() {
        return ApiResponse.ok(catalogService.getStockCapabilities());
    }
}

