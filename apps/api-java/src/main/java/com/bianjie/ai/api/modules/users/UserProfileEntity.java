package com.bianjie.ai.api.modules.users;

import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "user_profiles")
public class UserProfileEntity {

    @Id
    private String id;

    private String nickname;

    private String phoneMasked;

    private String avatar;

    private int points;

    private String vipStatus;

    private boolean checkedInToday;

    protected UserProfileEntity() {
    }

    public UserProfileEntity(
            String id,
            String nickname,
            String phoneMasked,
            String avatar,
            int points,
            String vipStatus,
            boolean checkedInToday
    ) {
        this.id = id;
        this.nickname = nickname;
        this.phoneMasked = phoneMasked;
        this.avatar = avatar;
        this.points = points;
        this.vipStatus = vipStatus;
        this.checkedInToday = checkedInToday;
    }

    public void checkIn() {
        if (!checkedInToday) {
            checkedInToday = true;
            points += 20;
        }
    }

    public UserProfileDto toDto() {
        return new UserProfileDto(id, nickname, phoneMasked, avatar, points, vipStatus, checkedInToday);
    }
}

