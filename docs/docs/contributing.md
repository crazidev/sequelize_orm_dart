# Contributing

Thank you for your interest in contributing to Sequelize Dart!

For detailed contributing guidelines, see [CONTRIBUTING.md](https://github.com/crazidev/sequelize_dart/blob/main/CONTRIBUTING.md) on GitHub.

## Quick Start

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure code is formatted
5. Submit a pull request

## Git Hooks Setup

This project includes git hooks to automatically format code:

```bash
./tools/setup-git-hooks.sh
```

This installs:
- **pre-commit hook**: Automatically formats code before each commit
- **pre-push hook**: Checks formatting before pushing

## Code Formatting

The project uses Dart's built-in formatter. Format code with:

```bash
dart format .
```

## Testing

Ensure all tests pass before submitting:

```bash
# Run tests
dart test
```

## Documentation

When adding features, please update:
- Relevant documentation pages in `docs/docs/`
- API reference if adding new APIs
- Examples if applicable

## Questions?

Open an issue on [GitHub](https://github.com/crazidev/sequelize_dart/issues) if you have questions about contributing.
