//
//  SwiftContextCLI.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation
import ArgumentParser
import SwiftContext

/// A command-line tool for generating Large Language Model (LLM) context from Swift source files.
///
/// This tool analyzes the dependencies of a specified Swift file, optimizes the token count,
/// and generates a structured context suitable for LLM-based applications.
@main
struct SwiftContextCLI: ParsableCommand {
    
    /// Configuration for the command-line tool, including its name, description, and version.
    static let configuration = CommandConfiguration(
        commandName: "swift-context",
        abstract: "A Swift source analysis tool that generates contextual summaries for AI/LLM interactions",
        discussion: """
            Swiftscope analyzes Swift source files and their dependencies to create comprehensive context \
            for AI/LLM interactions. It can:
            
            - Track and analyze file dependencies
            - Generate structured summaries of Swift code
            - Optimize output for token limitations
            - Format content with front matter metadata
            
            Example usage:
              $ swiftscope -p ./MyProject -f ./Sources/MyFile.swift
              $ swiftscope --project-root ./MyProject --file ./Sources/MyFile.swift --max-tokens 4000
              $ swiftscope -p . -f ./Sources/Main.swift --verbose
            """,
        version: "1.0.0"
    )
    
    /// The root directory of the project containing the Swift files.
    @Option(name: .shortAndLong, help: "Path to the project root directory")
    var projectRoot: String
    
    /// The path to the target Swift file for which the context will be generated.
    @Option(name: .shortAndLong, help: "Path to the target Swift file")
    var file: String
    
    /// The maximum number of tokens allowed in the generated context.
    ///
    /// This value ensures that the generated context does not exceed the token limit of the target LLM.
    @Option(name: .shortAndLong, help: "Maximum number of tokens in the output")
    var maxTokens: Int = 8192
    
    /// A flag to enable verbose output, providing detailed dependency information.
    @Flag(name: .shortAndLong, help: "Show detailed dependency information")
    var verbose: Bool = false
    
    /// Executes the command with the provided options and flags.
    ///
    /// - Throws: An error if the dependency analysis or context generation fails.
    func run() throws {
        let projectURL = URL(fileURLWithPath: projectRoot)
        let fileURL = URL(fileURLWithPath: file)
        
        // Initialize the components
        let analyzer = DependencyAnalyzer(projectRoot: projectURL)
        let optimizer = TokenOptimizer(maxTokens: maxTokens)
        let generator = ContextGenerator(analyzer: analyzer, optimizer: optimizer)
        
        // If verbose is enabled, display detailed information about the process
        if verbose {
            print("Analyzing dependencies for: \(fileURL.path)")
            let dependencies = try analyzer.analyze(file: fileURL)
            print("\nDependencies found:")
            for dependency in dependencies {
                print("- \(dependency.path)")
            }
            print("\nGenerating context...")
        }
        
        // Generate and output the context
        let context = try generator.generateContext(for: fileURL)
        print(context)
    }
}
