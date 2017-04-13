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
    let sharingInvitationViewControllerInst = SharingInvitationViewController()

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
        self.title = "Sharing Shopping Lists"
        self.navigationItem.hidesBackButton = true
        UITabBar.appearance().tintColor = UIColor(named: .statusBarBlue)
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Create tabStatus
        let tabStatus = UITabBarItem(title: "Sharing Status", image: UIImage(named: "person"), selectedImage: UIImage(named: "person"))
        self.sharingStatusViewControllerInst.tabBarItem = tabStatus
        
        // Create tabInvitation
        let tabInvitation = UITabBarItem(title: "Sharing Invitations", image: UIImage(named: "person"), selectedImage: UIImage(named: "person"))
        self.sharingInvitationViewControllerInst.tabBarItem = tabInvitation
        
        self.viewControllers = [self.sharingStatusViewControllerInst, sharingInvitationViewControllerInst]
        //self.viewControllers = [self.sharingStatusViewControllerInst]
        
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneButtonClicked))
        self.navigationItem.rightBarButtonItems = [doneButton]
    }
    
    func doneButtonClicked() {
        // clear the myItems array so we get a proper list of items
        self.store.datastoreRemoveAll()
        
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: true) // show destination with nav bar
    }
}
