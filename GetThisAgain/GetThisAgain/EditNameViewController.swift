//
//  EditNameViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class EditNameViewController: UIViewController {
    
    let editNameViewInst = EditNameView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar

        if editNameViewInst.itemExistsInDatastore == false {
            // add capture item button to nav bar
            self.navigationItem.setHidesBackButton(true, animated:false);
            let captureItemButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(captureItemButtonClicked))
            self.navigationItem.leftBarButtonItems = [captureItemButton]
        }
        
        // next button
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButtonClicked))
        self.navigationItem.rightBarButtonItems = [nextButton]
        
        // hardcode the image if needed for testing
        //editNameViewInst.itemImageView.image = UIImage(named: "jam.jpeg")
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.editNameViewInst.frame = CGRect.zero
        self.view = self.editNameViewInst
    }
    
    func nextButtonClicked() {
        let itemDetailViewControllerInst = ItemDetailViewController()
        let itemInst = MyItem(barcode: "0", name: self.editNameViewInst.nameTextView.text, category: self.editNameViewInst.categorySelected, imageURL: "", shoppingList: false, getAgain: .unsure)
        itemDetailViewControllerInst.itemInst = itemInst
        itemDetailViewControllerInst.itemInstImage = self.editNameViewInst.itemImageView.image
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }
    
    func captureItemButtonClicked() {
        let captureItemViewControllerInst = CaptureItemViewController()
//        itemDetailViewControllerInst.editMode = true
//        itemDetailViewControllerInst.itemInst = self.editNameViewInst.itemInst
        self.navigationController?.pushViewController(captureItemViewControllerInst, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // nav bar title
        editNameViewInst.itemExistsInDatastore ? (self.title = "Edit Name & Category") : (self.title = "Add Name & Category")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
