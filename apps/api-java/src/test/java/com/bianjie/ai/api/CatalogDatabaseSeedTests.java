package com.bianjie.ai.api;

import com.bianjie.ai.api.modules.agents.AgentTemplateRepository;
import com.bianjie.ai.api.modules.categories.ToolCategoryRepository;
import com.bianjie.ai.api.modules.membership.MembershipRepository;
import com.bianjie.ai.api.modules.models.AiModelRepository;
import com.bianjie.ai.api.modules.prompts.PromptSuggestionRepository;
import com.bianjie.ai.api.modules.stock.StockCapabilityRepository;
import com.bianjie.ai.api.modules.stock.StockStatRepository;
import com.bianjie.ai.api.modules.tools.ToolRepository;
import com.bianjie.ai.api.modules.users.UserProfileRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(properties = "bianjie.ai.gateway.provider=mock")
class CatalogDatabaseSeedTests {

    @Autowired
    private ToolRepository toolRepository;

    @Autowired
    private ToolCategoryRepository categoryRepository;

    @Autowired
    private PromptSuggestionRepository promptRepository;

    @Autowired
    private AiModelRepository modelRepository;

    @Autowired
    private AgentTemplateRepository agentTemplateRepository;

    @Autowired
    private StockStatRepository stockStatRepository;

    @Autowired
    private StockCapabilityRepository stockCapabilityRepository;

    @Autowired
    private UserProfileRepository userProfileRepository;

    @Autowired
    private MembershipRepository membershipRepository;

    @Test
    void seedDataIsLoadedIntoDatabase() {
        assertThat(toolRepository.count()).isEqualTo(25);
        assertThat(categoryRepository.count()).isEqualTo(10);
        assertThat(promptRepository.count()).isEqualTo(4);
        assertThat(modelRepository.count()).isEqualTo(5);
        assertThat(modelRepository.existsById("glm-5v-turbo")).isTrue();
        assertThat(agentTemplateRepository.count()).isEqualTo(4);
        assertThat(stockStatRepository.count()).isEqualTo(3);
        assertThat(stockCapabilityRepository.count()).isEqualTo(5);
        assertThat(userProfileRepository.existsById("u-demo-001")).isTrue();
        assertThat(membershipRepository.existsById("default")).isTrue();
    }
}
