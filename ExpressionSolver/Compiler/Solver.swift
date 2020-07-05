//
//  Solver.swift
//  ExpressionSolver
//
//  Created by Albert on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

public final class Printer: Visitor {
    public func visit(_ node: AstLiteralExpr) {
        print(node.token.kind.description)
    }
    
    public func visit(_ node: AstIdentExpr) {
        print(node.tokens.map { $0.kind.description }.joined(separator: "."))
    }
    
    public func visit(_ node: AstBinaryExpr) {
        
    }
    
    public func visit(_ node: AstUnaryExpr) {
        
    }
    
    public func visit(_ node: AstCallExpr) {
        
    }
    
    public func visit(_ node: AstArgumentList) {
        
    }
}
