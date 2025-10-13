# Contributing to Maven Release Action

First off, thank you for considering contributing to Maven Release Action! It's people like you that make this tool better for everyone.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Workflow](#development-workflow)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Style Guidelines](#style-guidelines)

## 📜 Code of Conduct

This project and everyone participating in it is governed by common sense and mutual respect. Please be kind and courteous to others.

## 🚀 Getting Started

### Prerequisites

- Git
- Maven 3.6+
- Java 8+
- Basic understanding of GitHub Actions

### Setting Up Development Environment

1. Fork the repository
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/maven-release-action.git
   cd maven-release-action
   ```

3. Run the local test:
   ```bash
   ./test-local.sh
   ```

## 🤝 How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- Clear and descriptive title
- Detailed steps to reproduce
- Expected behavior
- Actual behavior
- Your environment (OS, Java version, Maven version)
- Relevant logs or error messages

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- Clear and descriptive title
- Detailed explanation of the suggested enhancement
- Examples of how it would be used
- Why this enhancement would be useful

### Contributing Code

1. Check if there's an existing issue. If not, create one.
2. Fork the repository
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit your changes with clear messages
7. Push to your fork
8. Submit a pull request

## 🔄 Development Workflow

### Project Structure

```
maven-release-action/
├── .github/
│   └── workflows/        # Example workflows and CI
├── test-project/         # Test Maven project
│   ├── src/
│   └── pom.xml
├── action.yml            # Action definition
├── test-local.sh         # Local testing script
├── README.md             # Documentation
├── README.zh-CN.md       # Chinese documentation
└── LICENSE               # MIT License
```

### Making Changes to action.yml

1. Edit `action.yml`
2. Test locally using the test project:
   ```bash
   cd test-project
   mvn clean verify
   ```
3. Update documentation if needed
4. Run the full test suite:
   ```bash
   ./test-local.sh
   ```

### Adding New Features

1. Update `action.yml` with new inputs/outputs
2. Add corresponding documentation to README.md
3. Update README.zh-CN.md (Chinese version)
4. Add tests if applicable
5. Update CHANGELOG (if exists)

## 🧪 Testing

### Local Testing

```bash
# Run all tests
./test-local.sh

# Skip site generation (faster)
SKIP_SITE=true ./test-local.sh

# Test specific Maven command
cd test-project
mvn clean verify
```

### Testing Changes

1. Test on the test-project
2. Test with your own Maven project
3. Verify all existing examples still work
4. Check that error messages are clear

### Writing Tests

- Ensure the test-project covers your use case
- Add new test cases if needed
- Update test scripts if necessary

## 📥 Pull Request Process

1. **Before submitting:**
   - Run `./test-local.sh` and ensure all tests pass
   - Update documentation (README.md and README.zh-CN.md)
   - Update examples if needed
   - Ensure code follows style guidelines

2. **PR Description:**
   - Reference any related issues
   - Describe what changes you made
   - Explain why these changes are necessary
   - Include screenshots if UI/output changed

3. **Review Process:**
   - Maintainers will review your PR
   - Address any feedback
   - Once approved, your PR will be merged

4. **After merge:**
   - Delete your feature branch
   - Update your fork

## 📝 Style Guidelines

### YAML Files (action.yml, workflows)

- Use 2 spaces for indentation
- Keep lines under 120 characters
- Add comments for complex logic
- Use meaningful input/output names
- Include descriptions for all inputs

### Shell Scripts

- Use `#!/bin/bash` shebang
- Use `set -e` for error handling
- Quote variables: `"$VAR"`
- Use meaningful function and variable names
- Add comments for complex logic
- Follow Bash best practices

### Documentation

- Use clear, concise language
- Include examples for all features
- Keep English and Chinese versions in sync
- Use proper markdown formatting
- Add code examples with syntax highlighting

### Commit Messages

Follow conventional commits:

```
feat: add new feature
fix: fix bug description
docs: update documentation
test: add or update tests
chore: maintenance tasks
refactor: code refactoring
```

Examples:
```
feat: add support for custom Maven profiles
fix: resolve GPG signing issue on Windows
docs: update README with troubleshooting section
test: add tests for multi-module projects
```

## 🎯 Areas for Contribution

Looking for ideas? Here are areas where contributions are welcome:

### High Priority
- Improve error messages
- Add more examples
- Enhance documentation
- Fix bugs

### Medium Priority
- Add new features
- Improve test coverage
- Performance optimizations
- Windows-specific improvements

### Low Priority
- Code refactoring
- Additional language support in docs
- CI/CD improvements

## 📞 Getting Help

- Create an issue for questions
- Check existing issues and discussions
- Read the documentation thoroughly

## 🎉 Recognition

Contributors will be:
- Listed in the README (if significant contribution)
- Credited in release notes
- Appreciated by the community!

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to Maven Release Action! 🎉

