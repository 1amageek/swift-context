//
//  FrontMatter.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// A structure representing the metadata (front matter) of a Swift source file.
///
/// This includes information about the file name, its module, its dependencies, and the last updated timestamp.
public struct FrontMatter: Codable {
    
    /// The name of the file.
    public let file: String
    
    /// The name of the module to which the file belongs.
    public let module: String
    
    /// A list of dependencies for the file.
    public let dependencies: [String]
    
    /// The last modification date of the file.
    public let updatedAt: Date
    
    /// A formatted string representation of the front matter in YAML-like format.
    ///
    /// This is useful for inclusion in the output of tools or logs.
    public var formatted: String {
        """
        ---
        file: \(file)
        module: \(module)
        dependencies:
          - \(dependencies.joined(separator: "\n  - "))
        updated_at: \(updatedAt.ISO8601Format())
        ---
        """
    }
}
