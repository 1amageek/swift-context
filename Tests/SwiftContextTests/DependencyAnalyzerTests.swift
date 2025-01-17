import Testing
import Foundation
@testable import SwiftContext

struct DependencyAnalyzerTests {
    
    @Test("Analyze simple Swift file without dependencies")
    func testAnalyzeSimpleFile() async throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let simpleFile = try project.withFile(
            name: "Simple.swift",
            content: """
            struct Simple {
                let value: String
            }
            """
        )
        
        let analyzer = DependencyAnalyzer(projectRoot: project.projectRoot)
        let dependencies = try analyzer.analyze(file: simpleFile)
        
        #expect(dependencies.isEmpty)
    }
    
    @Test("Analyze file with custom type dependencies")
    func testAnalyzeWithDependencies() async throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let files = try project.withFiles([
            (
                name: "Dependency.swift",
                content: "struct Dependency {}"
            ),
            (
                name: "Main.swift",
                content: """
                struct Main {
                    let dependency: Dependency
                }
                """
            )
        ])
        
        let dependencyURL = files[0]
        let mainURL = files[1]
        
        let analyzer = DependencyAnalyzer(projectRoot: project.projectRoot)
        let dependencies = try analyzer.analyze(file: mainURL)
        
        #expect(TestHelpers.assertURLSetContains(dependencies, dependencyURL))
    }
    
    @Test("Analyze file with multiple dependencies")
    func testAnalyzeMultipleDependencies() async throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let files = try project.withFiles([
            (
                name: "Dep1.swift",
                content: "struct Dep1 {}"
            ),
            (
                name: "Dep2.swift",
                content: "struct Dep2 {}"
            ),
            (
                name: "Main.swift",
                content: """
                struct Main {
                    let dep1: Dep1
                    let dep2: Dep2
                }
                """
            )
        ])
        
        let dep1URL = files[0]
        let dep2URL = files[1]
        let mainURL = files[2]
        
        let analyzer = DependencyAnalyzer(projectRoot: project.projectRoot)
        let dependencies = try analyzer.analyze(file: mainURL)
        
        #expect(TestHelpers.assertURLSetContains(dependencies, dep1URL))
        #expect(TestHelpers.assertURLSetContains(dependencies, dep2URL))
    }
    
    @Test("Circular dependency detection")
    func testCircularDependencies() async throws {
        let project = try MockProject()
        defer { try? project.cleanup() }
        
        let files = try project.withFiles([
            (
                name: "TypeA.swift",
                content: """
                struct TypeA {
                    let b: TypeB
                }
                """
            ),
            (
                name: "TypeB.swift",
                content: """
                struct TypeB {
                    let a: TypeA
                }
                """
            )
        ])
        
        let typeBURL = files[1]
        let typeAURL = files[0]
        
        let analyzer = DependencyAnalyzer(projectRoot: project.projectRoot)
        let dependencies = try analyzer.analyze(file: typeAURL)
        
        #expect(TestHelpers.assertURLSetContains(dependencies, typeBURL))
    }
}
