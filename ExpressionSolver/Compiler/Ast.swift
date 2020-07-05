//
//  Ast.swift
//  ExpressionSolver
//
//  Created by Albert Varaksin on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

// MARK: - Ast

/// Base type for all AST nodes
public protocol Ast {
    func accept(_: Visitor) throws
}

/// Base type for expression nodes
public protocol AstExpr: Ast {}

/// Literal number
public struct AstNumberExpr: AstExpr {
    public func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
    public let token: Token
}

/// Identifier expression. e.g. variable or a method name
/// support member identifiers like `foo.bar`
public struct AstIdentifierExpr: AstExpr {
    public func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
    public let members: [Token]
}

/// Binary operation in form of `lhs op rhs`
public struct AstBinaryExpr: AstExpr {
    public func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
    public let lhs: AstExpr
    public let rhs: AstExpr
    public let op: Token
}

/// Unary operation
public struct AstUnaryExpr: AstExpr {
    public func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
    public let expr: AstExpr
    public let op: Token
}

/// Call expression
public struct AstFuncCallExpr: AstExpr {
    public func accept(_ visitor: Visitor) throws {
        try visitor.visit(self)
    }
    public let ident: AstIdentifierExpr
    public let arguments: [AstExpr]
}

// MARK: - Visitor


/// Visitor can be used to traverse AST tree
public protocol Visitor: class {
    func visit(_ node: AstNumberExpr) throws
    func visit(_ node: AstIdentifierExpr) throws
    func visit(_ node: AstBinaryExpr) throws
    func visit(_ node: AstUnaryExpr) throws
    func visit(_ node: AstFuncCallExpr) throws
}
