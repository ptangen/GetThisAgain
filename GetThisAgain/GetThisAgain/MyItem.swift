//
//  MyItem.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class MyItem {
    
    var createdBy: String
    var barcode: String
    var itemName: String
    var categoryID: Int
    var imageURL: String
    var listID: Int
    var getAgain: GetAgain
    var merchants: Int
    
    init (createdBy: String, barcode: String, itemName: String, categoryID: Int, imageURL: String, listID: Int, getAgain: GetAgain, merchants: Int) {
        self.createdBy = createdBy
        self.barcode = barcode
        self.itemName = itemName
        self.categoryID = categoryID
        self.imageURL = imageURL
        self.listID = listID
        self.getAgain = getAgain
        self.merchants = merchants
    }
    
    func setGetAgain(status: GetAgain) {
        self.getAgain = status
    }
}

enum GetAgain: String {
    case yes, no, unsure
    
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
