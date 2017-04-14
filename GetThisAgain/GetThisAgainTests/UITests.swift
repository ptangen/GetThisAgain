//
//  UITests.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 4/14/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

import KIF

class UITests : KIFTestCase {
    
    func testNavigtion() {
        
        // sign in with bad credentials
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().enterText("swift33", intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText("1234", intoViewWithAccessibilityLabel: "passwordField")
        tester().tapView(withAccessibilityLabel:"signInButton")
        tester().waitForView(withAccessibilityLabel: "signInView")
        
        // sign in with good credentials
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().clearTextFromView(withAccessibilityLabel: "passwordField")
        tester().enterText("swift3", intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText("1234", intoViewWithAccessibilityLabel: "passwordField")
        tester().tapView(withAccessibilityLabel:"signInButton")
    }
}
