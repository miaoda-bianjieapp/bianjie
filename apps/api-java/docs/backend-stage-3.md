# Backend Stage 3

## Goal

Stage 3 turns the Java API into a stable local development backend that can be started from IDEA and consumed by the Flutter app.

## Completed

- Renamed `CatalogMockService` to `CatalogService` so controllers depend on a real catalog service name instead of mock wording.
- Added the `dev` Spring profile with file-based H2 persistence.
- Kept the default profile on in-memory H2 for fast tests and smoke checks.
- Kept seed behavior idempotent: seed data is inserted only when the catalog is empty.
- Prepared the Flutter app for remote API access with configurable base URL and repository parsing.

## IDEA Run

Use this profile when you want local data to survive backend restarts.

In IDEA, set Spring Boot `Active profiles` to:

```text
dev
```

Or use this VM option:

```text
-Dspring.profiles.active=dev
```

The dev database is stored under:

```text
code/apps/api-java/data/
```

This directory is ignored by Git.

## API Docs

```text
http://localhost:8080/swagger-ui.html
```

## H2 Console

```text
http://localhost:8080/h2-console
```

For the default profile:

```text
jdbc:h2:mem:bianjie_ai
```

For the dev profile:

```text
jdbc:h2:file:./data/bianjie_ai
```
