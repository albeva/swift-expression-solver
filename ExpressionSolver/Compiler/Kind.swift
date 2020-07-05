//
//  Kind.swift
//  ExpressionSolver
//
//  Created by Albert Varaksin on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

/// Kinds of token that `Lexer` can recognize
public enum Kind: CaseIterable {
    /// Number literal
    case number
    /// Identifier
    case identifier
    /// + operator
    case plus
    /// - operator
    case minus
    /// * operator
    case multiply
    /// / operator
    case divide
    /// ^ operator
    case exponent
    /// - operator
    case negate
    /// ! operator
    case factorial
    /// , argument separator
    case comma
    /// . period
    case period
    /// ( opening parentheses
    case openParen
    /// ) closing parentheses
    case closeParen
    /// Invalid token
    case invalid
}

// MARK: - Operators
public extension Kind {
    
    /// Return true if token kind represents a mathematical
    /// operator
    var isOperator: Bool {
        switch self {
        case .plus,
             .minus,
             .multiply,
             .divide,
             .exponent,
             .negate,
             .factorial:
            return true
        default:
            return false
        }
    }
    
    /// Return true if operator is right associative
    ///
    /// Some operators stick more to one side of the expression than
    /// the other.
    ///
    /// e.g. `(2 + 3 + 4)` vs `(2 ^ 3 ^ 4)`
    ///
    /// is evaluated as `((2 + 3) + 4)` vs `(2 ^ (3 ^ 4))`
    var isRightAssociative: Bool {
        switch self {
        case .exponent, .factorial:
            return true
        default:
            return false
        }
    }
    
    /// Inverse of `isRightAssociative`
    var isLeftAssociative: Bool {
        switch self {
        case .plus, .minus, .multiply, .divide, .negate:
            return true
        default:
            return false
        }
    }
    
    /// Precedence level
    ///
    /// Higher the level, sooner it is evaluated.
    ///
    /// E.g. in expression `(2 + 3 * 4)` multiplication needs
    /// to happen first. This operator * shoudl have higher precedence
    var precedence: Int {
        switch self {
        case .plus, .minus:
            return 1
        case .multiply, .divide:
            return 2
        case .exponent:
            return 3
        case .negate, .factorial:
            return 4
        default:
            return 0
        }
    }
    
    /// Is binary or unary operator
    ///
    /// In expression `(2 + -x)` + is a binary operator, whereas
    /// - is a unary operator applying only to `x`
    var isBinaryOperator: Bool {
        switch self {
        case .plus, .minus, .multiply, .divide, .exponent:
            return true
        default:
            return false
        }
    }
    
    /// Inverse of `isBinaryOperator`
    var isUnaryOperator: Bool {
        switch self {
        case .negate, .factorial:
            return true
        default:
            return false
        }
    }

}

extension Kind {
    init?(character: Character) {
        let string = String(character)
        guard let kind = (Self.allCases.first { $0.description == string }) else {
            return nil
        }
        self = kind
    }
}

extension Kind: CustomStringConvertible {
    public var description: String {
        switch self {
        case .number:
            return "<number>"
        case .identifier:
            return "<identifier>"
        case .plus:
            return "+"
        case .minus:
            return "-"
        case .multiply:
            return "*"
        case .divide:
            return "/"
        case .exponent:
            return "^"
        case .negate:
            return "-"
        case .factorial:
            return "!"
        case .comma:
            return ","
        case .period:
            return "."
        case .openParen:
            return "("
        case .closeParen:
            return ")"
        case .invalid:
            return "<invalid>"
        }
    }
}
