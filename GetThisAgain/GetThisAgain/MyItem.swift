//
//  MyItem.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class MyItem {
    
    var barcode: String
    var name: String
    var categoryID: Int
    var imageURL: String
    var shoppingList: Bool
    var getAgain: GetAgain
    
    init (barcode: String, name: String, categoryID: Int, imageURL: String, shoppingList: Bool, getAgain: GetAgain) {
        self.barcode = barcode
        self.name = name
        self.categoryID = categoryID
        self.imageURL = imageURL
        self.shoppingList = shoppingList
        self.getAgain = getAgain
    }
    
    func setGetAgain(status: GetAgain) {
        self.getAgain = status
    }
}

enum GetAgain: String {
    case yes, no, unsure
    
    // thresholds for each measure
    func label() -> String {
        switch self {
        case .yes:
            return "Yes"
        case .unsure:
            return "Unsure"
        case .no:
            return "No"
        }
    }
}
