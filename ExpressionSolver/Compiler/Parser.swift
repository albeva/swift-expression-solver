//
//  Parser.swift
//  ExpressionSolver
//
//  Created by Albert Varaksin on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case expected(String)
    case unexpected(String)
}

extension ParseError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .expected(let what):
            return "Parse failed. Expected: \(what)"
        case .unexpected(let what):
            return "Unexpected input. Found \(what)"
        }
    }
}

/// Parse stream of tokens into an AST tree
public final class Parser {
    
    /// Lexer iterator provides a stream of tokens
    private var iterator: Lexer.Iterator
    
    /// Current token being parsed
    private var current: Token?
    
    /// Create instance of Parser
    /// - Parameter lexer: lexer that provide token stream to parse
    public init(lexer: Lexer) {
        self.iterator = lexer.makeIterator()
        self.current = iterator.next()
    }
    
    // MARK: - Parse
    
    /// Parse token stream and return Ast tree
    /// 
    /// - Throws: `ParseError`
    /// - Returns: ast tree of the parsed content
    public func parse() throws -> Ast {
        let expr = try expression()
        if let current = current {
            throw ParseError.unexpected(current.description)
        }
        return expr
    }
}

// MARK: - Parse expression

private extension Parser {
    
    /// Expr = Factor { BinaryOperator Expr } .
    func expression() throws -> AstExpr {
        let lhs = try factor()
        return try expression(lhs: lhs, precedence: 1)
    }
    
    /// Use operator precedence algorith
    func expression(lhs: AstExpr, precedence: Int) throws -> AstExpr {
        var left = lhs
        while let current = current, current.kind.precedence >= precedence {
            let op = current
            move()
            var right = try factor()
            
            while let next = self.current, next.kind.isBinaryOperator {
                guard
                    next.kind.precedence > current.kind.precedence ||
                    (next.kind.isRightAssociative && next.kind.precedence == current.kind.precedence)
                else {
                    break
                }
                right = try expression(lhs: right, precedence: next.kind.precedence)
            }
            
            left = AstBinaryExpr(
                lhs: left,
                rhs: right,
                op: op
            )
        }
        return left
    }
    
    /// Factor = Primary [ "!" ]
    func factor() throws -> AstExpr {
        let lhs = try primary()
        
        // we only care for unary operator
        guard let current = current, current.kind.isUnaryOperator else {
            return lhs
        }
        
        // must be right associative
        guard current.kind.isRightAssociative else {
            throw ParseError.unexpected(current.description)
        }
        
        move()
        
        return AstUnaryExpr(expr: lhs, op: current)
    }
    
    /// Primary = Number
    ///         | Identifier
    ///         | FuncCall
    ///         | "(" Expr ")"
    ///         | "-" Primary
    func primary() throws -> AstExpr {
        guard let current = current else {
            throw ParseError.expected("expression")
        }
        
        switch current.kind {
        case .number:
            return try number()
            
        case .identifier:
            let id = try identifier()
            if !accept(.openParen) {
                return id
            }
            
            let args: [AstExpr]
            if !match(.closeParen) {
                args = try argumentList()
            } else {
                args = []
            }
            try expect(.closeParen)
            
            return AstFuncCallExpr(
                ident: id,
                arguments: args
            )
            
        case .openParen:
            move()
            let expr = try expression()
            try expect(.closeParen)
            return expr
            
        case .minus:
            move()
            let rhs = try primary()
            return AstUnaryExpr(
                expr: rhs,
                op: Token(kind: .negate)
            )
            
        default:
            if current.kind.isUnaryOperator, current.kind.isLeftAssociative {
                move()
                return AstUnaryExpr(expr: try primary(), op: current)
            }
            throw ParseError.unexpected(current.description)
        }
    }
    
    /// Number = NumberLiteral
    func number() throws -> AstNumberExpr {
        let number = try expect(.number)
        return AstNumberExpr(token: number)
    }
    
    /// Identifier = id { "." id }
    func identifier() throws -> AstIdentifierExpr {
        var members: [Token] = []
        
        repeat {
            let identifier = try expect(.identifier)
            members.append(identifier)
        } while accept(.period)
        
        return AstIdentifierExpr(members: members)
    }
    
    /// ArgumentList = [ Expr {"," Expr } ]
    func argumentList() throws -> [AstExpr] {
        var args = [AstExpr]()
        repeat {
            args.append(try expression())
        } while accept(.comma)
        return args
    }
}

// MARK: - Helper methods

private extension Parser {
    
    /// Move current position to the next token
    private func move() {
        current = iterator.next()
    }
    
    /// Expect current token to match kind, otherwise throw error
    ///
    /// When matched will move to the next token and return current one
    ///
    /// - Parameter kind: token kind to match
    /// - Throws: `ParseError.expected`
    /// - Returns: Current token
    @discardableResult func expect(_ kind: Kind) throws -> Token {
        guard let current = current, current.kind == kind else {
            throw ParseError.expected(kind.description)
        }
        move()
        return current
    }
    
    /// Check if current token matches given token kind
    ///
    /// - Parameter kind: kind to check
    /// - Returns: true if it is a match
    func match(_ kind: Kind) -> Bool {
        return current?.kind == kind
    }
    
    /// If given token kind matches the current token, then move to the next
    /// position and return true
    ///
    /// - Parameter kind: token kind to check
    /// - Returns: true if matched, false otherwise
    @discardableResult func accept(_ kind: Kind) -> Bool {
        guard match(kind) else {
            return false
        }
        move()
        return true
    }
}
