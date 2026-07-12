package com.bianjie.ai.api.modules.membership;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/membership")
public class MembershipController {

    private final CatalogService catalogService;

    public MembershipController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping
    public ApiResponse<MembershipDto> getMembership() {
        return ApiResponse.ok(catalogService.getMembership());
    }
}

