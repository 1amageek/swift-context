//
//  ContextError.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// An enumeration of errors that can occur during context generation or analysis.
public enum ContextError: LocalizedError {
    
    /// Error indicating that a specified file could not be found.
    case fileNotFound(URL)
    
    /// Error indicating an invalid or unrecognized module name.
    case invalidModule(String)
    
    /// Error indicating a syntax issue in the source file.
    case syntaxError(String)
    
    /// Error indicating that a required dependency could not be resolved.
    case dependencyNotFound(String)
    
    /// Error indicating that the generated context exceeds the allowed token limit.
    case tokenLimitExceeded(Int)
    
    /// A description of the error for display purposes.
    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let url):
            return "File not found: \(url.path)"
        case .invalidModule(let name):
            return "Invalid module name: \(name)"
        case .syntaxError(let details):
            return "Syntax error: \(details)"
        case .dependencyNotFound(let name):
            return "Dependency not found: \(name)"
        case .tokenLimitExceeded(let count):
            return "Token limit exceeded: \(count) tokens"
        }
    }
}
