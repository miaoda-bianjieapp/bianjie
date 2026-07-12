# Bianjie AI Java API

Spring Boot backend for the Bianjie AI app.

```text
code/apps/app       Flutter app
code/apps/api-java  Java API
```

## Run In IDEA

Open this directory as a Maven project:

```text
E:\边界app\code\apps\api-java
```

Use JDK 17 and run:

```text
com.bianjie.ai.api.BianjieAiApiApplication
```

For persistent local data, set Spring Boot active profiles to:

```text
dev
```

In IDEA, put `dev` in the Spring Boot run configuration `Active profiles` field.

You can also use this VM option:

```text
-Dspring.profiles.active=dev
```

## Run From Terminal

```powershell
cd E:\边界app\code\apps\api-java
mvn spring-boot:run
```

With the dev profile:

```powershell
mvn spring-boot:run '-Dspring-boot.run.profiles=dev'
```

## Local URLs

```text
Swagger: http://localhost:8080/swagger-ui.html
Health:  http://localhost:8080/api/v1/health
H2:      http://localhost:8080/h2-console
```

Default H2 JDBC URL:

```text
jdbc:h2:mem:bianjie_ai
```

Dev profile H2 JDBC URL:

```text
jdbc:h2:file:./data/bianjie_ai
```
