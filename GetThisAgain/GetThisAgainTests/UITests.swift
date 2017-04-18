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
    
    func testCreateItemsAndShareLists() {
        
        // set my items as the current tab
        UserDefaults.standard.setValue(false, forKey: "mostRecentTabIsShoppingList")
        
        // sign in with bad username
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().enterText("invalid", intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText("invalid", intoViewWithAccessibilityLabel: "passwordField")
        tester().waitForTappableView(withAccessibilityLabel: "signInButton")
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
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Add on right in nav bar
        tester().waitForView(withAccessibilityLabel: "captureItemViewInst")
        tester().tapScreen(at: CGPoint(x: 40, y: 50)) // tap Cancel on left in nav bar
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Add on right in nav bar
        tester().waitForView(withAccessibilityLabel: "captureItemViewInst")
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Continue on right in nav bar
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
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Next on right in nav bar
        tester().waitForView(withAccessibilityLabel: "itemDetailViewInst")
        
        // tap check on getAgainPicker
        let getAgainPicker = tester().waitForView(withAccessibilityLabel: "getAgainPicker")
        let checkButtonCenter = CGPoint(x: (getAgainPicker?.frame.maxX)! - 30, y: (getAgainPicker?.frame.minY)! + 80) // + 60 for nav
        tester().tapScreen(at: checkButtonCenter)
        
        // enable on shoppingListSwitch
        let shoppingListSwitch1 = tester().waitForView(withAccessibilityLabel: "shoppingListSwitch")
        let shoppingListSwitch1Center = CGPoint(x: (shoppingListSwitch1?.frame.maxX)! - 15, y: (shoppingListSwitch1?.frame.minY)! + 80) // + 60 for nav
        tester().tapScreen(at: shoppingListSwitch1Center)
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Add Item on right in nav bar
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
        
        // invite User2 to view shopping list.
        tester().tapScreen(at: CGPoint(x: 40, y: 50)) // tap menu button in nav bar
        tester().tapView(withAccessibilityLabel: "Sharing Shopping Lists") // accessibilityLabel provided automatically
        tester().waitForView(withAccessibilityLabel: "sharingStatusViewInst")
        tester().tapView(withAccessibilityLabel: "tabInvitation")
        tester().waitForView(withAccessibilityLabel: "sharingInvitationViewInst")
        
        tester().tapView(withAccessibilityLabel: "addInvitationButton")
        tester().enterText("nobody", intoViewWithAccessibilityLabel: "textField")
        tester().tapView(withAccessibilityLabel:"cancelInvitation")
        
        tester().tapView(withAccessibilityLabel: "addInvitationButton")
        tester().enterText("tester2", intoViewWithAccessibilityLabel: "textField")
        tester().tapView(withAccessibilityLabel:"sendInvitation")
        if let newInvitations = tester().waitForCell(at: indexPath, inTableViewWithAccessibilityIdentifier: "invitationsTableView") {
            tester().expect(newInvitations.textLabel, toContainText: "tester2")
        }
        tester().tapRow(at: indexPath, inTableViewWithAccessibilityIdentifier: "invitationsTableView")
        tester().tapView(withAccessibilityLabel: "deleteInvitationButton")
        tester().tapView(withAccessibilityLabel:"cancelDeleteInvitation")
        tester().tapView(withAccessibilityLabel: "deleteInvitationButton")
        tester().tapView(withAccessibilityLabel:"confirmDeleteInvitation")
        if let newInvitations = tester().waitForCell(at: indexPath, inTableViewWithAccessibilityIdentifier: "invitationsTableView") {
            tester().expect(newInvitations.textLabel, toContainText: "No pending invitations found.")
        }
        tester().tapView(withAccessibilityLabel: "addInvitationButton")
        tester().enterText("tester2", intoViewWithAccessibilityLabel: "textField")
        tester().tapView(withAccessibilityLabel:"sendInvitation")
        if let newInvitations = tester().waitForCell(at: indexPath, inTableViewWithAccessibilityIdentifier: "invitationsTableView") {
            tester().expect(newInvitations.textLabel, toContainText: "tester2")
        }
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Done on right in nav bar
        tester().waitForView(withAccessibilityLabel: "shoppingListViewInst")
        tester().tapScreen(at: CGPoint(x: 40, y: 50)) // tap Menu button on right in nav bar
        tester().tapView(withAccessibilityLabel: "Sign Out") // accessibilityLabel provided automatically
        
        // user1 has invited user2 to share a shopping list
        
        // sign in as tester2
        tester().clearTextFromView(withAccessibilityLabel: "userNameField")
        tester().clearTextFromView(withAccessibilityLabel: "passwordField")
        tester().enterText(Secrets.userNameUITest2, intoViewWithAccessibilityLabel: "userNameField")
        tester().enterText(Secrets.passwordUITest2, intoViewWithAccessibilityLabel: "passwordField")
        tester().waitForAnimationsToFinish(withTimeout: 1)
        tester().waitForTappableView(withAccessibilityLabel: "signInButton")
        tester().tapView(withAccessibilityLabel:"signInButton")

        // add an item with no image
        tester().waitForAnimationsToFinish(withTimeout: 1)
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Add on right in nav bar
        tester().waitForView(withAccessibilityLabel: "captureItemViewInst")
        tester().tapScreen(at: CGPoint(x: 40, y: 50)) // tap Cancel on left in nav bar
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Add on right in nav bar
        tester().waitForView(withAccessibilityLabel: "captureItemViewInst")
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Continue on right in nav bar
        tester().waitForView(withAccessibilityLabel: "editNameViewInst")
        tester().enterText("Tester2 item", intoViewWithAccessibilityLabel: "nameTextView")
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Next on right in nav bar
        tester().waitForView(withAccessibilityLabel: "itemDetailViewInst")
        
        // enable on shoppingListSwitch
        let shoppingListSwitch2 = tester().waitForView(withAccessibilityLabel: "shoppingListSwitch")
        let shoppingListSwitch2Center = CGPoint(x: (shoppingListSwitch2?.frame.maxX)! - 15, y: (shoppingListSwitch2?.frame.minY)! + 80) // + 60 for nav
        tester().tapScreen(at: shoppingListSwitch2Center)
        
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Add Item on right in nav bar
        
        // accept sharing from user 1
        tester().waitForAnimationsToFinish(withTimeout: 1)
        tester().tapScreen(at: CGPoint(x: 40, y: 50)) // tap menu button in nav bar
        tester().tapView(withAccessibilityLabel: "Sharing Shopping Lists") // accessibilityLabel provided automatically
        tester().waitForView(withAccessibilityLabel: "sharingStatusViewInst")
        tester().tapView(withAccessibilityLabel: "tabInvitation")
        tester().waitForView(withAccessibilityLabel: "sharingInvitationViewInst")
        
        let indexPathSharing = IndexPath(row: 0, section: 1)
        tester().tapRow(at: indexPathSharing, inTableViewWithAccessibilityIdentifier: "invitationsTableView")
        tester().tapView(withAccessibilityLabel: "acceptInvitationButton")
        tester().tapView(withAccessibilityLabel: "tabStatus")
        tester().waitForView(withAccessibilityLabel: "sharingStatusViewInst")
        tester().tapRow(at: indexPathSharing, inTableViewWithAccessibilityIdentifier: "usersWithAccessTableView")
        tester().tapView(withAccessibilityLabel: "deleteListFromUserButton")
        tester().tapView(withAccessibilityLabel:"confirmDeleteListFromUser")
        tester().tapView(withAccessibilityLabel: "tabInvitation")
        tester().waitForView(withAccessibilityLabel: "sharingInvitationViewInst")
        if let newInvitations2 = tester().waitForCell(at: indexPathSharing, inTableViewWithAccessibilityIdentifier: "invitationsTableView") {
            tester().expect(newInvitations2.textLabel, toContainText: "tester1")
        }
        tester().tapRow(at: indexPathSharing, inTableViewWithAccessibilityIdentifier: "invitationsTableView")
        tester().tapView(withAccessibilityLabel: "acceptInvitationButton")
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.width - 40, y: 40)) // tap Done on right in nav bar
        tester().waitForView(withAccessibilityLabel: "shoppingListViewInst")
        
        // sign out user 2
        tester().tapScreen(at: CGPoint(x: 40, y: 50)) // tap Menu button on right in nav bar
        tester().tapView(withAccessibilityLabel: "Sign Out") // accessibilityLabel provided automatically
    }
    
}
