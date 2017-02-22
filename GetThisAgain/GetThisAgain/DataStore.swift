//
//  Datastore.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class DataStore {
    static let sharedInstance = DataStore()
    fileprivate init() {}
    
    var myItems = [Item]()
    
    func getItemFromBarcode(barcode: String) -> Item? {
        for item in myItems {
            if item.barcode == barcode {
                return item
            }
        }
        return nil
    }
    
    func getSampleData() {
        let myItem1 = Item(barcode: "0073852009385", name: "Purell H/Sanit Gel Aloe 2oz", category: "Bath / Beauty / Hygiene", imageURL: "http://eandata.com/image/products/007/385/200/0073852009385.jpg", shoppingList: false, getThisAgain: .yes)
        self.myItems.append(myItem1)
        
        let myItem2 = Item(barcode: "0037600106245", name: "Skippy Peanut Butter Creamy, 28 oz", category: "Food", imageURL: "http://eandata.com/image/products/003/760/010/0037600106245.jpg", shoppingList: false, getThisAgain: .yes)
        self.myItems.append(myItem2)
        
        let myItem3 = Item(barcode: "0072940748007", name: "Redpack Tomato Paste 6 Oz", category: "Food", imageURL: "http://eandata.com/image/products/007/294/074/0072940748007.jpg", shoppingList: true, getThisAgain: .yes)
        self.myItems.append(myItem3)
        
        let myItem4 = Item(barcode: "0787780770193", name: "French Vanilla Decaffeinated, Ground, 10-Ounce Bags, New England", category: "Food", imageURL: "http://eandata.com/image/products/078/778/077/0787780770193.jpg", shoppingList: false, getThisAgain: .no)
        self.myItems.append(myItem4)
        
        let myItem5 = Item(barcode: "0711381000083", name: "Stonewall Stonewall Wld Maine Blubr 13 Oz", category: "Food", imageURL: "http://eandata.com/image/products/071/138/100/0711381000083.jpg", shoppingList: true, getThisAgain: .yes)
        self.myItems.append(myItem5)
        
    }
}
