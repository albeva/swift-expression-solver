//
//  Token.swift
//  ExpressionSolver
//
//  Created by Albert Varaksin on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

/// Lexer splits the input into a stream of `Tokens`
public struct Token {
    /// Kind of the token
    public let kind: Kind
    
    /// Scanned text
    public let lexeme: String?
    
    init(kind: Kind, lexeme: String? = nil) {
        self.kind = kind
        self.lexeme = lexeme
    }
}

extension Token: CustomStringConvertible {
    public var description: String {
        return lexeme ?? kind.description
    }
}
