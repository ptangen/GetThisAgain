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
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.sharingStatusViewInst.frame = CGRect.zero
        self.view = self.sharingStatusViewInst
        self.getAccessListFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.createArraysForTableView()
        //self.sharingStatusViewInst.usersWithAccessTableView.reloadData()
    }
    
    func onTapDeleteUser(message: String) {
        
        // set the status to pending the user cannot see the list and the record becomes an invitation from the other user.
        let alertController = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default){ action -> Void in
            var action = String()

            if self.sharingStatusViewInst.selectedSection == 0 {
                action = "delete"  // remove the record that lets this user see my list.
            } else {
                action = "updateToPendingByViewer"  // set the status of the record that lets me see this user's list to pending
            }
            
            // send request to update DB
            if let selectedAccessRecord = self.sharingStatusViewInst.selectedAccessRecord {
                APIClient.handleAccessRecord(action: action, listID: selectedAccessRecord.id, listOwner: selectedAccessRecord.owner, listViewer: selectedAccessRecord.viewer, status: selectedAccessRecord.status, completion: { (result) in
                    if result == apiResponse.ok {
                        DispatchQueue.main.async {
                            // update the array in the datastore
                            if action == "delete" {
                                self.store.removeAccessRecord(accessRecord: self.sharingStatusViewInst.selectedAccessRecord!)
                            } else {
                                selectedAccessRecord.status = "pending"
                            }
                            self.createArraysForTableView()
                        }
                    } else {
                        Utilities.showAlertMessage("The system was unable to remove this user.", viewControllerInst: self)
                    }
                })
            }
        })
        alertController.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getAccessListFromDB() {
        if self.store.accessList.isEmpty {
            APIClient.getAccessList(completion: { isSuccessful in
                if isSuccessful {
                    self.createArraysForTableView()
                } else {
                    OperationQueue.main.addOperation {
                        //self.activityIndicator.isHidden = true  TODO: Add spinner
                    }
                    self.showAlertMessage(message: "Unable to retrieve data from the server.")
                }
            })
        }
    }
    
    func createArraysForTableView() {
        
        self.sharingStatusViewInst.selectedAccessRecord = nil
        self.sharingStatusViewInst.deleteUserButton.isEnabled = false
        
        OperationQueue.main.addOperation {
            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                self.sharingStatusViewInst.accessListAccepted[0] = self.store.accessList.filter(
                    { $0.owner == userName && $0.viewer != userName && $0.status == "accepted" } )
                self.sharingStatusViewInst.accessListAccepted[1] = self.store.accessList.filter(
                    { $0.viewer == userName && $0.owner != userName && $0.status == "accepted" } )
                
                // add messages when no record exists
                self.sharingStatusViewInst.accessListAccepted[0].isEmpty ? (self.sharingStatusViewInst.accessListAccepted[0] = [AccessRecord(id: -1, owner: "", viewer: "Nobody has access to your list.", status: "empty")]) : ()
                self.sharingStatusViewInst.accessListAccepted[1].isEmpty ? (self.sharingStatusViewInst.accessListAccepted[1] = [AccessRecord(id: -1, owner: "Nobody is sharing their list with you.", viewer: "", status: "empty")]) : ()
                
                self.sharingStatusViewInst.usersWithAccessTableView.reloadData()
            }
        }
    }
    
    func showAlertMessage(message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
}
