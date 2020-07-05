//
//  Lexer.swift
//  ExpressionSolver
//
//  Created by Albert Varaksin on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

public final class Lexer: Sequence {
    public typealias Index = String.Index
    
    public let source: String
    
    public init(source: String) {
        self.source = source
    }
    
    public func makeIterator() -> LexerIterator {
        return LexerIterator(lexer: self)
    }
}

public final class LexerIterator: IteratorProtocol {
    private let lexer: Lexer
    private var index: Lexer.Index
    
    public init(lexer: Lexer) {
        self.lexer = lexer
        self.index = lexer.source.startIndex
    }
    
    private var current: Character? {
        return index < lexer.source.endIndex ? lexer.source[index] : nil
    }
    
    private var peek: Character? {
        let next = lexer.source.index(after: index)
        return next < lexer.source.endIndex ? lexer.source[next] : nil
    }
    
    private func move() {
        index = lexer.source.index(after: index)
    }
    
    public func next() -> Token? {
        while let char = current {
            if char.isWhitespace {
                move()
                continue
            }
            
            if char.isNumber {
                return number()
            }
            
            if char == ".", peek?.isNumber == true {
                return number()
            }
            
            if char.isLetter {
                return identifier()
            }
            
            if let kind = Kind(character: char) {
                return token(kind: kind)
            }
            
            // invalid token
            return token(kind: .invalid, lexeme: String(char))
        }
        return nil
    }
    
    private func token(kind: Kind, lexeme: String? = nil) -> Token {
        move()
        return Token(kind: kind, lexeme: lexeme)
    }
    
    private func number() -> Token {
        let start = index
        
        var decimal = false
        while let char = current {
            if !char.isNumber {
                if char == ".", decimal == false {
                    decimal = true
                } else {
                    break
                }
            }
            move()
        }
        
        let range = start ..< index
        let number = lexer.source[range]
        return Token(kind: .number, lexeme: String(number))
    }
    
    private func identifier() -> Token {
        let start = index
        move()
        
        while let char = current {
            guard char.isLetter || char.isNumber else {
                break
            }
            move()
        }
        
        let range = start ..< index
        let id = lexer.source[range]
        return Token(kind: .identifier, lexeme: String(id))
    }
}
