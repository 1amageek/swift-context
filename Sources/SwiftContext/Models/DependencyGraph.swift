//
//  DependencyGraph.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// A class representing a dependency graph for managing file dependencies in a Swift project.
///
/// This graph stores relationships between source files and their dependencies,
/// allowing recursive resolution of dependencies and caching of processed file contexts.
public final class DependencyGraph {
    
    /// A dictionary mapping a source file URL to its set of dependent file URLs.
    private var nodes: [URL: Set<URL>] = [:]
    
    /// A cache for storing processed file contexts by their URLs.
    private var cache: [URL: FileContext] = [:]
    
    /// Initializes a new empty `DependencyGraph`.
    public init() {}
    
    /// Adds a dependency from a source file to a target file.
    ///
    /// - Parameters:
    ///   - source: The URL of the source file.
    ///   - target: The URL of the dependent target file.
    public func addDependency(from source: URL, to target: URL) {
        nodes[source, default: []].insert(target)
    }
    
    /// Retrieves all dependencies for a given file, including indirect dependencies.
    ///
    /// This method performs a recursive traversal of the dependency graph starting from the given file.
    ///
    /// - Parameter file: The URL of the file for which dependencies are to be retrieved.
    /// - Returns: A set of URLs representing all dependencies of the file.
    public func dependencies(for file: URL) -> Set<URL> {
        var result = Set<URL>()
        var visited = Set<URL>()
        
        func visit(_ url: URL) {
            guard !visited.contains(url) else { return }
            visited.insert(url)
            
            if let deps = nodes[url] {
                result.formUnion(deps)
                deps.forEach(visit)
            }
        }
        
        visit(file)
        return result
    }
    
    /// Caches the context for a specific file.
    ///
    /// - Parameter context: The `FileContext` object representing the file's processed context.
    public func cacheContext(_ context: FileContext) {
        cache[context.url] = context
    }
    
    /// Retrieves the cached context for a specific file, if available.
    ///
    /// - Parameter url: The URL of the file for which the context is to be retrieved.
    /// - Returns: The cached `FileContext` object, or `nil` if no context is cached.
    public func cachedContext(for url: URL) -> FileContext? {
        return cache[url]
    }
}
