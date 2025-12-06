# Contributing to Sequelize Dart

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Code Formatting

This project uses automated formatting to maintain consistent code style. Please ensure your code is properly formatted before submitting.

### Formatting Rules

- **Dart files**: Use `dart format` (configured in `analysis_options.yaml`)
- **JavaScript/JSON files**: Use Prettier (configured in `.prettierrc.json`)
- **Line length**: 80 characters for Dart, 100 for JavaScript
- **Indentation**: 2 spaces
- **Trailing commas**: Preserved (reduces unnecessary diffs)

### Formatting Commands

#### Format all files:

```bash
# Using the format script
./tools/format.sh

# Or using npm scripts
npm run format

# Or manually
dart format .
prettier --write "**/*.{js,json,md}"
```

#### Check formatting (CI/CD):

```bash
npm run format:check
```

#### Auto-fix linting issues:

```bash
npm run lint:fix
# or
dart fix --apply .
```

### Editor Configuration

The project includes configuration for:

- **VS Code**: `.vscode/settings.json` - Auto-format on save enabled
- **EditorConfig**: `.editorconfig` - Cross-editor formatting rules
- **Prettier**: `.prettierrc.json` - JavaScript/JSON formatting
- **Dart Analysis**: `analysis_options.yaml` - Dart linting and formatting

### Pre-commit Checklist

Before committing, ensure:

- [ ] Code is formatted: `./tools/format.sh`
- [ ] No linting errors: `npm run lint`
- [ ] All tests pass (if applicable)
- [ ] Generated files are up to date

## Code Style Guidelines

### Dart

- Use trailing commas in multi-line lists/maps
- Prefer `final` over `var` when possible
- Use `const` constructors when possible
- Follow Dart style guide: https://dart.dev/guides/language/effective-dart/style

### JavaScript

- Use single quotes for strings
- Use semicolons
- Use trailing commas in multi-line objects/arrays
- Follow Prettier formatting

### File Organization

- Group related files together
- Use consistent naming conventions
- Keep files focused and modular

## Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Format code: `./tools/format.sh`
5. Run linting: `npm run lint`
6. Commit with clear messages
7. Push to your fork
8. Create a pull request

## Questions?

If you have questions about contributing, please open an issue for discussion.
