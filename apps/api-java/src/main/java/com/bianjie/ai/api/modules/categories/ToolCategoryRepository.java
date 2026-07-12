package com.bianjie.ai.api.modules.categories;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ToolCategoryRepository extends JpaRepository<ToolCategoryEntity, String> {

    List<ToolCategoryEntity> findAllByOrderBySortOrderAsc();
}

