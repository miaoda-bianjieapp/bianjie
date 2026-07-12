package com.bianjie.ai.api.modules.tools;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ToolRepository extends JpaRepository<ToolEntity, String> {

    List<ToolEntity> findAllByOrderBySortOrderAsc();
}

