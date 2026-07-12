package com.bianjie.ai.api;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfSystemProperty;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;

import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@EnabledIfSystemProperty(named = "spring.profiles.active", matches = "local")
class PostgresqlCatalogMigrationTests {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private ObjectMapper objectMapper;

    @Test
    void databaseOwnsProtocolV2ToolDefinitions() throws Exception {
        Long version = jdbcTemplate.queryForObject(
                "SELECT MAX(CAST(version AS BIGINT)) FROM flyway_schema_history WHERE success = TRUE",
                Long.class
        );
        assertThat(version).isGreaterThanOrEqualTo(2L);

        assertToolConfig("design-image", "image-generation", "design-image");
        assertToolConfig("pdf-convert", "document-processing", "pdf-convert");
        assertToolConfig("document-to-ppt", "ppt-generation", "document-to-ppt");
    }

    private void assertToolConfig(String toolId, String executor, String operation) throws Exception {
        String json = jdbcTemplate.queryForObject(
                "SELECT config_json FROM tools WHERE id = ?",
                String.class,
                toolId
        );
        Map<String, Object> config = objectMapper.readValue(json, new TypeReference<>() {
        });
        assertThat(config)
                .containsEntry("version", "tool-protocol-v2")
                .containsEntry("executor", executor)
                .containsEntry("operation", operation);
    }
}
