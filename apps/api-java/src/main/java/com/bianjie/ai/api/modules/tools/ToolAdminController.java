package com.bianjie.ai.api.modules.tools;

import com.bianjie.ai.api.common.response.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/tools")
@ConditionalOnProperty(prefix = "bianjie.catalog", name = "admin-enabled", havingValue = "true")
public class ToolAdminController {

    private final ToolAdminService toolAdminService;

    public ToolAdminController(ToolAdminService toolAdminService) {
        this.toolAdminService = toolAdminService;
    }

    @PutMapping("/{toolId}")
    public ApiResponse<ToolDto> upsert(
            @PathVariable String toolId,
            @Valid @RequestBody UpsertToolRequest request
    ) {
        return ApiResponse.ok(toolAdminService.upsert(toolId, request));
    }

    @PatchMapping("/{toolId}/status")
    public ApiResponse<ToolDto> updateStatus(
            @PathVariable String toolId,
            @Valid @RequestBody UpdateToolStatusRequest request
    ) {
        return ApiResponse.ok(toolAdminService.updateStatus(toolId, request.enabled()));
    }
}
