//
//  DependencyAnalyzer.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation
import SwiftSyntax
import SwiftParser

/// A protocol defining the interface for dependency analysis.
///
/// Classes conforming to this protocol are responsible for analyzing dependencies of a given Swift file.
public protocol DependencyAnalyzing {
    /// Analyzes the dependencies of a given Swift file.
    ///
    /// - Parameter file: The URL of the Swift file to analyze.
    /// - Returns: A set of URLs representing the dependent files.
    /// - Throws: An error if the analysis fails.
    func analyze(file: URL) throws -> Set<URL>
}

/// A class that analyzes the dependencies of Swift files within a project.
///
/// This class uses `SwiftSyntax` to parse Swift files and identify their dependencies based on
/// import statements and type references.
public final class DependencyAnalyzer: DependencyAnalyzing {
    
    /// The root directory of the project containing the Swift files.
    private let projectRoot: URL
    
    /// A graph structure for storing and managing file dependencies.
    private let dependencyGraph: DependencyGraph
    
    /// A file manager for handling file operations.
    private let fileManager: FileManager
    
    /// Initializes a new instance of `DependencyAnalyzer` with the project root.
    ///
    /// - Parameter projectRoot: The root directory of the project.
    public init(projectRoot: URL) {
        self.projectRoot = projectRoot
        self.dependencyGraph = DependencyGraph()
        self.fileManager = FileManager.default
    }
    
    /// Initializes a new instance of `DependencyAnalyzer` with a custom dependency graph.
    ///
    /// - Parameters:
    ///   - projectRoot: The root directory of the project.
    ///   - dependencyGraph: A custom dependency graph instance.
    public init(projectRoot: URL, dependencyGraph: DependencyGraph) {
        self.projectRoot = projectRoot
        self.dependencyGraph = dependencyGraph
        self.fileManager = FileManager.default
    }
    
    /// Analyzes the dependencies of a given Swift file.
    ///
    /// This method checks for cached results and updates them if the file has been modified.
    /// It extracts dependencies using import statements and type references, updates the dependency graph,
    /// and caches the analysis results.
    ///
    /// - Parameter file: The URL of the Swift file to analyze.
    /// - Returns: A set of URLs representing the dependent files.
    /// - Throws: An error if the analysis fails.
    public func analyze(file: URL) throws -> Set<URL> {
        // Check the cache for existing analysis
        if let cachedContext = dependencyGraph.cachedContext(for: file) {
            let lastModified = try fileManager.modificationDate(of: file)
            if lastModified <= cachedContext.frontMatter.updatedAt {
                return dependencyGraph.dependencies(for: file)
            }
        }
        
        let content = try String(contentsOf: file, encoding: .utf8)
        let syntax = Parser.parse(source: content)
        
        let dependencyVisitor = DependencyVisitor(viewMode: .sourceAccurate)
        let typeReferenceVisitor = TypeReferenceVisitor(viewMode: .sourceAccurate)
        
        dependencyVisitor.walk(syntax)
        typeReferenceVisitor.walk(syntax)
        
        let context = VisitorContext(
            dependencyVisitor: dependencyVisitor,
            typeReferenceVisitor: typeReferenceVisitor
        )
        
        // Resolve dependencies and update the graph
        let dependencies = try resolveDependencies(from: context)
        dependencies.forEach { dependencyGraph.addDependency(from: file, to: $0) }
        
        // Generate and cache the file context
        let fileContext = try generateFileContext(for: file, with: dependencies)
        dependencyGraph.cacheContext(fileContext)
        
        return dependencies
    }
    
    /// Resolves dependencies from the visitor context by analyzing import statements and type references.
    ///
    /// - Parameter context: The visitor context containing analyzed dependencies.
    /// - Returns: A set of URLs representing resolved dependencies.
    /// - Throws: An error if dependency resolution fails.
    private func resolveDependencies(from context: VisitorContext) throws -> Set<URL> {
        var dependencies = Set<URL>()
        
        // Resolve dependencies from import statements
        for importPath in context.filterSystemTypes() {
            if let url = try findFile(for: importPath) {
                dependencies.insert(url)
            }
        }
        
        // Resolve dependencies from type references
        for typeName in context.allReferencedTypes {
            if let url = try findFile(for: typeName) {
                dependencies.insert(url)
            }
        }
        
        return dependencies
    }
    
    /// Searches for a file corresponding to the given identifier.
    ///
    /// - Parameter identifier: The identifier (e.g., module or type name) to find.
    /// - Returns: The URL of the file if found, or `nil` if not found.
    /// - Throws: An error if the search fails.
    private func findFile(for identifier: String) throws -> URL? {
        let sourcesDir = projectRoot.appendingPathComponent("Sources")
        let files = try fileManager.swiftFiles(in: sourcesDir)
        
        return files.first { url in
            let filename = url.deletingPathExtension().lastPathComponent
            return filename == identifier
        }
    }
    
    /// Generates a `FileContext` for the given file and its dependencies.
    ///
    /// - Parameters:
    ///   - file: The URL of the target file.
    ///   - dependencies: The set of dependencies for the file.
    /// - Returns: A `FileContext` containing the file content and metadata.
    /// - Throws: An error if file content or metadata extraction fails.
    private func generateFileContext(for file: URL, with dependencies: Set<URL>) throws -> FileContext {
        let content = try String(contentsOf: file, encoding: .utf8)
        let dependencyNames = dependencies.map { $0.lastPathComponent }
        
        let frontMatter = FrontMatter(
            file: file.lastPathComponent,
            module: try determineModule(for: file),
            dependencies: Array(dependencyNames),
            updatedAt: try fileManager.modificationDate(of: file)
        )
        
        return FileContext(
            url: file,
            content: content,
            frontMatter: frontMatter
        )
    }
    
    /// Determines the module name for the given file based on its path.
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
