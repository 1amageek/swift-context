//
//  VisitorContext.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation

/// A structure representing the combined context extracted by `DependencyVisitor` and `TypeReferenceVisitor`.
///
/// This structure consolidates information about imports, type references, extension targets,
/// protocols, inherited types, property types, function parameter types, and generic constraints
/// from a Swift source file.
public struct VisitorContext {
    
    /// The set of import paths found in the source file.
    public let imports: Set<String>
    
    /// The set of type references found in the source file.
    public let typeReferences: Set<String>
    
    /// The set of target types extended in the source file.
    public let extensionTargets: Set<String>
    
    /// The set of protocols declared in the source file.
    public let protocols: Set<String>
    
    /// The set of types inherited by classes, structs, or enums in the source file.
    public let inheritedTypes: Set<String>
    
    /// The set of types used in property declarations in the source file.
    public let propertyTypes: Set<String>
    
    /// The set of types used in function parameter declarations in the source file.
    public let functionParameterTypes: Set<String>
    
    /// The set of types referenced in generic constraints in the source file.
    public let genericConstraints: Set<String>
    
    /// Initializes a new `VisitorContext` by combining the results from dependency and type reference visitors.
    ///
    /// - Parameters:
    ///   - dependencyVisitor: A `DependencyVisitor` instance containing analyzed imports and dependencies.
    ///   - typeReferenceVisitor: A `TypeReferenceVisitor` instance containing analyzed type references.
    public init(dependencyVisitor: DependencyVisitor, typeReferenceVisitor: TypeReferenceVisitor) {
        self.imports = dependencyVisitor.imports
        self.typeReferences = dependencyVisitor.typeReferences
        self.extensionTargets = dependencyVisitor.extensionTargets
        self.protocols = dependencyVisitor.protocols
        self.inheritedTypes = typeReferenceVisitor.inheritedTypes
        self.propertyTypes = typeReferenceVisitor.propertyTypes
        self.functionParameterTypes = typeReferenceVisitor.functionParameterTypes
        self.genericConstraints = typeReferenceVisitor.genericConstraints
    }
    
    /// Combines all referenced types from different aspects of the source file.
    ///
    /// This includes type references, extension targets, inherited types, property types,
    /// function parameter types, and generic constraints.
    public var allReferencedTypes: Set<String> {
        return typeReferences
            .union(extensionTargets)
            .union(inheritedTypes)
            .union(propertyTypes)
            .union(functionParameterTypes)
            .union(genericConstraints)
    }
    
    /// Filters out commonly used system modules from the set of imports.
    ///
    /// - Returns: A set of imports excluding system modules such as `Swift`, `Foundation`, and others.
    public func filterSystemTypes() -> Set<String> {
        let systemModules = Set(["Swift", "Foundation", "UIKit", "SwiftUI", "Combine"])
        return imports.filter { !systemModules.contains($0) }
    }
}
