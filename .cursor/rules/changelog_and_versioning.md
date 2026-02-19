# Changelog and Versioning Rules

Follow these rules when bumping versions or updating changelogs in the Sequelize Dart project.

## Versioning Policy

- We use **Semantic Versioning** (MAJOR.MINOR.PATCH).
- Both `sequelize_orm` and `sequelize_orm_generator` should generally be kept in sync with the same version number.
- When `sequelize_orm_generator` is updated, ensure its dependency on `sequelize_orm` in `pubspec.yaml` is also updated to the matching version.

## Files to Update

When bumping the version (e.g., from `0.1.4` to `0.1.5`), you **MUST** update the version string in the following files:

1.  `packages/sequelize_orm/pubspec.yaml`
2.  `packages/sequelize_orm_generator/pubspec.yaml` (also update the `sequelize_orm` dependency)
3.  `packages/sequelize_orm/README.md` (installation snippets)
4.  `packages/sequelize_orm_generator/README.md` (installation snippets)
5.  `packages/sequelize_orm/CHANGELOG.md` (add new version header)
6.  `packages/sequelize_orm/dartdoc/get-started.md` (installation snippets)
7.  `docs/docs/get-started.md` (installation snippets)

## Changelog Conventions

- Update `packages/sequelize_orm/CHANGELOG.md` with every release.
- Use the following categories for entries:
    - **FEAT**: New features or significant additions.
    - **FIX**: Bug fixes.
    - **IMPROVEMENT**: Non-breaking enhancements or performance gains.
    - **CHORE**: Internal maintenance, documentation updates, or refactoring.
    - **REFACTOR**: Specifically for structural code changes that don't change behavior.
- Entries should be concise but descriptive.

## Code Generation Recommendation

Always recommend `dart run sequelize_orm_generator:generate` over `build_runner` in documentation and user communication.
It is significantly faster as it only processes model files and bypasses the heavy `build_runner` graph calculation.
