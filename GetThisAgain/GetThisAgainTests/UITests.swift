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
        
        // set my items as the current tab
        UserDefaults.standard.setValue(false, forKey: "mostRecentTabIsShoppingList")
        
        // sign in with bad credentials
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().enterText("invalid", intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText("invalid", intoViewWithAccessibilityLabel: "passwordField")
        tester().tapView(withAccessibilityLabel:"signInButton")
        tester().waitForView(withAccessibilityLabel: "signInView")
        
        // sign in with good credentials
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().clearTextFromView(withAccessibilityLabel: "passwordField")
        tester().enterText(Secrets.userNameUITest, intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText(Secrets.passwordUITest, intoViewWithAccessibilityLabel: "passwordField")
        tester().tapView(withAccessibilityLabel:"signInButton")
        tester().waitForView(withAccessibilityLabel: "myItemsViewInst")
        
        // My Items and Shopping list tabs
        tester().tapView(withAccessibilityLabel:"tabShoppingList")
        tester().waitForView(withAccessibilityLabel: "shoppingListViewInst")
        tester().tapView(withAccessibilityLabel:"tabMyItems")
        tester().waitForView(withAccessibilityLabel: "myItemsViewInst")
        
        // add an item with no image
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Add on right in nav bar
        tester().waitForView(withAccessibilityLabel: "captureItemViewInst")
        tester().tapScreen(at: CGPoint(x: 40, y: 50)) // tap Cancel on left in nav bar
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Add on right in nav bar
        tester().waitForView(withAccessibilityLabel: "captureItemViewInst")
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Continue on right in nav bar
        tester().waitForView(withAccessibilityLabel: "editNameViewInst")
        tester().enterText("AAAA item", intoViewWithAccessibilityLabel: "nameTextView")
        
        // add category
        tester().tapView(withAccessibilityLabel:"addCategoryButton")
        tester().tapView(withAccessibilityLabel:"cancelAddCategory")
        tester().waitForView(withAccessibilityLabel: "editNameViewInst")
        tester().tapView(withAccessibilityLabel:"addCategoryButton")
        tester().enterText("AAAA category", intoViewWithAccessibilityLabel: "textField")
        tester().tapView(withAccessibilityLabel:"addCategory")
        // verify category was added
        let indexPath = IndexPath(row: 0, section: 0)
        if let newCategoryResults = tester().waitForCell(at: indexPath, inTableViewWithAccessibilityIdentifier: "categoryTableView") {
            tester().expect(newCategoryResults.textLabel, toContainText: "AAAA category")
        }
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Next on right in nav bar
        tester().waitForView(withAccessibilityLabel: "itemDetailViewInst")
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Add Item on right in nav bar
        tester().waitForView(withAccessibilityLabel: "myItemsViewInst")
        // verify new item was added
//        if let newItemResults = tester().waitForCell(at: indexPath, inTableViewWithAccessibilityIdentifier: "myItemsTableView") {
//            tester().expect(newItemResults, toContainText: "AAAA item")
//        }
        
    }
}
