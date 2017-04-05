//
//  ViewController.swift
//  Calculator
//
//  Created by Omer Yetik on 31/08/16.
//  Copyright © 2016 Omer Yetik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // Assignment #1, Extra Task #3 : NSNumberFormatter lines added
    private var formatter: NSNumberFormatter {
        get {
            let formatter = NSNumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 6
            formatter.minimumIntegerDigits = 1
            return formatter
        }
    }
    // 
    
    @IBOutlet private weak var display: UILabel!
    // Assignment #1, Required Task #6
    @IBOutlet weak var history: UILabel!
    //
    private var userIsInTheMiddleOfTyping = false
    
    // A computed property (Swift) to keep displayed value in Double
    // Assignment #1, Extra Task #2 : Changed to Optional
    // Assignment #1, Extra Task #3 : NSNumberFormatter lines added
    private var displayValue: Double? {
        get {
            if let text = display.text,
                value = formatter.numberFromString(text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                display.text = formatter.stringFromNumber(value)
                history.text = brain.description + (brain.isPartialResult ? " ..." : brain.description.characters.count > 0 ? " =" : " ")
            } else {
                display.text = "0"
                history.text = " "
            }
        }
    }
 
    @IBAction private func touchDigitButton(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            // Assignment #1: Required Task #1:
            // If the displayed number already has a "." and user entered a "." again, don't do anything.
            if !(digit == "." && (display.text!.rangeOfString(".") != nil)) {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            // Assignment #1: Required Task #1:
            // User just started entering a number. If it starts with a ".", append 0 at the beginning
            display.text = digit == "." ? "0." : digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    // Assignment #2, Required Task #8 (A2RT8)
    //
    // Button "→M" : sets the variable M to the displayed value
    @IBAction func setVariable(sender: AnyObject) {
        if userIsInTheMiddleOfTyping {
            brain.variableValues["M"] = displayValue
            userIsInTheMiddleOfTyping = false
            displayValue = brain.result
        }
    }
    
    
    // Button "M" : gets the value of the variable M
    @IBAction func getVariable(sender: AnyObject) {
        brain.setOperand("M")
        displayValue = brain.result
    }
    //
    
    // Assignment #1, Required Task #8 
    @IBAction private func clear() {
        brain.clear()
        // Assignment #1, Extra Task #2
        displayValue = nil
        // Assignment #2, Required Task #9 (A2RT9), Clear values for the variable M
        brain.variableValues["M"] = nil
        
    }
    
    // Assignment #1, Extra Task #1
    @IBAction func backSpace() {
        if userIsInTheMiddleOfTyping {
            if var text = display.text {
                text.removeAtIndex(text.endIndex.predecessor())
                if text.isEmpty {
                    text = "0"
                    userIsInTheMiddleOfTyping = false
                }
                display.text = text
            }
        } else { // Assignment #2, Required Task #10 (A2RT10) : Undo function
            if let lastNumberOperand = brain.undo() {
                displayValue = lastNumberOperand
                userIsInTheMiddleOfTyping = true
            } else {
                displayValue = brain.result
            }
        }
    }
}

