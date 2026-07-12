package com.bianjie.ai.api.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI bianjieOpenApi() {
        return new OpenAPI()
                .info(new Info()
                        .title("杈圭晫 AI API")
                        .description("App demo backend API for tool catalog and task entry.")
                        .version("0.1.0"));
    }
}

