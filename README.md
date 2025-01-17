# swift-context 🔍

Generate rich context for LLM interactions from Swift source code 🚀

## Overview 📖

swift-context is a command-line tool that analyzes Swift source files to create optimized context for AI/LLM interactions. It helps you extract meaningful information from your Swift codebase by:

- 🔄 Analyzing file dependencies
- 📝 Generating structured code summaries
- ⚡️ Optimizing output for token limitations
- 📊 Including metadata via front matter

## Installation 📦

```bash
git clone https://github.com/1amageek/swift-context.git
cd swift-context
swift build -c release
```

## Requirements 🛠️

- Swift 6.0+
- macOS 15.0+ or iOS 18.0+
- Xcode 15.0+

## Usage 💻

Basic command structure:

```bash
swift-context --project-root <project_path> --file <file_path> [options]
```

Example usage:

```bash
# Basic analysis
swift-context -p ./MyProject -f ./Sources/MyFile.swift

# With token limit
swift-context -p ./MyProject -f ./Sources/MyFile.swift --max-tokens 4000

# Detailed output
swift-context -p . -f ./Sources/Main.swift --verbose
```

### Options 🎯

- `-p, --project-root`: Path to the project root directory
- `-f, --file`: Path to the target Swift file
- `--max-tokens`: Maximum number of tokens in the output (default: 8192)
- `-v, --verbose`: Show detailed dependency information

## Example Output 📋

```yaml
---
file: MyFile.swift
module: MyModule
dependencies:
  - Dependency1.swift
  - Dependency2.swift
updated_at: 2025-01-17T10:29:32Z
---

// Generated context content
```

## Features 🌟

- 🔍 Intelligent dependency tracking
- 📊 Front matter metadata generation
- ⚡️ Token-aware content optimization
- 🔄 Recursive dependency analysis
- 📝 Structured output format

## Dependencies 📚

- [swift-syntax](https://github.com/swiftlang/swift-syntax) - For Swift code parsing
- [swift-argument-parser](https://github.com/apple/swift-argument-parser) - For CLI argument parsing

## Contributing 🤝

Contributions are welcome! Please feel free to submit a Pull Request.

## License 📄

This project is licensed under the MIT License - see the LICENSE file for details.

## Author ✨

[@1amageek](https://github.com/1amageek)

---

Made with ❤️ for the Swift community