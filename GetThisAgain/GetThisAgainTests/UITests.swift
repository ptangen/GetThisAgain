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
        
        // sign in with bad username
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().enterText("invalid", intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText("invalid", intoViewWithAccessibilityLabel: "passwordField")
        tester().tapView(withAccessibilityLabel:"signInButton")
        tester().waitForView(withAccessibilityLabel: "signInView")
        
        // sign in with bad password
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().clearTextFromView(withAccessibilityLabel: "passwordField")
        tester().enterText(Secrets.userNameUITest1, intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText("invalid", intoViewWithAccessibilityLabel: "passwordField")
        tester().tapView(withAccessibilityLabel:"signInButton")
        tester().waitForView(withAccessibilityLabel: "signInView")
        
        // sign in with good credentials
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().clearTextFromView(withAccessibilityLabel: "passwordField")
        tester().enterText(Secrets.userNameUITest1, intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText(Secrets.passwordUITest1, intoViewWithAccessibilityLabel: "passwordField")
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
        tester().enterText("Tester1 item", intoViewWithAccessibilityLabel: "nameTextView")
        
        // add category
        tester().tapView(withAccessibilityLabel:"addCategoryButton")
        tester().tapView(withAccessibilityLabel:"cancelAddCategory")
        tester().waitForView(withAccessibilityLabel: "editNameViewInst")
        tester().tapView(withAccessibilityLabel:"addCategoryButton")
        tester().enterText("Tester1 category", intoViewWithAccessibilityLabel: "textField")
        tester().tapView(withAccessibilityLabel:"addCategory")
        // verify category was added
        let indexPath = IndexPath(row: 0, section: 0)
        if let newCategoryResults = tester().waitForCell(at: indexPath, inTableViewWithAccessibilityIdentifier: "categoryTableView") {
            tester().expect(newCategoryResults.textLabel, toContainText: "Tester1 category")
        }
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Next on right in nav bar
        tester().waitForView(withAccessibilityLabel: "itemDetailViewInst")
        
        // tap check on getAgainPicker
        let getAgainPicker = tester().waitForView(withAccessibilityLabel: "getAgainPicker")
        let checkButtonCenter = CGPoint(x: (getAgainPicker?.frame.maxX)! - 30, y: (getAgainPicker?.frame.minY)! + 80) // + 60 for nav
        tester().tapScreen(at: checkButtonCenter)
        
        // tap check on shoppingListSwitch
        let shoppingListSwitch = tester().waitForView(withAccessibilityLabel: "shoppingListSwitch")
        let shoppingListSwitchCenter = CGPoint(x: (shoppingListSwitch?.frame.maxX)! - 15, y: (shoppingListSwitch?.frame.minY)! + 80) // + 60 for nav
        tester().tapScreen(at: shoppingListSwitchCenter)
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Add Item on right in nav bar
        tester().waitForView(withAccessibilityLabel: "myItemsViewInst")
        
        // verify new item was added
        tester().tapView(withAccessibilityLabel:"tabShoppingList")
        tester().waitForView(withAccessibilityLabel: "shoppingListViewInst")
        tester().tapRow(at: indexPath, inTableViewWithAccessibilityIdentifier: "shoppingListTableView")
        tester().waitForView(withAccessibilityLabel: "itemDetailViewInst")
        let nameLabel = tester().waitForView(withAccessibilityLabel: "nameLabel")
        tester().expect(nameLabel, toContainText: "Tester1 item")
        let categoryLabel = tester().waitForView(withAccessibilityLabel: "categoryLabel")
        tester().expect(categoryLabel, toContainText: "Tester1 category")
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 50)) // tap Done on right in nav bar
        tester().waitForView(withAccessibilityLabel: "shoppingListViewInst")
        
        // so we have added an item with no image, created a category, marked the item as getAgain, added to shopping list
        // opened the shopping list, opened the new item and verified the name and cateogry, closed the item
        
        
    }
}
