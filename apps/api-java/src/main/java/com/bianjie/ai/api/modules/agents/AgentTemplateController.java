package com.bianjie.ai.api.modules.agents;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/agents/templates")
public class AgentTemplateController {

    private final CatalogService catalogService;

    public AgentTemplateController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public ApiResponse<List<AgentTemplateDto>> listTemplates() {
        return ApiResponse.ok(catalogService.getAgentTemplates());
    }

    @GetMapping("/{templateId}")
    public ApiResponse<AgentTemplateDto> getTemplate(@PathVariable String templateId) {
        return ApiResponse.ok(catalogService.getAgentTemplate(templateId));
    }
}

