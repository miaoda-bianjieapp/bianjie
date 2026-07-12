package com.bianjie.ai.api.modules.membership;

import java.util.List;

public record MembershipDto(
        String status,
        String title,
        int remainingCredits,
        List<String> benefits
) {
}

