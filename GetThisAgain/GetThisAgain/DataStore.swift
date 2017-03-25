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
    var myLists = [MyList]()
    var otherItems = [MyItem]()
    var otherCategories = [MyCategory]()
    var sharedListStatus = [[(listID: Int, userName: String)]]()
    var invitations = [[(listID: Int, userName: String)]]()
    
    func datastoreRemoveAll() {
        self.myItems.removeAll()
        self.myCategories.removeAll()
        self.myLists.removeAll()
        self.otherItems.removeAll()
        self.otherCategories.removeAll()
        self.sharedListStatus.removeAll()
    }
    
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
        
        var categoryLabel: String = "labelNotFound"
        
        // look in the myCategories array for the label
        for category in myCategories {
            if category.id == id {
                categoryLabel = category.label
            }
        }
        // look in the otherCategories array for the label
        if categoryLabel == "labelNotFound" {
            for otherCategory in otherCategories {
                if otherCategory.id == id {
                    categoryLabel = otherCategory.label
                }
            }
        }
        return categoryLabel
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
    
    func getCategoryIndexPath(id: Int) -> IndexPath {
        var itemIndex = Int()
        for (index,category) in myCategories.enumerated() {
            if category.id == id {
                itemIndex = index
                break
            }
        }
        let indexPath = IndexPath(item: itemIndex, section: 0)
        return indexPath
    }
    
    func setIDOnCategoryForInsert() -> MyCategory {
        let newCategoryArr = self.myCategories.filter { $0.id == -1 }
        if let newCategory = newCategoryArr.first {
            // find the largest id value in the current categories
            self.myCategories.sort(by: { $0.id > $1.id })
            if let categoryWithMaxValue = self.myCategories.first {
                newCategory.id = categoryWithMaxValue.id + 1
            }
            self.myCategories.sort(by: { $0.label < $1.label })
            return newCategory
        }
        let x = MyCategory(createdBy: "", id: 0, label: "")
        return x
    }
    
    func removeDefaultMessageFromSharedListStatusInvitations(completion: @escaping () -> Void) {
        for (index1, _) in sharedListStatus.enumerated() {
            if self.sharedListStatus[index1].count > 1 {
                for (index2, listInArray) in self.sharedListStatus[index1].enumerated() {
                    if listInArray.listID == -1 {
                        self.sharedListStatus[index1].remove(at: index2)
                    }
                }
            }
            if self.invitations.isEmpty == false {
                if self.invitations[index1].count > 1 {
                    for (index3, listInArray) in self.invitations[index1].enumerated() {
                        if listInArray.listID == -1 {
                            self.invitations[index1].remove(at: index3)
                        }
                    }
                }
            }
        }
        completion()
    }
    
    func removeUserNameFromSharedListStatus(slot: Int, userName: String) {
        for (index, userNameInArray) in self.sharedListStatus[slot].enumerated() {
            if userName == userNameInArray.userName {
                
                self.sharedListStatus[slot].remove(at: index)
                
                // make sure the message is available
                self.sharedListStatus[0].isEmpty ? self.sharedListStatus[0].append((listID: -1, userName: "No one can see your list.")) : ()
                self.sharedListStatus[1].isEmpty ? self.sharedListStatus[1].append((listID: -1, userName: "You cannot see anyone's list.")) : ()
            }
        }
    }
    
    func removeUserNameFromInvitations(slot: Int, userName: String) {
        for (index, userNameInArray) in self.invitations[slot].enumerated() {
            if userName == userNameInArray.userName {
                
                self.invitations[slot].remove(at: index)
                
                // make sure the message is available
                self.invitations[0].isEmpty ? self.invitations[0].append((listID: -1, userName: "Any invitations sent have been addressed.")) : ()
                self.invitations[1].isEmpty ? self.invitations[1].append((listID: -1, userName: "You have addressed any invitations received.")) : ()
            }
        }
    }
}
