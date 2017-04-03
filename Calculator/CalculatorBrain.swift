//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Omer Yetik on 05/09/16.
//  Copyright © 2016 Omer Yetik. All rights reserved.
//

import Foundation

func multiply(op1: Double, op2: Double) -> Double {
    return op1 * op2
}

class CalculatorBrain {
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    private var formatter: NSNumberFormatter {
        get {
            let formatter = NSNumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 6
            formatter.minimumIntegerDigits = 1
            return formatter
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
    }
    
    // Assignment #2, Required Task #4 (RT4)
    //
    var variableValues = [String:Double]() {
        // When variable values are updated, rerun the program...
        didSet {
            program = internalProgram
        }
    }
    
    func setOperand(variableName: String) {
        accumulator = variableValues[variableName] ?? 0.0
        internalProgram.append(variableName)
    }
    
    //
    
    // Assignment #1, Required Task #5
    //
    // Updated in Assignment #2 to adopt the "proram" mechanics in description as well.
    //
    var description: String {
        get {
            
            var partialDescriotion = ""
            var lastItem: String?
            
            for item in internalProgram {
                if let operand = item as? Double {
                    lastItem = formatter.stringFromNumber(operand)
                } else if let symbol = item as? String, operation = operations[symbol] {
                    switch operation {
                    case .Constant(let symbol, _):
                        lastItem = symbol
                    case .NullaryOperation(let symbol, _):
                        lastItem = nil
                        partialDescriotion += symbol + "(" + ")"
                    case .UnaryOperation(let symbol, _):
                        if lastItem != nil {
                            partialDescriotion += symbol + "(" + lastItem! + ")"
                            lastItem = nil
                        } else {
                            partialDescriotion = symbol + "(" + partialDescriotion + ")"
                        }
                    case .BinaryOperation(let symbol, _, let precedence):
                        partialDescriotion += (lastItem ?? "")
                        if partialDescriotion != "" {
                            if currentPrecedence < precedence {
                                partialDescriotion = "(" + partialDescriotion + ")"
                            }
                        }
                        partialDescriotion += " " + symbol + " "
                        currentPrecedence = precedence
                    case .Equals:
                        partialDescriotion += lastItem ?? ""
                        lastItem = nil
                    }
                } else {
                    print("Unable to process \(lastItem)")
                }
            }
            
            return partialDescriotion
        }
    }
    
    private var currentPrecedence = Int.max
    
    //
    
    // Assignment #1, Required Task #6
    //
    var isPartialResult: Bool {
        get {
            return !(pending == nil)
        }
    }
    //
    
    // Extensible table to keep operation list
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.Constant("π", M_PI),
        "e" : Operation.Constant("e", M_E),
        "±" : Operation.UnaryOperation("±", { -$0 }),
        "√" : Operation.UnaryOperation("√", sqrt),
        "cos" : Operation.UnaryOperation("cos", cos),
        "×" : Operation.BinaryOperation("×", { $0 * $1 }, 1),
        "÷" : Operation.BinaryOperation("÷", { $0 / $1 }, 1),
        "+" : Operation.BinaryOperation("+", { $0 + $1 }, 0),
        "−" : Operation.BinaryOperation("−", { $0 - $1 }, 0),
        "=" : Operation.Equals,
        // Assignment #1, Required Task #3, new operations added below
        //
        "x²": Operation.UnaryOperation("x²", { pow($0, 2) }),
        "x³": Operation.UnaryOperation("x³", { pow($0, 3) }),
        "x⁻¹": Operation.UnaryOperation("x⁻¹", { pow($0, -1) }),
        "10ˣ" : Operation.UnaryOperation("10ˣ", { pow(10, $0) }),
        "∛" : Operation.UnaryOperation("∛", { pow($0, 1/3) }),
        "sin" : Operation.UnaryOperation("sin", sin),
        "tan" : Operation.UnaryOperation("tan", tan),
        "cosh" : Operation.UnaryOperation("cosh", cosh),
        "sinh" : Operation.UnaryOperation("sinh", sinh),
        "tanh" : Operation.UnaryOperation("tanh", tanh),
        "ln" : Operation.UnaryOperation("log", log),
        "log₁₀" : Operation.UnaryOperation("log10", log10),
        "eˣ" : Operation.UnaryOperation("exp", exp),
        "xʸ" : Operation.BinaryOperation("pow", pow, 2),
        //
        // Assignment #1, Extra Task #4
        "rand" : Operation.NullaryOperation("rand", drand48)
    ]
    
    private enum Operation {
        case Constant(String, Double)
        case NullaryOperation(String, () -> Double)
        case UnaryOperation(String, (Double) -> Double)
        case BinaryOperation(String, (Double, Double) -> Double, Int)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(_, let value):
                accumulator = value
            case .NullaryOperation(_, let function):
                accumulator = function()
            case .UnaryOperation(_, let function):
                accumulator = function(accumulator)
            case .BinaryOperation(_, let function, _):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator)
            case .Equals :
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    // PropertyList declaration of program variable from Lecture #3
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram
        }
        set {
            clear()
            if let arrayOfOps = newValue as? [AnyObject] {
                for op in arrayOfOps {
                    if let operand = op as? Double {
                        setOperand(operand)
                    } else if let symbol = op as? String {
                        if operations[symbol] != nil {
                            performOperation(symbol)
                        } else if variableValues[symbol] != nil {
                            setOperand(symbol)
                        }
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
    
}
