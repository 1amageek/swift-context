//
//  DependencyVisitor.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation
import SwiftSyntax
import SwiftParser

/// A syntax visitor that analyzes Swift source files to extract dependencies.
///
/// This visitor traverses the syntax tree of a Swift file and collects information about
/// import statements, type references, extension targets, and protocol declarations.
public class DependencyVisitor: SyntaxVisitor {
    
    /// A set of unique import paths found in the source file.
    public private(set) var imports: Set<String> = []
    
    /// A set of unique type references found in the source file.
    public private(set) var typeReferences: Set<String> = []
    
    /// A set of target types extended in the source file.
    public private(set) var extensionTargets: Set<String> = []
    
    /// A set of protocols declared in the source file.
    public private(set) var protocols: Set<String> = []
    
    /// Visits an import declaration node and extracts the import path.
    ///
    /// - Parameter node: The `ImportDeclSyntax` node representing an import statement.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
        let importPath = node.path.description.trimmingCharacters(in: .whitespaces)
        imports.insert(importPath)
        return .skipChildren
    }
    
    /// Visits an identifier type node and extracts the type name.
    ///
    /// - Parameter node: The `IdentifierTypeSyntax` node representing a type identifier.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: IdentifierTypeSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.name.text.trimmingCharacters(in: .whitespaces)
        if !typeName.isEmpty && typeName != "Self" {
            typeReferences.insert(typeName)
        }
        return .visitChildren
    }
    
    /// Visits a member type node and extracts the type name.
    ///
    /// - Parameter node: The `MemberTypeSyntax` node representing a member type.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: MemberTypeSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.name.text.trimmingCharacters(in: .whitespaces)
        if !typeName.isEmpty {
            typeReferences.insert(typeName)
        }
        return .visitChildren
    }
    
    /// Visits an extension declaration node and extracts the target type being extended.
    ///
    /// - Parameter node: The `ExtensionDeclSyntax` node representing an extension declaration.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.extendedType.trimmedDescription
        extensionTargets.insert(typeName)
        return .visitChildren
    }
    
    /// Visits a protocol declaration node and extracts the protocol name.
    ///
    /// - Parameter node: The `ProtocolDeclSyntax` node representing a protocol declaration.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: ProtocolDeclSyntax) -> SyntaxVisitorContinueKind {
        let protocolName = node.name.text.trimmingCharacters(in: .whitespaces)
        protocols.insert(protocolName)
        return .visitChildren
    }
    
    /// Visits a type alias declaration node and extracts the aliased type name.
    ///
    /// - Parameter node: The `TypeAliasDeclSyntax` node representing a type alias declaration.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: TypeAliasDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.initializer.value.trimmedDescription
        typeReferences.insert(typeName)
        return .visitChildren
    }
}
