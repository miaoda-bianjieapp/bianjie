package com.bianjie.ai.api.modules.users;

import com.bianjie.ai.api.common.response.ApiResponse;
import com.bianjie.ai.api.modules.catalog.CatalogService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class UserController {

    private final CatalogService catalogService;

    public UserController(CatalogService catalogService) {
        this.catalogService = catalogService;
    }

    @GetMapping("/me")
    public ApiResponse<UserProfileDto> getMe() {
        return ApiResponse.ok(catalogService.getUser());
    }

    @PostMapping("/check-in")
    public ApiResponse<UserProfileDto> checkIn() {
        return ApiResponse.ok(catalogService.checkIn());
    }
}

