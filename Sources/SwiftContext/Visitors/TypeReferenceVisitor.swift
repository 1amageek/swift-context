//
//  TypeReferenceVisitor.swift
//  swift-context
//
//  Created by Norikazu Muramoto on 2025/01/17.
//

import Foundation
import SwiftSyntax

/// A syntax visitor that analyzes Swift source files to extract type references.
///
/// This visitor traverses the syntax tree of a Swift file and collects information about
/// inherited types, property types, function parameter types, and generic constraints.
public class TypeReferenceVisitor: SyntaxVisitor {
    
    /// A set of types inherited by classes, structs, or enums in the source file.
    public private(set) var inheritedTypes: Set<String> = []
    
    /// A set of types used in property declarations in the source file.
    public private(set) var propertyTypes: Set<String> = []
    
    /// A set of types used in function parameter declarations in the source file.
    public private(set) var functionParameterTypes: Set<String> = []
    
    /// A set of types referenced in generic constraints in the source file.
    public private(set) var genericConstraints: Set<String> = []
    
    /// Visits an inherited type syntax node and extracts the type name.
    ///
    /// - Parameter node: The `InheritedTypeSyntax` node representing an inherited type.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: InheritedTypeSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.type.trimmedDescription
        inheritedTypes.insert(typeName)
        return .skipChildren
    }
    
    /// Visits a variable declaration node and extracts the type of the variable.
    ///
    /// - Parameter node: The `VariableDeclSyntax` node representing a variable declaration.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        for pattern in node.bindings {
            if let typeAnnotation = pattern.typeAnnotation {
                let typeName = typeAnnotation.type.trimmedDescription
                propertyTypes.insert(typeName)
            }
        }
        return .visitChildren
    }
    
    /// Visits a function parameter syntax node and extracts the type of the parameter.
    ///
    /// - Parameter node: The `FunctionParameterSyntax` node representing a function parameter.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: FunctionParameterSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.type.trimmedDescription
        functionParameterTypes.insert(typeName)
        return .visitChildren
    }
    
    /// Visits a generic requirement syntax node and extracts the type references.
    ///
    /// - Parameter node: The `GenericRequirementSyntax` node representing a generic constraint.
    /// - Returns: The visitation strategy for the children of this node.
    public override func visit(_ node: GenericRequirementSyntax) -> SyntaxVisitorContinueKind {
        switch node.requirement {
        case .conformanceRequirement(let requirement):
            let typeName = requirement.rightType.trimmedDescription
            genericConstraints.insert(typeName)
        case .sameTypeRequirement(let requirement):
            let typeName = requirement.rightType.trimmedDescription
            genericConstraints.insert(typeName)
        default:
            break
        }
        return .skipChildren
    }
}
