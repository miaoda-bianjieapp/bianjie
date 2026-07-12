package com.bianjie.ai.api.modules.agents;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AgentTemplateRepository extends JpaRepository<AgentTemplateEntity, String> {

    List<AgentTemplateEntity> findAllByOrderBySortOrderAsc();
}

