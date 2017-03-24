//
//  SharingStatusViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/23/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class SharingStatusViewController: UIViewController, SharingStatusViewDelegate {
    
    let store = DataStore.sharedInstance
    let sharingStatusViewInst = SharingStatusView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sharingStatusViewInst.delegate = self
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.sharingStatusViewInst.frame = CGRect.zero
        self.view = self.sharingStatusViewInst
        self.sharingStatusViewInst.getSharingStatusFromDB()
    }
    
    func onTapDeleteUser(message: String) {
        //print(message)
        let alertController = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ action -> Void in
            
            if self.sharingStatusViewInst.selectedSection == "People that see my shopping list" {
                // remove the record that lets this user see my list.
                
                APIClient.editSharedListAccess(action: "removeRecord", userName: self.sharingStatusViewInst.selectedUserName, completion: { (result) in
                    if result == apiResponse.ok {
                        DispatchQueue.main.async {
                            self.store.removeUserNameFromSharedListStatus(list: 0, userName: self.sharingStatusViewInst.selectedUserName)
                            
                            self.sharingStatusViewInst.usersWithAccessToMyListTableView.reloadData()
                            
                            self.sharingStatusViewInst.selectedSection = String()
                            self.sharingStatusViewInst.selectedUserName = String()
                            self.sharingStatusViewInst.deleteUserButton.isEnabled = false
                        }
                    } else {
                        Utilities.showAlertMessage("The system was unable to remove this user.", viewControllerInst: self)
                    }
                })
            } else {
                // set the status of the record that lets me see this user's list to pending
                if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                    APIClient.editSharedListAccess(action: "updateToPending", userName: userName, completion: { (result) in
                        if result == apiResponse.ok {
                            DispatchQueue.main.async {
                                self.store.removeUserNameFromSharedListStatus(list: 1, userName: self.sharingStatusViewInst.selectedUserName)
                                
                                self.sharingStatusViewInst.usersWithAccessToMyListTableView.reloadData()
                                
                                self.sharingStatusViewInst.selectedSection = String()
                                self.sharingStatusViewInst.selectedUserName = String()
                                self.sharingStatusViewInst.deleteUserButton.isEnabled = false
                            }
                        } else {
                            Utilities.showAlertMessage("The system was unable to remove this user.", viewControllerInst: self)
                        }
                    })
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertMessage(message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
}
