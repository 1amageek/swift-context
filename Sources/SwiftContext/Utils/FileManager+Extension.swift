//
//  FileManager+Extension.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// An extension to `FileManager` providing utilities for handling Swift files and file metadata.
extension FileManager {
    
    /// Checks if a given URL represents a Swift source file.
    ///
    /// - Parameter url: The URL to check.
    /// - Returns: `true` if the URL points to a file with the `.swift` extension, otherwise `false`.
    func isSwiftFile(_ url: URL) -> Bool {
        return url.pathExtension == "swift"
    }
    
    /// Retrieves all Swift files in a specified directory (non-recursive).
    ///
    /// - Parameter directory: The directory URL to search in.
    /// - Returns: An array of URLs pointing to Swift files in the directory.
    /// - Throws: An error if the directory cannot be accessed.
    func swiftFiles(in directory: URL) throws -> [URL] {
        return try swiftFilesRecursively(in: directory)
    }
    
    /// Recursively retrieves all Swift files in a specified directory and its subdirectories.
    ///
    /// - Parameter directory: The root directory URL to start the search from.
    /// - Returns: An array of URLs pointing to all Swift files found recursively.
    /// - Throws: An error if a directory cannot be accessed.
    func swiftFilesRecursively(in directory: URL) throws -> [URL] {
        let keys: [URLResourceKey] = [.isRegularFileKey, .isDirectoryKey]
        let contents = try contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: keys,
            options: [.skipsHiddenFiles]
        )
        
        var results = [URL]()
        
        for url in contents {
            let resourceValues = try url.resourceValues(forKeys: Set(keys))
            
            if resourceValues.isDirectory == true {
                // Recursively search in subdirectories
                results.append(contentsOf: try swiftFilesRecursively(in: url))
            } else if resourceValues.isRegularFile == true && isSwiftFile(url) {
                // Add Swift files to the result
                results.append(url)
            }
        }
        
        return results
    }
    
    /// Retrieves the modification date of a specified file.
    ///
    /// - Parameter url: The URL of the file.
    /// - Returns: The modification date of the file.
    /// - Throws: An error if the file attributes cannot be retrieved.
    func modificationDate(of url: URL) throws -> Date {
        let attributes = try attributesOfItem(atPath: url.path)
        return attributes[.modificationDate] as? Date ?? Date()
    }
}
