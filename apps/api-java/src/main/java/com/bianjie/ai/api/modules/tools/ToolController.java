package com.bianjie.ai.api.modules.tools;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/tools")
public class ToolController {

    private final CatalogService catalogService;

    public ToolController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public ApiResponse<List<ToolDto>> listTools() {
        return ApiResponse.ok(catalogService.getTools());
    }

    @GetMapping("/{toolId}")
    public ApiResponse<ToolDto> getTool(@PathVariable String toolId) {
        return ApiResponse.ok(catalogService.getTool(toolId));
    }
}

