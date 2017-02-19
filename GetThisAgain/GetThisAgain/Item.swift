//
//  Item.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class Item {
    
    let barcode: String
    //let barcodeType: Constants.barcodeType
    let name: String
    let categoryText: String
    let imageURL: String
    var shoppingList: Bool
    var getThisAgain: GetThisAgain
    
    init (barcode: String, name: String, categoryText: String, imageURL: String, shoppingList: Bool, getThisAgain: GetThisAgain) {
        self.barcode = barcode
        //self.barcodeType = barcodeType
        self.name = name
        self.categoryText = categoryText
        self.imageURL = imageURL
        self.shoppingList = shoppingList
        self.getThisAgain = getThisAgain
    }
    
    func setGetThisAgain(status: GetThisAgain) {
        self.getThisAgain = status
    }
}

enum GetThisAgain: String {
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
