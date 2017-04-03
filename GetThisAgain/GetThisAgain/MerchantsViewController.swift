//
//  MerchantsViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 4/3/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class MerchantsViewController: UIViewController {
    
    let store = DataStore.sharedInstance
    let merchantsViewInst = MerchantsView()
    var doneButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar

        // done button
        self.doneButton.style = .plain
        self.doneButton.target = self
        self.doneButton.title = "Done"
        self.doneButton.action = #selector(doneButtonClicked)
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Merchants" // nav bar title
        
        // set the text in the labels
        self.merchantsViewInst.nameLabel.text = merchantsViewInst.itemInst.itemName
        self.merchantsViewInst.categoryLabel.text = self.store.getCategoryLabelFromID(id: merchantsViewInst.itemInst.categoryID)
        
        if merchantsViewInst.itemInst.imageURL.isEmpty {
            // show no image found
            self.merchantsViewInst.itemImageView.image = #imageLiteral(resourceName: "noImageFound.jpg")
        } else {
            // show the image per the URL
            let itemImageURL = URL(string: merchantsViewInst.itemInst.imageURL)
            self.merchantsViewInst.itemImageView.sd_setImage(with: itemImageURL)
        }
        self.merchantsViewInst.itemImageView.contentMode = .scaleAspectFit
        
        self.navigationItem.rightBarButtonItems = [self.doneButton]
        self.navigationItem.setHidesBackButton(true, animated:false);
       
        self.merchantsViewInst.showActivityIndicator(uiView: self.merchantsViewInst)
        APIClient.getMerchantsFromAPI(barcode: self.merchantsViewInst.itemInst.barcode) { (merchants) in
            OperationQueue.main.addOperation {
                self.merchantsViewInst.merchants = merchants
                self.merchantsViewInst.merchantsTableView.reloadData()
                self.merchantsViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                self.merchantsViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
            }
        }
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.merchantsViewInst.frame = CGRect.zero
        self.view = self.merchantsViewInst
    }
    
    func doneButtonClicked() {
        let itemDetailViewControllerInst = ItemDetailViewController()
        itemDetailViewControllerInst.itemInst = self.merchantsViewInst.itemInst
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
