//
//  Printer.swift
//  ExpressionSolver
//
//  Created by Albert on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

public final class Printer: Visitor {
    public private(set) var output: String = ""
    
    public func visit(_ node: AstNumberExpr) {
        output += node.token.description
    }
    
    public func visit(_ node: AstIdentifierExpr) {
        output += node.members.map { $0.description }.joined(separator: ".")
    }
    
    public func visit(_ node: AstBinaryExpr) throws {
        try node.lhs.accept(self)
        output += " \(node.op.kind.description) "
        try node.rhs.accept(self)
    }
    
    public func visit(_ node: AstUnaryExpr) throws {
        if node.op.kind.isLeftAssociative {
            output += node.op.description
            try node.expr.accept(self)
        } else {
            try node.expr.accept(self)
            output += node.op.description
        }
    }
    
    public func visit(_ node: AstFuncCallExpr) throws {
        try node.ident.accept(self)
        output += "("
        var isFirst = true
        for arg in node.arguments {
            if isFirst {
                isFirst = false
            } else {
                output += ", "
            }
            try arg.accept(self)
        }
        output += ")"
    }

}
