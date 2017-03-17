//
//  EditNameViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class EditNameViewController: UIViewController, EditNameViewDelegate {
    
    let store = DataStore.sharedInstance
    let editNameViewInst = EditNameView()
    var nameInitial = String()
    var categoryInitial = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.editNameViewInst.delegate = self
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        if let itemInst = self.editNameViewInst.itemInst {
            // we are editing an existing item so populate the controls with values from the object
            self.editNameViewInst.nameTextView.text = itemInst.name
            self.nameInitial = self.editNameViewInst.nameTextView.text
            
            if !itemInst.imageURL.isEmpty {  // imageURL exists
                let itemImageURL = URL(string: itemInst.imageURL)
                self.editNameViewInst.itemImageView.sd_setImage(with: itemImageURL)
            } else { // no imageURL, show "no image found"
                self.editNameViewInst.itemImageView.image = #imageLiteral(resourceName: "noImageFound.jpg")
            }
            // set the category
            let indexPath = self.getCategoryIndex(categoryID: itemInst.categoryID)
            self.editNameViewInst.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            self.categoryInitial = self.editNameViewInst.itemInst!.categoryID

        } else {
            print("no itemInst passed in")
            // item does not exist yet, add back button to nav bar
            let captureItemButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(captureItemButtonClicked))
            self.navigationItem.leftBarButtonItems = [captureItemButton]
            // set the category to none
            let indexPath = self.getCategoryIndex(categoryID: 0)
            self.editNameViewInst.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            self.categoryInitial = 0
        }
        
        // next button
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonClicked))
        self.navigationItem.rightBarButtonItems = [nextButton]
    }
    
    func getCategoryIndex(categoryID: Int) -> IndexPath {
        var indexPath = IndexPath()
        for (i, categoryInList) in self.store.myCategories.enumerated() {
            if categoryID == categoryInList.id {
                indexPath = IndexPath(item: i, section: 0)
                break
            }
        }
        return indexPath
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.editNameViewInst.frame = CGRect.zero
        self.view = self.editNameViewInst
    }
    
    func nextButtonClicked() {
        let itemDetailViewControllerInst = ItemDetailViewController()
        
        if let itemInst = self.editNameViewInst.itemInst {
            // update the record in the DB and itemInst object if any properties values changed
            if (self.nameInitial != self.editNameViewInst.nameTextView.text || self.categoryInitial != itemInst.categoryID) && self.store.getItemExistsInDatastore(item: itemInst) {
                
                APIClient.updateMyItem(barcode: itemInst.barcode, name: self.editNameViewInst.nameTextView.text, categoryID: itemInst.categoryID , completion: { (results) in
                    if results == apiResponse.ok {
                        // database updated successfully, so update the object
                        itemInst.name = self.editNameViewInst.nameTextView.text
                        itemDetailViewControllerInst.itemInst = itemInst
                        itemDetailViewControllerInst.itemInstImage = self.editNameViewInst.itemImageView.image
                        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false) // navigate to Item detail
                    } else {
                        print("error") // TODO: Show error message to user as changes were not applied.
                    }
                })
            } else {
                // if the name was changed, but the item is not in the datastore yet update the property
                self.nameInitial != self.editNameViewInst.nameTextView.text ? itemInst.name = self.editNameViewInst.nameTextView.text : ()
                // nothing was changed, so pass the itemInst and open the item detail
                itemDetailViewControllerInst.itemInst = itemInst
                itemDetailViewControllerInst.itemInstImage = self.editNameViewInst.itemImageView.image
                self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false) // navigate to Item detail
            }
        } else {
            print("no itemInst yet, cagtegoryID = \(self.editNameViewInst.getSelectedCategoryID())")
            // we dont have an itemInst, so create one
            let itemInst = MyItem(barcode: "0", name: self.editNameViewInst.nameTextView.text, categoryID: self.editNameViewInst.getSelectedCategoryID(), imageURL: "", shoppingList: false, getAgain: .unsure)
            itemDetailViewControllerInst.itemInst = itemInst
            itemDetailViewControllerInst.itemInstImage = self.editNameViewInst.itemImageView.image
            self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false) // navigate to Item detail
            print("pushViewController(itemDetailViewControllerInst")
        }
    }
    
    func captureItemButtonClicked() {
        let captureItemViewControllerInst = CaptureItemViewController()
        self.navigationController?.pushViewController(captureItemViewControllerInst, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // nav bar title
        self.editNameViewInst.itemInst == nil ? (self.title = "Add Name & Category") : (self.title = "Edit Name & Category")
        self.editNameViewInst.itemImageView.contentMode = .scaleAspectFit
        
        self.editNameViewInst.enableDisbleDeleteButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAddCategory() {
        let alertController = UIAlertController(title: "Add Category", message: "", preferredStyle: UIAlertControllerStyle.alert)
        //Add text field
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Name"
        }
        alertController.addAction(UIAlertAction(title: "Add", style: UIAlertActionStyle.default){ action -> Void in
            if let newCategoryLabel = ((alertController.textFields?.first)! as UITextField).text {
                if newCategoryLabel.isEmpty {
                    Utilities.showAlertMessage("A new category was not added because a label was not provided.", viewControllerInst: self)
                } else {
                    let tempCategory = MyCategory(id: -1, label: newCategoryLabel)
                    self.store.myCategories.append(tempCategory)
                    let newCategory = self.store.setIDOnCategoryForInsert()
                
                    APIClient.insertMyCategory(category: newCategory, completion: { (result) in
                        if result == apiResponse.ok {
                            self.editNameViewInst.categoryTableView.reloadData()
                            // select the new category in the tableview
                            let newID = self.store.getCategoryIDFromLabel(label: newCategoryLabel)
                            let indexPath = self.store.getCategoryIndexPath(id: newID)
                            self.editNameViewInst.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                            // set the new category on the item
                            self.editNameViewInst.itemInst?.categoryID = newID
                            self.editNameViewInst.enableDisbleDeleteButton()
                        } else {
                            self.store.removeCategory(id: -1)
                            Utilities.showAlertMessage("The system was unable to add the new category.", viewControllerInst: self)
                        }
                    })
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteSelectedCategory(id: Int) {
        APIClient.deleteMyCategory(id: id) { (result) in
            if result == apiResponse.ok {
                
                // get the selected item so we can reselect it after the table reload below
                let selectedID = self.editNameViewInst.getSelectedCategoryID()
                
                // remove the category from the array
                for (index, category) in self.store.myCategories.enumerated() {
                    if category.id == id {
                        self.store.myCategories.remove(at: index)
                    }
                }
                
                // reload the table and reselect the item that was selected
                self.editNameViewInst.categoryTableView.reloadData()
                let indexPath = self.store.getCategoryIndexPath(id: selectedID)
                self.editNameViewInst.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                self.editNameViewInst.enableDisbleDeleteButton()
            }
        }
    }
    
    func deleteCategoryClicked(id: Int) {
        
        // create a menu of categories that can be deleted
        let deleteMenu = UIAlertController(title: nil, message: "Select an Unused Category to Delete", preferredStyle: .actionSheet)
        
        // iterate through the categories and create menu items for the categories that are not used
        for category in self.store.myCategories {
            let itemsUsingCategoryID = self.store.myItems.filter({ $0.categoryID == category.id })

            // if there are some unused categories and the unused category is not "none" (0) then add the cagtegory to the menu
            if itemsUsingCategoryID.isEmpty && category.id != 0 {
                
                    let menuItemToDeleteCategory = UIAlertAction(title: category.label, style: .default, handler: { (alert: UIAlertAction!) -> Void in
                        self.deleteSelectedCategory(id: category.id)
                    })
                    deleteMenu.addAction(menuItemToDeleteCategory)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        deleteMenu.addAction(cancelAction)
        self.present(deleteMenu, animated: true, completion: nil)
    }
}
