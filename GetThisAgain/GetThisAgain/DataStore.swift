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
    var accessList = [AccessRecord]()
    
    // Either MyItems or Shopping list can call getMyItemsFromDB. We need to respond when the data is recieved and then two view controllers
    // are of different types, so a generic was used.
    func getMyItemsFromDB<T>(currentViewController: T, type: String) {

        if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
            APIClient.selectMyItems(createdBy: userName) { isSuccessful in
                if isSuccessful {
                    OperationQueue.main.addOperation {
                        // reload data for the current view
                        if type == "MyItems" {
                            let viewController = currentViewController as! MyItemsViewController
                            viewController.myItemsViewInst.myItemsTableView.reloadData()
                            viewController.myItemsViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                            viewController.myItemsViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                        } else {
                            let viewController = currentViewController as! ShoppingListViewController
                            viewController.viewWillAppear(false) // filter myItems to get the shooping list items
                            viewController.shoppingListViewInst.shoppingListTableView.reloadData()
                            viewController.shoppingListViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                            viewController.shoppingListViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                        }
                    }
                } else {
                    OperationQueue.main.addOperation {
                        // show error message in the current view
                        let message = "Unable to retrieve data from the server."
                        if type == "MyItems" {
                            let viewController = currentViewController as! MyItemsViewController
                            viewController.myItemsViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                            viewController.myItemsViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                            viewController.showAlertMessage(message)
                        } else {
                            let viewController = currentViewController as! ShoppingListViewController
                            viewController.shoppingListViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                            viewController.shoppingListViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                            viewController.showAlertMessage(message)
                        }
                    }
                }
            }
        }
    }
    
    func datastoreRemoveAll() {
        self.myItems.removeAll()
        self.myCategories.removeAll()
        self.myLists.removeAll()
        self.otherItems.removeAll()
        self.otherCategories.removeAll()
        self.accessList.removeAll()
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
    
    func removeAccessRecord(accessRecord: AccessRecord) {
        for (index, accessRecordInDataStore) in self.accessList.enumerated() {
            if accessRecordInDataStore.id == accessRecord.id && accessRecordInDataStore.owner == accessRecord.owner && accessRecordInDataStore.viewer == accessRecord.viewer   {
                self.accessList.remove(at: index)
            }
        }
    }
}
