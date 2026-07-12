package com.bianjie.ai.api.modules.models;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface AiModelRepository extends JpaRepository<AiModelEntity, String> {

    List<AiModelEntity> findAllByOrderBySortOrderAsc();

    Optional<AiModelEntity> findFirstByDefaultModelTrueOrderBySortOrderAsc();
}

