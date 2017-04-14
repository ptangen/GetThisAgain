//
//  CaptureItemViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class CaptureItemViewController: UIViewController, CaptureItemViewDelegate {
    
    var captureItemViewInst = CaptureItemView()
    let store = DataStore.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
        self.captureItemViewInst.delegate = self
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.captureItemViewInst.frame = CGRect.zero
        self.view = self.captureItemViewInst
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Capture the Item"
        
        // add cancel button to nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonClicked))
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        let continueButton = UIBarButtonItem(title: "Continue", style: .plain, target: self, action: #selector(continueButtonClicked))
        self.navigationItem.rightBarButtonItems = [continueButton]
    }
    
    func cancelButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
    }
    
    func continueButtonClicked() {
        // no barcode or image, just go to edit name
        let editNameViewControllerInst = EditNameViewController()
        self.navigationController?.pushViewController(editNameViewControllerInst, animated: false)
    }
    
    func openItemDetail(item: MyItem) {
        let itemDetailViewControllerInst = ItemDetailViewController()
        itemDetailViewControllerInst.itemInst = item
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }
    
    func openEditName(capturedImageView: UIImageView) {
        let editNameViewControllerInst = EditNameViewController()
        editNameViewControllerInst.editNameViewInst.itemImageView.image = capturedImageView.image
        self.navigationController?.pushViewController(editNameViewControllerInst, animated: false)
    }
    
    func getItemInformationEAN(barcodeValue: String) {
        
        // fetch item info from the EAN API
        APIClient.getEanDataFromAPI(barcode: barcodeValue, completion: {itemInst in
            if itemInst.barcode != "notFound" {
                DispatchQueue.main.async {
                    self.captureItemViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                    self.captureItemViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                    self.openItemDetail(item: itemInst)
                }
            } else {
                // display not found message
                DispatchQueue.main.async {
                    self.captureItemViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                    self.captureItemViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                    self.captureItemViewInst.barcodeStatusLabel.text = "The item was not found in the database."
                    self.captureItemViewInst.startStopBarcodePreview()
                }
            }
        })
    }
    
    func getItemInformationVig(barcodeValue: String) {
        
        if let itemInst = self.store.getItemFromBarcode(barcode: barcodeValue) {
            // we have the item that was scanned in the datastore so show the item detail
            DispatchQueue.main.async {
                self.openItemDetail(item: itemInst)
            }
        } else {
            // we dont have the item in the datastore so fetch it from the API
            APIClient.getVigDataFromAPI(barcode: barcodeValue, completion: {itemInst in
                if itemInst.barcode != "notFound" {
                    DispatchQueue.main.async {
                        self.captureItemViewInst.activityIndicatorXConstraintWhileDisplayed.isActive = false
                        self.captureItemViewInst.activityIndicatorXConstraintWhileHidden.isActive = true
                        self.openItemDetail(item: itemInst)
                    }
                } else {
                    // item not found at Vig, search for it in the EAN DB
                    self.getItemInformationEAN(barcodeValue: barcodeValue)
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
