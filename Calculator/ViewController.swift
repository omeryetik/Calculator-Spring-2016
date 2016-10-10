//
//  ViewController.swift
//  Calculator
//
//  Created by Omer Yetik on 31/08/16.
//  Copyright © 2016 Omer Yetik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    private struct Constants {
        static let DecimalDigits = 6
    }
    
    @IBOutlet private weak var display: UILabel!
    // Assignment #1, Required Task #6
    @IBOutlet weak var history: UILabel!
    //
    private var userIsInTheMiddleOfTyping = false

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
        }
        userIsInTheMiddleOfTyping = true
    }
    
    // A computed property (Swift) to keep displayed value in Double
    // Assignment #1, Extra Task #2 : Changed to Optional
    // Assignment #1, Extra Task #3 : NSNumberFormatter lines added
    private var displayValue: Double? {
        get {
            if let text = display.text,
                value = NSNumberFormatter().numberFromString(text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .DecimalStyle
                formatter.maximumFractionDigits = Constants.DecimalDigits
                display.text = formatter.stringFromNumber(value)
                history.text = brain.description + (brain.isPartialResult ? " ..." : " =")
            } else {
                display.text = "0"
                history.text = " "
            }
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
    
    // Assignment #1, Required Task #8 
    @IBAction private func clear() {
        brain = CalculatorBrain()
        display.text = "0"
        history.text = " "
        // Assignment #1, Extra Task #2
        displayValue = nil
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
        }
    }
}

