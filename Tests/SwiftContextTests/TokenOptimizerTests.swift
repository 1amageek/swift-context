import Testing
import Foundation
@testable import SwiftContext

struct TokenOptimizerTests {
    struct TestTokenOptimizer: TokenOptimizing {
        let maxTokens: Int
        
        init(maxTokens: Int = 100) {
            self.maxTokens = maxTokens
        }
        
        func optimize(_ context: String) -> String {
            var result = context
            
            // コメントを削除
            result = result.replacingOccurrences(
                of: "//[^\n]*\n",
                with: "\n",
                options: .regularExpression
            )
            result = result.replacingOccurrences(
                of: "/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/",
                with: "",
                options: .regularExpression
            )
            
            // トークン数を制限
            let words = result.split(separator: " ")
            if words.count > maxTokens {
                return words.prefix(maxTokens).joined(separator: " ")
            }
            
            return result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    @Test("No optimization needed for small content")
    func testNoOptimizationNeeded() {
        let optimizer = TestTokenOptimizer(maxTokens: 100)
        let content = "This is a small content"
        let optimized = optimizer.optimize(content)
        
        #expect(optimized == content)
    }
    
    @Test("Content is optimized when exceeds token limit")
    func testContentOptimization() {
        let optimizer = TestTokenOptimizer(maxTokens: 5)
        let content = "This is a longer content that needs optimization"
        let optimized = optimizer.optimize(content)
        
        let tokens = optimized.split(separator: " ")
        #expect(tokens.count <= 5, "Optimized content should not exceed token limit")
    }
    
    @Test("Remove comments while preserving code")
    func testRemoveComments() {
        let optimizer = TestTokenOptimizer(maxTokens: 10)
        let content = """
        // This is a comment
        let x = 1
        /* This is a
           multiline comment */
        let y = 2
        """
        
        let optimized = optimizer.optimize(content)
        
        #expect(!optimized.contains("// This is a comment"))
        #expect(!optimized.contains("/* This is a"))
        #expect(optimized.contains("let x = 1"))
        #expect(optimized.contains("let y = 2"))
    }
}
