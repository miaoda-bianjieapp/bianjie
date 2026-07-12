package com.bianjie.ai.api.modules.prompts;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PromptSuggestionRepository extends JpaRepository<PromptSuggestionEntity, String> {

    List<PromptSuggestionEntity> findAllByOrderBySortOrderAsc();

    List<PromptSuggestionEntity> findByScenarioIgnoreCaseOrderBySortOrderAsc(String scenario);
}

