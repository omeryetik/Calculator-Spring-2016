//
//  ViewController.swift
//  Calculator
//
//  Created by Omer Yetik on 31/08/16.
//  Copyright © 2016 Omer Yetik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    
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
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
}

