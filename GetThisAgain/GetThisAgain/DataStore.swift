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
    
    var myItems = [MyItem]()
    
    var myCategories = [MyCategory]()
    
    func getItemFromBarcode(barcode: String) -> MyItem? {
        for item in myItems {
            if item.barcode == barcode {
                return item
            }
        }
        return nil
    }
    
    func getCategoryLabelFromID(id: Int) -> String {
        for category in myCategories {
            if category.id == id {
                return category.label
            }
        }
        return "labelNotFound"
    }
    
    func getCategoryIDFromLabel(label: String) -> Int {
        for category in myCategories {
            if category.label == label {
                return category.id
            }
        }
        return -1
    }
    
    func addNextCategoryID() -> Int {
        // find the largest id value
        let myCategoriesSorted = self.myCategories.sorted(by: { $0.id > $1.id })
        if let categoryWithMaxValue = myCategoriesSorted.first {
            return categoryWithMaxValue.id + 1
        }
        return 0
    }
}
