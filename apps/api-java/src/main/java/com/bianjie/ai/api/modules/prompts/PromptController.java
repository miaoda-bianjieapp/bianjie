package com.bianjie.ai.api.modules.prompts;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/prompts")
public class PromptController {

    private final CatalogService catalogService;

    public PromptController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public ApiResponse<List<PromptSuggestionDto>> listPrompts(
            @RequestParam(required = false) String scenario
    ) {
        return ApiResponse.ok(catalogService.getPrompts(scenario));
    }
}

