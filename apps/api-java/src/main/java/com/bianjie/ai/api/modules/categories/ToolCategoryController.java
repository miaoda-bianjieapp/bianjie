package com.bianjie.ai.api.modules.categories;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tool-categories")
public class ToolCategoryController {

    private final CatalogService catalogService;

    public ToolCategoryController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public ApiResponse<List<ToolCategoryDto>> listCategories() {
        return ApiResponse.ok(catalogService.getCategories());
    }
}

