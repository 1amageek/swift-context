//
//  FileContext.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// A structure representing the context of a Swift source file, including its metadata and content.
public struct FileContext {
    
    /// The URL of the source file.
    public let url: URL
    
    /// The content of the source file as a string.
    public let content: String
    
    /// The front matter metadata associated with the source file.
    public let frontMatter: FrontMatter
    
    /// A formatted representation of the file's content, including its front matter.
    ///
    /// This combines the front matter and the source file content, separated by a blank line.
    public var formattedContent: String {
        return """
        \(frontMatter.formatted)
        
        \(content)
        """
    }
}
