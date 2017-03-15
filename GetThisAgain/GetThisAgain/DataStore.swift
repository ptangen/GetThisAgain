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
    
    func getItemExistsInDatastore(item: MyItem) -> Bool {
        for itemInDataStore in myItems {
            if itemInDataStore.barcode == item.barcode {
                return true
            }
        }
        return false
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


    func removeCategory(id: Int) {
        for (index, category) in myCategories.enumerated() {
            if category.id == id {
                self.myCategories.remove(at: index)
            }
        }
    }
    
    func getIdOfNone() -> Int {
        // get the ID of none so we can select a valid item when we dont have a category
        var idOfNone = Int()
        let categoryForNone = self.myCategories.filter { $0.label == "none" }
        
        if let firstItem = categoryForNone.first {
            idOfNone = firstItem.id
        }
        return idOfNone
    }
    
    func getNewCategoryForInsert() -> MyCategory {
        let newCategoryArr = self.myCategories.filter { $0.id == -1 }
        if let newCategory = newCategoryArr.first {
            // find the largest id value in the current categories
            let myCategoriesSorted = self.myCategories.sorted(by: { $0.id > $1.id })
            if let categoryWithMaxValue = myCategoriesSorted.first {
                newCategory.id = categoryWithMaxValue.id + 1
            }
            return newCategory
        }
        let x = MyCategory(id: 0, label: "")
        return x
    }
}
