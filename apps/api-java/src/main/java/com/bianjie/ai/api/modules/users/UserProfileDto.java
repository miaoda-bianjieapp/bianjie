package com.bianjie.ai.api.modules.users;

public record UserProfileDto(
        String id,
        String nickname,
        String phoneMasked,
        String avatar,
        int points,
        String vipStatus,
        boolean checkedInToday
) {
}

