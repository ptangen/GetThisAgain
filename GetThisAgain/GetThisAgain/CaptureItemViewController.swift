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
        self.navigationItem.rightBarButtonItems = [cancelButton]
    }
    
    func cancelButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
