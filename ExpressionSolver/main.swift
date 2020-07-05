//
//  main.swift
//  ExpressionSolver
//
//  Created by Albert Varaksin on 29/06/2020.
//  Copyright © 2020 Albert Varaksin. All rights reserved.
//

import Foundation

func main() {
    let source = "2 - 3 * 4"
    let lexer = Lexer(source: source)
    let parser = Parser(lexer: lexer)
    let table = SymbolTable()

    do {
        let ast = try parser.parse()
        
        let printer = Printer()
        try ast.accept(printer)
        
        let calculator = Calculator(symbolTable: table)
        try ast.accept(calculator)
        
        print(printer.output, "=", calculator.output)
    } catch {
        print("error:", error.localizedDescription)
    }
}
main()
