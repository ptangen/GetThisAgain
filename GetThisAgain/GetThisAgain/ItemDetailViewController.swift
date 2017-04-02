//
//  ItemDetailViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit
import SDWebImage

class ItemDetailViewController: UITabBarController, ItemDetailViewDelegate {
    
    let store = DataStore.sharedInstance
    let itemDetailViewInst = ItemDetailView()
    var itemInst: MyItem!
    var itemInstImage: UIImage?
    var addButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    var doneButton = UIBarButtonItem()
    var deleteButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemDetailViewInst.delegate = self
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
        
        // add button
        self.addButton.style = .plain
        self.addButton.target = self
        self.addButton.action = #selector(addButtonClicked)
        self.addButton.title = "Add Item"
        
        // cancel button
        self.cancelButton.style = .plain
        self.cancelButton.target = self
        self.cancelButton.action = #selector(cancelButtonClicked)
        self.cancelButton.title = "Cancel"
        
        // done button
        self.doneButton.style = .plain
        self.doneButton.target = self
        self.doneButton.title = "Done"
        self.doneButton.action = #selector(doneButtonClicked)
        
        // delete button
        self.deleteButton.style = .plain
        self.deleteButton.target = self
        self.deleteButton.title = "Delete"
        self.deleteButton.action = #selector(deleteButtonClicked)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemDetailViewInst.itemInst = itemInst
        self.title = "Item Detail" // nav bar title
        self.itemDetailViewInst.updateRecordRequired = false
        
        self.itemDetailViewInst.nameLabel.text = itemInst.itemName
        if itemInst.categoryID == -1 { // prompt user about new cagtegory
            let message = "This item is associated with a new cagtegory: \(self.store.getCategoryLabelFromID(id: itemInst.categoryID))."
            self.showNewCategoryMessage(message, viewControllerInst: self)
        } else { // set the text in the label
            self.itemDetailViewInst.categoryLabel.text = self.store.getCategoryLabelFromID(id: itemInst.categoryID)
        }
        
        itemInst.listID > 0 ? (self.itemDetailViewInst.shoppingListSwitch.isOn = true) : (self.itemDetailViewInst.shoppingListSwitch.isOn = false)
        
