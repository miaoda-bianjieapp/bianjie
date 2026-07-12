# Backend Stage 2

## Goal

Move the initial API catalog from in-memory mock lists to a database-backed structure.

## Completed

- Added Spring Data JPA and H2.
- Added entities and repositories for tools, categories, prompts, models, agents, stock data, users, and membership.
- Added `CatalogSeedRunner` to seed the first development catalog.
- Kept existing controller API paths stable.
- Added database seed tests.

## Database Mode

The default profile uses in-memory H2:

```text
jdbc:h2:mem:bianjie_ai
```

This keeps automated tests fast and isolated.
