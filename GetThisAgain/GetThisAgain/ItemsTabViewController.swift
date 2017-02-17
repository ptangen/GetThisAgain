//
//  ItemsTabViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ItemsTabViewController: UITabBarController, UITabBarControllerDelegate  {
    
    let myItemsViewControllerInst = MyItemsViewController()
    

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
        self.title = "Get This Again"
        self.navigationItem.hidesBackButton = true
        UITabBar.appearance().tintColor = UIColor(named: .statusBarBlue)
        
        // Create MyItems Tab
        let tabMyItems = UITabBarItem(title: "My Items", image: UIImage(named: "sentiment_satisfied"), selectedImage: UIImage(named: "sentiment_satisfied"))
        self.myItemsViewControllerInst.tabBarItem = tabMyItems
        //self.myItemsViewControllerInst.myItemsViewInst.setHeadingLabels()
        
        self.viewControllers = [myItemsViewControllerInst]
        
        // add controls to nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonClicked))
        self.navigationItem.rightBarButtonItems = [addButton]
        
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(menuButtonClicked))
        self.navigationItem.leftBarButtonItems = [menuButton]
    }
    
    func addButtonClicked() {
        let scanViewControllerInst = ScanViewController()
        self.navigationController?.pushViewController(scanViewControllerInst, animated: true) // show destination with nav bar
    }
    
    func menuButtonClicked(sender: UIBarButtonItem) {
        
        let optionMenu = UIAlertController(title: nil, message: "Menu", preferredStyle: .actionSheet)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            //let signInControllerInst = SignInViewController()
            //self.navigationController?.pushViewController(signInControllerInst, animated: true) // show destination with nav bar
        })
        
        let addAction = UIAlertAction(title: "Add Item with Barcode", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.addButtonClicked()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        // Add actions to menu and display
        optionMenu.addAction(addAction)
        optionMenu.addAction(signOutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}
