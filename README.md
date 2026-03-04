# Automation Testing Boilerplate

A comprehensive automation testing boilerplate generator that creates production-ready project structures for both **Python/pytest** and **Playwright** test automation frameworks.

## 🚀 Features

### Core Capabilities
- **Multi-framework support**: Python/pytest and Playwright (JavaScript/TypeScript)
- **Interactive setup**: Command-line interface for easy project creation
- **Production-ready**: Industry-standard configurations and best practices
- **Docker support**: Containerized testing environments
- **Dependency validation**: Automatic checks for required tools

### Python/pytest Framework
- ✅ Complete pytest project structure
- ✅ Pre-commit hooks with code quality checks
- ✅ YAPF code formatting configuration
- ✅ Requirements management
- ✅ Modular architecture with proper imports

### Playwright Framework  
- ✅ TypeScript configuration with path mapping
- ✅ ESLint and Prettier for code quality
- ✅ Comprehensive npm scripts for all testing scenarios
- ✅ Docker setup with multi-service architecture
- ✅ Browser automation for Chromium, Firefox, and WebKit
- ✅ Parallel and serial test execution options

## 📋 Prerequisites

### System Requirements
- **jq** - JSON processor for configuration parsing
- **Git** - Version control (optional but recommended)

### Framework-Specific Requirements

#### For Python/pytest projects:
- **Python 3.7+** - Python runtime
- **pip** - Python package manager

#### For Playwright projects:
- **Node.js 18+** - JavaScript runtime
- **npm 8+** - Node package manager
- **Docker** (optional) - For containerized testing

## 🛠 Installation

### Install Prerequisites

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install jq python3 nodejs npm
```

**macOS:**
```bash
brew install jq python3 node
```

### Clone Repository
```bash
git clone <repository-url>
cd automation-boilerplate
chmod +x entrypoint.sh
```

## 🎯 Quick Start

### Interactive Setup
```bash
./entrypoint.sh
```

The script will:
1. 🔍 Check system dependencies
2. 📁 Prompt for destination directory
3. ⚡ Framework selection (Python/Playwright)
4. 🏗️ Generate complete project structure

### Example Usage
```bash
$ ./entrypoint.sh
Where should the boilerplate code be created?
Enter the full path to the destination directory: /home/user/my-tests

Please select a framework:
1) python
2) playwright

Enter your choice (1 or 2): 2
```

## 📁 Project Structure

### Python/pytest Projects
```
automation-testing/
├── credentials/
│   └── credentials.yml
├── scripts/
├── modules/
│   └── [generated modules]
├── conftest.py
├── requirements.txt
└── .style.yapf
```

### Playwright Projects
```
automation-testing/
├── credentials/
│   └── credentials.yml
├── scripts/
├── src/
│   ├── data/
│   ├── pages/
│   ├── staticfiles/
│   ├── tests/
│   │   ├── features/
│   │   └── steps/
│   └── utils/
├── playwright.config.js
├── package.json
├── tsconfig.json
├── .eslintrc.js
├── .prettierrc
├── Dockerfile
├── docker-compose.yml
└── .dockerignore
```

## 🐳 Docker Usage (Playwright)

### Quick Commands
```bash
# Run tests in Docker
npm run docker:test

# Development mode with UI
npm run docker:dev

# View reports
npm run docker:report

# Access container shell
npm run docker:shell

# Clean up
npm run docker:clean
```

### Docker Services
- **playwright-tests**: Main testing service
- **selenium-grid**: Distributed testing support
- **playwright-dev**: Development environment
- **playwright-reporter**: Report generation

## 🔧 Development Workflow

### Local Development (Playwright)
```bash
cd your-project-directory

# Install dependencies
npm install

# Install browser binaries
npx playwright install

# Run tests
npm test

# Run tests with UI
npm run test:ui

# Debug mode
npm run test:debug

# Generate reports
npm run report
```

### Local Development (Python)
```bash
cd your-project-directory

# Install dependencies
pip install -r requirements.txt

# Run tests
pytest

# With coverage
pytest --cov=modules
```

## 📊 Available Scripts (Playwright)

### Testing
- `npm test` - Run all tests
- `npm run test:headed` - Run with browser UI
- `npm run test:ui` - Interactive test runner
- `npm run test:debug` - Debug mode
- `npm run test:chromium` - Chromium only
- `npm run test:firefox` - Firefox only 
- `npm run test:webkit` - WebKit only
- `npm run test:parallel` - Parallel execution
- `npm run test:serial` - Serial execution

### Code Quality
- `npm run lint` - Check code quality
- `npm run lint:fix` - Fix linting issues
- `npm run format` - Format code
- `npm run format:check` - Check formatting
- `npm run typecheck` - TypeScript validation

### Utilities
- `npm run codegen` - Generate test code
- `npm run trace` - View test traces
- `npm run clean` - Clean test artifacts
- `npm run setup` - Complete setup

### Docker
- `npm run docker:build` - Build image
- `npm run docker:test` - Run containerized tests
- `npm run docker:dev` - Development container
- `npm run docker:report` - Report container
- `npm run docker:clean` - Clean containers
- `npm run docker:logs` - View logs
- `npm run docker:shell` - Container access

## ⚙️ Configuration

### Playwright Configuration
Main configuration in `playwright.config.js`:
- **testDir**: `./src/tests` - Test directory
- **Browser support**: Chromium, Firefox, WebKit
- **Parallel execution**: Enabled by default
- **Retry logic**: CI environment aware
- **Reporting**: HTML reports with trace collection

### TypeScript Configuration
Path mapping configured in `tsconfig.json`:
- `@/*` → `src/*`
- `@pages/*` → `src/pages/*`
- `@utils/*` → `src/utils/*`
- `@data/*` → `src/data/*`

### Docker Configuration  
Multi-stage builds with:
- **Security**: Non-root user execution
- **Optimization**: Layer caching and minimal dependencies
- **Development**: Volume mounting for live reload
- **Production**: Optimized image size

## 🤝 Contributing

### Guidelines
1. Follow existing code structure and patterns
2. Test changes with both frameworks  
3. Update documentation for new features
4. Ensure Docker compatibility for Playwright changes

### Development Setup
```bash
# Clone repository
git clone <repository-url>
cd automation-boilerplate

# Test Python boilerplate
./entrypoint.sh
# Select option 1, test in temporary directory

# Test Playwright boilerplate  
./entrypoint.sh
# Select option 2, test in temporary directory
```

## 📖 Documentation

### Key Files
- `entrypoint.sh` - Main entry point and framework selector
- `orchestrate/pytest_boilerplate.sh` - Python project generator
- `orchestrate/playwright_boilerplate.sh` - Playwright project generator
- `models/*/config/config.json` - Framework configurations
- `content-as-service/` - Shared configuration files

### Configuration Schema
Projects are generated based on JSON configurations in `models/*/config/config.json` that define:
- Directory structure hierarchy
- File templates and content
- Framework-specific customizations

## 🐛 Troubleshooting

### Common Issues

**jq not found:**
```bash
# Ubuntu/Debian
sudo apt-get ensure jq

# macOS  
brew ensure jq
```

**Permission denied:**
```bash
chmod +x entrypoint.sh
```

**Docker issues (Playwright):**
```bash
# Clean Docker environment
npm run docker:clean
docker system prune -f

# Rebuild containers
npm run docker:build
```

**Playwright browsers not installed:**
```bash
npx playwright install --with-deps
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues, questions, or contributions:
1. Check existing documentation
2. Search through troubleshooting section
3. Create detailed issue reports
4. Provide system information and error logs

---

**Happy Testing! 🎭🐍**