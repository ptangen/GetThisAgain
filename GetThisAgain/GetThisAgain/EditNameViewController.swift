//
//  EditNameViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class EditNameViewController: UIViewController {
    
    let store = DataStore.sharedInstance
    let editNameViewInst = EditNameView()
    var nameInitial = String()
    var categoryInitial = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
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
            // we dont have an itemInst, so create one
            let itemInst = MyItem(barcode: "0", name: self.editNameViewInst.nameTextView.text, categoryID: self.editNameViewInst.getSelectedCategoryID(), imageURL: "", shoppingList: false, getAgain: .unsure)
            itemDetailViewControllerInst.itemInst = itemInst
            itemDetailViewControllerInst.itemInstImage = self.editNameViewInst.itemImageView.image
            self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false) // navigate to Item detail
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
