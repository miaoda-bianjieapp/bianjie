package com.bianjie.ai.api.modules.ai;

import com.bianjie.ai.api.common.response.ApiResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/ai-gateway")
public class AiGatewayController {

    private final AiGatewayStatusService statusService;

    public AiGatewayController(AiGatewayStatusService statusService) {
        this.statusService = statusService;
    }

    @GetMapping("/status")
    public ApiResponse<AiGatewayStatusDto> status() {
        return ApiResponse.ok(statusService.status());
    }
}
