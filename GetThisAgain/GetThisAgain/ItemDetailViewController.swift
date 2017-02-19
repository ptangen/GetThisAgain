//
//  ItemDetailViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit
import SDWebImage

class ItemDetailViewController: UITabBarController {
    
    let itemDetailViewInst = ItemDetailView()
    var itemInst: Item!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemDetailViewInst.itemInst = itemInst
        self.itemDetailViewInst.nameLabel.text = self.itemInst.name
        self.title = "Item Detail"
        
        let itemImageURL = URL(string: self.itemInst.imageURL)
        self.itemDetailViewInst.itemImageView.sd_setImage(with: itemImageURL)
        self.itemDetailViewInst.itemImageView.contentMode = .scaleAspectFit
        
        // add cancel button to nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonClicked))
        self.navigationItem.leftBarButtonItems = [cancelButton]
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.itemDetailViewInst.frame = CGRect.zero
        self.view = self.itemDetailViewInst
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
    }
}
