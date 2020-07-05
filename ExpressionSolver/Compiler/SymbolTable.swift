//
//  SymbolTable.swift
//  ExpressionSolver
//
//  Created by Albert on 30/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

/// Type of the sumbol
public enum Symbol {
    /// Simple constant e.g `pi`
    case constant(value: Double)
    
    /// Callable function.
    ///
    /// - Parameters:
    ///   - count: number of parameters
    ///   - variadic: if true then `count` is simply minimum required
    ///   - handler: function callback handler
    case function(count: Int, variadic: Bool = false, handler: ([Double]) -> Double)
}

enum SymbolError: Error {
    case symbolNotFound(String)
    case redeclarionOf(String)
}

public final class SymbolTable {
    /// Hold our symbols
    private var table: [String: Symbol]
    
    init() {
        table = [
            "pi": .constant(value: Double.pi),
            
            "round": .function(count: 1) {
                return round($0[0])
            },
            
            "ceil": .function(count: 1) {
                return ceil($0[0])
            },
            
            "floor": .function(count: 1) {
                return floor($0[0])
            },
            
            "pow": .function(count: 2) {
                return pow($0[0], $0[1])
            },
            
            "sqrt": .function(count: 1) {
                return sqrt($0[0])
            },
            
            "min": .function(count: 2, variadic: true) {
                var minimum = $0[0]
                for param in $0[1...] {
                    minimum = min(minimum, param)
                }
                return minimum
            },
            
            "max": .function(count: 2, variadic: true) {
                var maximum = $0[0]
                for param in $0[1...] {
                    maximum = max(maximum, param)
                }
                return maximum
            }
        ]
    }
    
    public func add(name: String, symbol: Symbol) throws {
        guard table[name] == nil else {
            throw SymbolError.redeclarionOf(name)
        }
        table[name] = symbol
    }
    
    public func get(name: String) throws -> Symbol {
        guard let symbol = table[name] else {
            throw SymbolError.symbolNotFound(name)
        }
        return symbol
    }
}
