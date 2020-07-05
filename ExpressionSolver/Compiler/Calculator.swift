//
//  Calculator.swift
//  ExpressionSolver
//
//  Created by Albert on 30/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

enum CalculatorError: Error {
    case undefined(String)
    case argumentCount(String)
    case logic(String)
}

extension CalculatorError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .undefined(let what):
            return "Undefined \(what)"
        case .argumentCount(let got):
            return "Invalid argument count. \(got)"
        case .logic(let what):
            return "Logic error: \(what)"
        }
    }
}


public final class Calculator: Visitor {
    public private(set) var output: Double = 0
    private let symbolTable: SymbolTable
    
    public init(symbolTable: SymbolTable) {
        self.symbolTable = symbolTable
    }
    
    public func visit(_ node: AstNumberExpr) {
        guard
            let lexeme = node.token.lexeme,
            let number = Double(lexeme)
        else {
            return
        }
        output = number
    }
    
    public func visit(_ node: AstIdentifierExpr) throws {
        let variable = node.members.map { $0.lexeme! }.joined(separator: ".")
        guard
            let symbol = try? symbolTable.get(name: variable),
            case .constant(let value) = symbol
        else {
            throw CalculatorError.undefined("identifier \(variable)")
        }
        output = value
    }
    
    public func visit(_ node: AstBinaryExpr) throws {
        try node.lhs.accept(self)
        let lhs = output
        
        try node.rhs.accept(self)
        let rhs = output
        
        switch node.op.kind {
        case .plus:
            output = lhs + rhs
        case .minus:
            output = lhs - rhs
        case .multiply:
            output = lhs * rhs
        case .divide:
            output = lhs / rhs
        case .exponent:
            output = pow(lhs, rhs)
        default:
            output = 0
        }
    }
    
    public func visit(_ node: AstUnaryExpr) throws {
        try node.expr.accept(self)
        switch node.op.kind {
        case .negate:
            output = -output
        case .factorial:
            output = try factorial(output)
        default:
            output = 0
        }
    }
    
    public func visit(_ node: AstFuncCallExpr) throws {
        let function = node.ident.members.map { $0.lexeme! }.joined(separator: ".")
        
        guard
            let symbol = try? symbolTable.get(name: function),
            case let .function(count, variadic, handler) = symbol
        else {
            throw CalculatorError.undefined("function \(function)")
        }
        
        if variadic, node.arguments.count < count {
            throw CalculatorError.argumentCount("\(function) expects at least \(count)")
        }
        
        if !variadic, node.arguments.count != count {
            throw CalculatorError.argumentCount("\(function) expects \(count)")
        }
        
        var arguments: [Double] = []
        for arg in node.arguments {
            try arg.accept(self)
            arguments.append(output)
        }
        
        output = handler(arguments)
    }
    
    private func factorial(_ n: Double) throws -> Double {
        if n < 1 {
            throw CalculatorError.logic("Factorial of negative!")
        }
        if n == 1 {
            return 1
        } else {
            return n * (try! factorial(n - 1))
        }
    }
}
