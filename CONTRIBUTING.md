# Contributing to Sequelize Dart

Thank you for your interest in contributing! This document provides guidelines for contributing to the project.

## Git Hooks Setup

This project includes git hooks to automatically format code before committing and check formatting before pushing.

### Initial Setup

Run the setup script to install git hooks:

```bash
./tools/setup-git-hooks.sh
```

This will install:

- **pre-commit hook**: Automatically formats code before each commit
- **pre-push hook**: Checks formatting before pushing (fails if code is not formatted)

### Manual Setup

If you prefer to set up hooks manually:

```bash
# Copy hooks to .git/hooks
cp hooks/pre-commit .git/hooks/pre-commit
cp hooks/pre-push .git/hooks/pre-push
chmod +x .git/hooks/pre-commit .git/hooks/pre-push
```

### Bypassing Hooks (Not Recommended)

If you need to bypass hooks temporarily:

```bash
# Skip pre-commit hook
git commit --no-verify

# Skip pre-push hook
git push --no-verify
```

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

If git hooks are installed, formatting happens automatically. Otherwise:

- [ ] Code is formatted: `./tools/format.sh`
- [ ] No linting errors: `npm run lint`
- [ ] All tests pass (if applicable)
- [ ] Generated files are up to date

**Note**: Git hooks will automatically format code before committing, so you don't need to run the formatter manually if hooks are set up.

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
