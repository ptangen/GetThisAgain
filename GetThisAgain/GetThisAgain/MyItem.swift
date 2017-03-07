//
//  MyItem.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class MyItem {
    
    let barcode: String
    //let barcodeType: Constants.barcodeType
    let name: String
    var category: Constants.ItemCategory
    var imageURL: String
    var shoppingList: Bool
    var getAgain: GetAgain
    
    init (barcode: String, name: String, category: Constants.ItemCategory, imageURL: String, shoppingList: Bool, getAgain: GetAgain) {
        self.barcode = barcode
        //self.barcodeType = barcodeType
        self.name = name
        self.category = category
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
