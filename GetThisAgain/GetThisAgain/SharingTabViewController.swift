//
//  SharingTabViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/23/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class SharingTabViewController: UITabBarController, UITabBarControllerDelegate  {
    
    let store = DataStore.sharedInstance
    let sharingStatusViewControllerInst = SharingStatusViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Sharing Lists"
        self.navigationItem.hidesBackButton = true
        UITabBar.appearance().tintColor = UIColor(named: .statusBarBlue)
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Create MyItems Tab
        let tabStatus = UITabBarItem(title: "Sharing Status", image: UIImage(named: "person"), selectedImage: UIImage(named: "person"))
        self.sharingStatusViewControllerInst.tabBarItem = tabStatus
        
        self.viewControllers = [self.sharingStatusViewControllerInst]
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonClicked))
        self.navigationItem.rightBarButtonItems = [doneButton]
    }
    
    func doneButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: true) // show destination with nav bar
    }
}
