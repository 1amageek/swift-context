import Testing
import Foundation
@testable import SwiftContext

struct ContextGeneratorTests {
    struct TestDependencyAnalyzer: DependencyAnalyzing {
        var mockedDependencies: Set<URL> = []
        
        func analyze(file: URL) throws -> Set<URL> {
            return Set(mockedDependencies.map { $0.standardized.resolvingSymlinksInPath() })
        }
    }
    
    @Test("Generate context for single file without dependencies")
    func testGenerateContextSingleFile() async throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let mainURL = try project.withFile(
            name: "Main.swift",
            content: "struct Main {}"
        )
        
        let analyzer = TestDependencyAnalyzer()
        let optimizer = TokenOptimizerTests.TestTokenOptimizer(maxTokens: 10)
        let generator = ContextGenerator(analyzer: analyzer, optimizer: optimizer)
        
        let context = try generator.generateContext(for: mainURL)
        
        #expect(context.contains("struct Main"))
        #expect(context.contains("dependencies:"))
        #expect(context.contains("module: TestModule"))
        #expect(context.contains("file: Main.swift"))
    }
    
    @Test("Generate context with dependencies")
    func testGenerateContextWithDependencies() async throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let files = try project.withFiles([
            (
                name: "Dependency.swift",
                content: "struct Dependency {}"
            ),
            (
                name: "Main.swift",
                content: "struct Main { let dep: Dependency }"
            )
        ])
        
        let dependencyURL = files[0]
        let mainURL = files[1]
        
        var analyzer = TestDependencyAnalyzer()
        analyzer.mockedDependencies = [dependencyURL]
        let optimizer = TokenOptimizerTests.TestTokenOptimizer(maxTokens: 100)
        let generator = ContextGenerator(analyzer: analyzer, optimizer: optimizer)
        
        let context = try generator.generateContext(for: mainURL)
        
        // コンテンツチェック
        #expect(context.contains("struct Dependency"))
        #expect(context.contains("struct Main"))
        
        // Front Matter チェック
        #expect(context.contains("dependencies:"))
        #expect(context.contains("  - Dependency.swift"))
        #expect(context.contains("module: TestModule"))
        #expect(context.contains("file: Main.swift"))
    }
    
    @Test("Context optimization respects token limit")
    func testContextOptimizationWithTokenLimit() async throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let mainURL = try project.withFile(
            name: "Main.swift",
            content: """
            struct Main {
                let value1: String
                let value2: String
                let value3: String
            }
            """
        )
        
        let analyzer = TestDependencyAnalyzer()
        let optimizer = TokenOptimizerTests.TestTokenOptimizer(maxTokens: 5)
        let generator = ContextGenerator(analyzer: analyzer, optimizer: optimizer)
        
        let context = try generator.generateContext(for: mainURL)
        let tokens = context.split(separator: " ")
        
        #expect(tokens.count <= 5, "Generated context should respect token limit")
    }
}
