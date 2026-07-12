package com.bianjie.ai.api.modules.models;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/models")
public class AiModelController {

    private final CatalogService catalogService;

    public AiModelController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public ApiResponse<List<AiModelDto>> listModels() {
        return ApiResponse.ok(catalogService.getModels());
    }

    @GetMapping("/default")
    public ApiResponse<AiModelDto> getDefaultModel() {
        return ApiResponse.ok(catalogService.getDefaultModel());
    }
}

