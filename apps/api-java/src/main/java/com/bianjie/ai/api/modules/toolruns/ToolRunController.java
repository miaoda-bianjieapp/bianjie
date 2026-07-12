package com.bianjie.ai.api.modules.toolruns;

import com.bianjie.ai.api.common.response.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class ToolRunController {

    private final ToolRunService toolRunService;

    public ToolRunController(ToolRunService toolRunService) {
        this.toolRunService = toolRunService;
    }

    @PostMapping("/tools/{toolId}/runs")
    public ApiResponse<ToolRunDto> createRun(
            @PathVariable String toolId,
            @Valid @RequestBody CreateToolRunRequest request
    ) {
        return ApiResponse.ok(toolRunService.createRun(toolId, request));
    }

    @GetMapping("/tool-runs")
    public ApiResponse<List<ToolRunDto>> listRuns() {
        return ApiResponse.ok(toolRunService.listRuns());
    }

    @GetMapping("/tool-runs/{runId}")
    public ApiResponse<ToolRunDto> getRun(@PathVariable String runId) {
        return ApiResponse.ok(toolRunService.getRun(runId));
    }
}

