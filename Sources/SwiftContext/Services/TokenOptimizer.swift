//
//  TokenOptimizer.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// A protocol defining the interface for token optimization.
///
/// Classes conforming to this protocol are responsible for optimizing the token count
/// of a given context string to fit within specified limits.
public protocol TokenOptimizing {
    /// Optimizes the given context string to fit within the token limit.
    ///
    /// - Parameter context: The context string to optimize.
    /// - Returns: An optimized context string.
    func optimize(_ context: String) -> String
}

/// A class that optimizes token count for a given context string.
///
/// This class applies various strategies, such as removing comments, reducing empty lines,
/// and summarizing long methods, to ensure the context fits within the specified token limit.
public final class TokenOptimizer: TokenOptimizing {
    
    /// The maximum number of tokens allowed in the optimized context.
    private let maxTokens: Int
    
    /// Initializes a new instance of `TokenOptimizer` with the specified token limit.
    ///
    /// - Parameter maxTokens: The maximum number of tokens allowed in the optimized context.
    ///                        Defaults to `8192`.
    public init(maxTokens: Int = 8192) {
        self.maxTokens = maxTokens
    }
    
    /// Optimizes the given context string to fit within the token limit.
    ///
    /// If the token count exceeds the limit, various optimization strategies are applied
    /// to reduce the token count.
    ///
    /// - Parameter context: The context string to optimize.
    /// - Returns: The optimized context string.
    public func optimize(_ context: String) -> String {
        let estimatedTokens = estimateTokenCount(context)
        
        if estimatedTokens <= maxTokens {
            return context
        }
        
        // Apply optimization strategies if the token count exceeds the limit
        return applyOptimizationStrategies(context)
    }
    
    /// Estimates the token count of the given text.
    ///
    /// This is a simple approximation based on the number of words in the text.
    /// Actual tokenization by a language model may differ.
    ///
    /// - Parameter text: The text to analyze.
    /// - Returns: The estimated token count.
    private func estimateTokenCount(_ text: String) -> Int {
        return text.split(separator: " ").count
    }
    
    /// Applies various optimization strategies to reduce the token count of the context.
    ///
    /// - Parameter context: The context string to optimize.
    /// - Returns: The optimized context string.
    private func applyOptimizationStrategies(_ context: String) -> String {
        var optimizedContext = context
        
        // Strategy 1: Remove comments
        optimizedContext = removeComments(optimizedContext)
        
        // Strategy 2: Optimize empty lines
        optimizedContext = optimizeEmptyLines(optimizedContext)
        
        // Strategy 3: Summarize long methods (placeholder implementation)
        optimizedContext = summarizeLongMethods(optimizedContext)
        
        return optimizedContext
    }
    
    /// Removes comments from the given text.
    ///
    /// Both single-line and multi-line comments are removed.
    ///
    /// - Parameter text: The text to process.
    /// - Returns: The text without comments.
    private func removeComments(_ text: String) -> String {
        // Remove single-line comments
        var result = text.replacingOccurrences(
            of: "//[^\n]*\n",
            with: "\n",
            options: .regularExpression
        )
        
        // Remove multi-line comments
        result = result.replacingOccurrences(
            of: "/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/",
            with: "",
            options: .regularExpression
        )
        
        return result
    }
    
    /// Reduces consecutive empty lines to a maximum of one.
    ///
    /// - Parameter text: The text to process.
    /// - Returns: The text with optimized empty lines.
    private func optimizeEmptyLines(_ text: String) -> String {
        return text.replacingOccurrences(
            of: "\n{3,}",
            with: "\n\n",
            options: .regularExpression
        )
    }
    
    /// Summarizes long methods in the given text.
    ///
    /// This is a placeholder method for summarizing methods based on their length.
    /// Actual implementation is not yet provided.
    ///
    /// - Parameter text: The text to process.
    /// - Returns: The text with summarized methods.
    private func summarizeLongMethods(_ text: String) -> String {
        // TODO: Implement logic to summarize long methods based on their length.
        return text
    }
}
