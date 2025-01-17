import Testing
import Foundation
@testable import SwiftContext

struct DependencyGraphTests {
    @Test("Add and retrieve single dependency")
    func testAddAndRetrieveSingleDependency() throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let sourceFile = try project.withFile(name: "source.swift", content: "")
        let targetFile = try project.withFile(name: "target.swift", content: "")
        
        let graph = DependencyGraph()
        graph.addDependency(from: sourceFile, to: targetFile)
        let dependencies = graph.dependencies(for: sourceFile)
        
        #expect(dependencies.count == 1)
        #expect(TestHelpers.assertURLSetContains(dependencies, targetFile))
    }
    
    @Test("Add and retrieve multiple dependencies")
    func testAddAndRetrieveMultipleDependencies() throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let files = try project.withFiles([
            (name: "source.swift", content: ""),
            (name: "target1.swift", content: ""),
            (name: "target2.swift", content: "")
        ])
        
        let sourceFile = files[0]
        let target1File = files[1]
        let target2File = files[2]
        
        let graph = DependencyGraph()
        graph.addDependency(from: sourceFile, to: target1File)
        graph.addDependency(from: sourceFile, to: target2File)
        
        let dependencies = graph.dependencies(for: sourceFile)
        
        #expect(dependencies.count == 2)
        #expect(TestHelpers.assertURLSetContains(dependencies, target1File))
        #expect(TestHelpers.assertURLSetContains(dependencies, target2File))
    }
    
    @Test("Cache and retrieve FileContext")
    func testCacheAndRetrieveFileContext() throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let fileURL = try project.withFile(name: "test.swift", content: "// Test content")
        
        let frontMatter = FrontMatter(
            file: "test.swift",
            module: "TestModule",
            dependencies: [],
            updatedAt: Date()
        )
        
        let context = FileContext(
            url: fileURL,
            content: "// Test content",
            frontMatter: frontMatter
        )
        
        let graph = DependencyGraph()
        graph.cacheContext(context)
        let retrieved = graph.cachedContext(for: fileURL)
        
        #expect(retrieved != nil)
        #expect(TestHelpers.assertURLsEqual(retrieved!.url, fileURL))
        #expect(retrieved?.content == "// Test content")
    }
    
    @Test("Recursive dependency resolution")
    func testRecursiveDependencyResolution() throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let files = try project.withFiles([
            (name: "source.swift", content: ""),
            (name: "mid.swift", content: ""),
            (name: "target.swift", content: "")
        ])
        
        let sourceFile = files[0]
        let midFile = files[1]
        let targetFile = files[2]
        
        let graph = DependencyGraph()
        graph.addDependency(from: sourceFile, to: midFile)
        graph.addDependency(from: midFile, to: targetFile)
        
        let dependencies = graph.dependencies(for: sourceFile)
        
        #expect(dependencies.count == 2)
        #expect(TestHelpers.assertURLSetContains(dependencies, midFile))
        #expect(TestHelpers.assertURLSetContains(dependencies, targetFile))
    }
}
