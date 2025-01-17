import Testing
import Foundation
@testable import SwiftContext

// MARK: - MockProject
public final class MockProject {
    
    public let projectRoot: URL
    public let sourcesDir: URL
    public let moduleName: String
    public let moduleDir: URL
    
    private let fileManager: FileManager
    private let uniqueIdentifier: String
    
    public init(moduleName: String = "TestModule") throws {
        self.fileManager = FileManager.default
        self.moduleName = moduleName
        self.uniqueIdentifier = UUID().uuidString
        
        // プロジェクト構造の設定
        let basePath = fileManager.temporaryDirectory
            .appendingPathComponent("SwiftContextTests")
            .appendingPathComponent(uniqueIdentifier)
            .standardized
        
        projectRoot = basePath.appendingPathComponent("TestProject").standardized
        sourcesDir = projectRoot.appendingPathComponent("Sources").standardized
        moduleDir = sourcesDir.appendingPathComponent(moduleName).standardized
        
        // 以前のテストファイルが残っている可能性があるため、cleanup を先に実行
        try? cleanup()
        
        // プロジェクト構造の作成
        try fileManager.createDirectory(at: moduleDir, withIntermediateDirectories: true, attributes: nil)
    }
    
    public func createFile(name: String, content: String) throws -> URL {
        let fileURL = moduleDir.appendingPathComponent(name).standardized
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }
    
    public func createFiles(_ files: [(name: String, content: String)]) throws -> [URL] {
        try files.map { try createFile(name: $0.name, content: $0.content) }
    }
    
    public func fileExists(at url: URL) -> Bool {
        fileManager.fileExists(atPath: url.standardized.path)
    }
    
    public func cleanup() throws {
        // プロジェクトのルートディレクトリだけでなく、親ディレクトリまで削除
        let basePath = projectRoot.deletingLastPathComponent()
        if fileManager.fileExists(atPath: basePath.path) {
            try fileManager.removeItem(at: basePath)
        }
    }
    
    deinit {
        try? cleanup()
    }
}

// MARK: - Test Extensions
extension MockProject {
    public static func createForTest() throws -> MockProject {
        try MockProject()
    }
    
    public func withFiles(_ files: [(name: String, content: String)]) throws -> [URL] {
        try createFiles(files)
    }
    
    public func withFile(name: String, content: String) throws -> URL {
        try createFile(name: name, content: content)
    }
}

// MARK: - Test Helpers
public struct TestHelpers {
    public static func assertURLsEqual(_ url1: URL, _ url2: URL) -> Bool {
        let standardized1 = url1.standardized.resolvingSymlinksInPath()
        let standardized2 = url2.standardized.resolvingSymlinksInPath()
        return standardized1 == standardized2
    }
    
    public static func assertURLSetContains(_ set: Set<URL>, _ url: URL) -> Bool {
        let standardizedUrl = url.standardized.resolvingSymlinksInPath()
        let standardizedSet = Set(set.map { $0.standardized.resolvingSymlinksInPath() })
        return standardizedSet.contains(standardizedUrl)
    }
}
