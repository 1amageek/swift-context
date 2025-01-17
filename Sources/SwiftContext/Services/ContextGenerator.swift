//
//  ContextGenerator.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// A class responsible for generating context from Swift source files and their dependencies.
///
/// This class analyzes the dependencies of a given Swift file, extracts the content from the file and its dependencies,
/// and combines them into a structured and optimized context.
public final class ContextGenerator {
    
    /// The dependency analyzer used to determine dependencies of Swift files.
    private let analyzer: any DependencyAnalyzing
    
    /// The token optimizer used to ensure the generated context fits within a token limit.
    private let optimizer: any TokenOptimizing
    
    /// Initializes a new instance of `ContextGenerator` with the given analyzer and optimizer.
    ///
    /// - Parameters:
    ///   - analyzer: An object conforming to `DependencyAnalyzing` for analyzing dependencies.
    ///   - optimizer: An object conforming to `TokenOptimizing` for optimizing token count.
    public init(analyzer: any DependencyAnalyzing, optimizer: any TokenOptimizing) {
        self.analyzer = analyzer
        self.optimizer = optimizer
    }
    
    /// Generates the context for a given Swift file.
    ///
    /// This method analyzes the dependencies, extracts content from the file and its dependencies,
    /// combines the contents, and optimizes the result.
    ///
    /// - Parameter file: The URL of the target Swift file.
    /// - Returns: A combined and optimized context as a `String`.
    /// - Throws: An error if dependency analysis or content extraction fails.
    public func generateContext(for file: URL) throws -> String {
        let dependencies = try analyzer.analyze(file: file)
        var contexts: [FileContext] = []
        
        // Generate context for the main file
        contexts.append(try generateFileContext(for: file))
        
        // Generate context for dependencies
        for dependency in dependencies {
            contexts.append(try generateFileContext(for: dependency))
        }
        
        // Combine and optimize the context
        let combinedContext = contexts
            .map { $0.formattedContent }
            .joined(separator: "\n\n")
        
        return optimizer.optimize(combinedContext)
    }
    
    /// Generates the context for a specific file, including its content and metadata.
    ///
    /// - Parameter file: The URL of the file to process.
    /// - Returns: A `FileContext` object containing the file's content and metadata.
    /// - Throws: An error if the file content cannot be read or dependencies cannot be analyzed.
    private func generateFileContext(for file: URL) throws -> FileContext {
        let content = try String(contentsOf: file, encoding: .utf8)
        let dependencies = try analyzer.analyze(file: file)
            .map { $0.lastPathComponent }
        
        let frontMatter = FrontMatter(
            file: file.lastPathComponent,
            module: try determineModule(for: file),
            dependencies: Array(dependencies),
            updatedAt: try FileManager.default.modificationDate(of: file)
        )
        
        return FileContext(
            url: file,
            content: content,
            frontMatter: frontMatter
        )
    }
    
    /// Determines the module name for a given file by analyzing its path.
    ///
    /// This method assumes the project follows the Swift Package Manager convention, where source files
    /// are organized under the `Sources/<ModuleName>` directory.
    ///
    /// - Parameter file: The URL of the file to analyze.
    /// - Returns: The name of the module to which the file belongs.
    /// - Throws: An error if the module name cannot be determined.
    private func determineModule(for file: URL) throws -> String {
        let components = file.pathComponents
        if let index = components.firstIndex(of: "Sources"),
           index + 1 < components.count {
            return components[index + 1]
        }
        throw ContextError.invalidModule(file.path)
    }
}
