package com.bianjie.ai.api.modules.membership;

import com.bianjie.ai.api.common.persistence.StringListConverter;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.util.List;

@Entity
@Table(name = "memberships")
public class MembershipEntity {

    @Id
    private String id;

    private String status;

    private String title;

    private int remainingCredits;

    @Convert(converter = StringListConverter.class)
    private List<String> benefits;

    protected MembershipEntity() {
    }

    public MembershipEntity(String id, String status, String title, int remainingCredits, List<String> benefits) {
        this.id = id;
        this.status = status;
        this.title = title;
        this.remainingCredits = remainingCredits;
        this.benefits = benefits;
    }

    public MembershipDto toDto() {
        return new MembershipDto(status, title, remainingCredits, benefits == null ? List.of() : benefits);
    }
}