        if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
            if self.store.getItemExistsInDatastore(item: self.itemInst) && userName == self.itemInst.createdBy {
                // done button
                self.navigationItem.rightBarButtonItems = [doneButton]
                // delete button
                self.navigationItem.leftBarButtonItems = [deleteButton]
            } else if userName == self.itemInst.createdBy {
                // add button
                self.navigationItem.rightBarButtonItems = [addButton]
                // cancel button
                self.navigationItem.setHidesBackButton(true, animated:false);
            
                self.navigationItem.leftBarButtonItems = [cancelButton]
            } else {
                // done button only, this is someone else's item
                self.navigationItem.rightBarButtonItems = [doneButton]
                self.navigationItem.setHidesBackButton(true, animated:false);
            }
        }

        if let itemInstImage = self.itemInstImage {
            // image came from a snapshot
            self.itemDetailViewInst.itemImageView.image = itemInstImage
        } else {
            if itemInst.imageURL.isEmpty {
                // show no image found
                self.itemDetailViewInst.itemImageView.image = #imageLiteral(resourceName: "noImageFound.jpg")
            } else {
                // show the image per the URL
                let itemImageURL = URL(string: itemInst.imageURL)
                self.itemDetailViewInst.itemImageView.sd_setImage(with: itemImageURL)
            }
        }

        self.itemDetailViewInst.itemImageView.contentMode = .scaleAspectFit
        
        // set the getThisAgainControl
        switch itemInst.getAgain.label() {
        case "No" :
            self.itemDetailViewInst.getAgainPicker.selectedSegmentIndex = 0
        case "Unsure" :
            self.itemDetailViewInst.getAgainPicker.selectedSegmentIndex = 1
        case "Yes" :
            self.itemDetailViewInst.getAgainPicker.selectedSegmentIndex = 2
        default:
            break
        }
        
        // disable editing of items that are not the current user's items
        if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
            if itemInst.createdBy != userName {
                self.itemDetailViewInst.editTextButton.isHidden = true
                self.itemDetailViewInst.getAgainPicker.isHidden = true
                self.itemDetailViewInst.getAgainLabel.isHidden = true
                
                // disable tap on nameLabel
                self.itemDetailViewInst.nameLabel.isUserInteractionEnabled = false
            }
        }
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.itemDetailViewInst.frame = CGRect.zero
        self.view = self.itemDetailViewInst
    }

    func addButtonClicked() {
        if let itemInst = self.itemInst {
            self.itemDetailViewInst.showActivityIndicator(uiView: self.itemDetailViewInst)
            itemInst.imageURL != "" ? self.itemInstImage = nil : ()
            APIClient.insertMyItem(itemInst: itemInst, image: self.itemInstImage) { (results, imageURL, barcode) in

                self.itemDetailViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                self.itemDetailViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                if results == apiResponse.ok {
                    itemInst.barcode = barcode
                    itemInst.imageURL = imageURL
                    self.store.myItems.append(itemInst)
                    self.store.myItems.sort(by: { $0.itemName < $1.itemName })
                    
                    let itemsTabViewControllerInst = ItemsTabViewController()
                    self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
                } else {
                    Utilities.showAlertMessage("The system was unable to save the new item. Please contact ptangen@ptangen.com about this issue.", viewControllerInst: self)
                }
            }
        }
    }
    
    func deleteButtonClicked() {
        if let itemInst = self.itemInst {
            self.itemDetailViewInst.showActivityIndicator(uiView: self.itemDetailViewInst)
            APIClient.deleteMyItem(createdBy: UserDefaults.standard.value(forKey: "userName") as! String, barcode: itemInst.barcode, imageURL: itemInst.imageURL) { (results) in
                
                self.itemDetailViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                self.itemDetailViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                
                if results == apiResponse.ok {
                    self.store.myItems = self.store.myItems.filter { $0.barcode != itemInst.barcode } // remove the item from the datastore
                    self.doneButtonClicked()
                } else {
                    Utilities.showAlertMessage("The system was unable to delete the item. Please contact ptangen@ptangen.com about this issue.", viewControllerInst: self)
                }
            }
        }
    }

    func doneButtonClicked() {
        if self.itemDetailViewInst.updateRecordRequired {
            self.itemDetailViewInst.showActivityIndicator(uiView: self.itemDetailViewInst)
            APIClient.updateMyItem(createdBy: itemInst.createdBy, barcode: itemInst.barcode, itemName: itemInst.itemName, categoryID: itemInst.categoryID, getAgain: itemInst.getAgain, listID: itemInst.listID, completion: { (results) in
                
                self.itemDetailViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                self.itemDetailViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                
                if results == apiResponse.ok {
                    let itemsTabViewControllerInst = ItemsTabViewController()
                    self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
                } else {
                    self.showAlertMessage("The system cannot update this item. Please forward this message to ptangen@ptangen.com")
                }
            })
        } else {
            let itemsTabViewControllerInst = ItemsTabViewController()
            self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
    }
    
    func openEditName(item: MyItem) {
        let editNameViewControllerInst = EditNameViewController()
        editNameViewControllerInst.editNameViewInst.itemInst = item
        self.navigationController?.pushViewController(editNameViewControllerInst, animated: false)
    }
    
    func handleNewCategoryAlert(action: UIAlertAction) {
        if let title = action.title {
            if title == "Select Existing Category" {
                self.store.removeCategory(id: self.itemDetailViewInst.itemInst.categoryID) // remove temp category
                self.itemDetailViewInst.itemInst.categoryID = self.store.getIdOfNone()
                self.openEditName(item: self.itemDetailViewInst.itemInst)
            } else {
                // add new category
                let categoryForInsert = self.store.setIDOnCategoryForInsert()
                APIClient.insertMyCategory(category: categoryForInsert, completion: { (result) in
                    if result == apiResponse.ok {
                        self.itemDetailViewInst.itemInst.categoryID = categoryForInsert.id
                        self.itemDetailViewInst.categoryLabel.text = self.store.getCategoryLabelFromID(id: categoryForInsert.id)
                    } else {
                        Utilities.showAlertMessage("The system was unable to save the new category. Please contact ptangen@ptangen.com about this issue.", viewControllerInst: self)
                    }

                })
            }
        }
    }
    
    func showNewCategoryMessage(_ message: String, viewControllerInst: UIViewController) {
        let alertController = UIAlertController(title: "New Category Found", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Add Category", style: UIAlertActionStyle.default,handler: handleNewCategoryAlert))
        alertController.addAction(UIAlertAction(title: "Select Existing Category", style: UIAlertActionStyle.default, handler: handleNewCategoryAlert))
        viewControllerInst.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertMessage(_ message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
}
