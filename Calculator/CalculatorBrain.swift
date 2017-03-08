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
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand)
        accumulatorDescription = String(format: "%g", operand)
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
        accumulatorDescription = variableName
    }
    
    //
    
    // Assignment #1, Required Task #5
    //
    var description: String {
        get {
            if pending == nil {
                return accumulatorDescription
            } else {
                return pending!.descriptionFunction(pending!.firstOperandDescription,
                                                    pending!.firstOperandDescription !=
                                                        accumulatorDescription ?
                                                            accumulatorDescription : "")
            }
        }
    }
    
    private var accumulatorDescription = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
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
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "±" : Operation.UnaryOperation({ -$0 }, { "-(" + $0 + ")" }),
        "√" : Operation.UnaryOperation(sqrt, { "√(" + $0 + ")" }),
        "cos" : Operation.UnaryOperation(cos, { "cos(" + $0 + ")" }),
        "×" : Operation.BinaryOperation({ $0 * $1 }, { $0 + " × " + $1 }, 1),
        "÷" : Operation.BinaryOperation({ $0 / $1 }, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.BinaryOperation({ $0 + $1 }, { $0 + " + " + $1 }, 0),
        "−" : Operation.BinaryOperation({ $0 - $1 }, { $0 + " − s" + $1 }, 0),
        "=" : Operation.Equals,
        // Assignment #1, Required Task #3, new operations added below
        //
        "x²": Operation.UnaryOperation({ pow($0, 2) }, { "(" + $0 + ")²" }),
        "x³": Operation.UnaryOperation({ pow($0, 3) }, { "(" + $0 + ")³" }),
        "x⁻¹": Operation.UnaryOperation({ pow($0, -1) }, { "(" + $0 + ")⁻¹" }),
        "10ˣ" : Operation.UnaryOperation({ pow(10, $0) }, { "10^(" + $0 + ")" }),
        "∛" : Operation.UnaryOperation({ pow($0, 1/3) }, { "∛(" + $0 + ")" }),
        "sin" : Operation.UnaryOperation(sin, { "sin(" + $0 + ")" }),
        "tan" : Operation.UnaryOperation(tan, { "tan(" + $0 + ")" }),
        "cosh" : Operation.UnaryOperation(cosh, { "cosh(" + $0 + ")" }),
        "sinh" : Operation.UnaryOperation(sinh, { "sinh(" + $0 + ")" }),
        "tanh" : Operation.UnaryOperation(tanh, { "tanh(" + $0 + ")" }),
        "ln" : Operation.UnaryOperation(log, { "ln(" + $0 + ")" }),
        "log₁₀" : Operation.UnaryOperation(log10, { "log(" + $0 + ")" }),
        "eˣ" : Operation.UnaryOperation(exp, { "e^(" + $0 + ")" }),
        "xʸ" : Operation.BinaryOperation(pow, { $0 + " ^ " + $1 }, 2),
        //
        // Assignment #1, Extra Task #4
        "rand" : Operation.NullaryOperation(drand48, "rand()")
    ]
    
    private enum Operation {
        case Constant(Double)
        case NullaryOperation(() -> Double, String)
        case UnaryOperation((Double) -> Double, (String) -> String)
        case BinaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case Equals
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol)
        if let operation = operations[symbol] {
            switch operation {
            case .Constant(let value):
                accumulator = value
                accumulatorDescription = symbol
            case .NullaryOperation(let function, let description):
                accumulator = function()
                accumulatorDescription = description
            case .UnaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                accumulatorDescription = descriptionFunction(accumulatorDescription)
            case .BinaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    accumulatorDescription = "(" + accumulatorDescription + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator, descriptionFunction: descriptionFunction, firstOperandDescription: accumulatorDescription)
            case .Equals :
                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            accumulatorDescription = pending!.descriptionFunction(pending!.firstOperandDescription, accumulatorDescription)
            pending = nil
        }
    }
    
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var firstOperandDescription: String
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
