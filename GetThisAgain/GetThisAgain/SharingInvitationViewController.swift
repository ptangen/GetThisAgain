//
//  SharingInvitationViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/24/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class SharingInvitationViewController: UIViewController, SharingInvitationViewDelegate {
    
    let store = DataStore.sharedInstance
    let sharingInvitationViewInst = SharingInvitationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sharingInvitationViewInst.delegate = self
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.sharingInvitationViewInst.frame = CGRect.zero
        self.view = self.sharingInvitationViewInst
        self.createArraysForTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.createArraysForTableView()
    }
    
    func showAlertMessage(message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
    
    func onTapDeleteInvitation(message: String) {
        
        let alertController = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)

        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default){ action -> Void in
            
            if let selectedAccessRecord = self.sharingInvitationViewInst.selectedAccessRecord {
                // send request to update DB
                APIClient.handleAccessRecord(action: "delete", listID: selectedAccessRecord.id, listOwner: selectedAccessRecord.owner, listViewer: selectedAccessRecord.viewer, status: selectedAccessRecord.status, completion: { (result) in
                    if result == apiResponse.ok {
                        DispatchQueue.main.async {
                            // update the array in the datastore
                            self.store.removeAccessRecord(accessRecord: selectedAccessRecord)
                            self.createArraysForTableView()
                        }
                    } else {
                        Utilities.showAlertMessage("The system was unable to remove this user.", viewControllerInst: self)
                    }
                })
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        self.present(alertController, animated: true, completion: {
            // accessibility labels for buttons in alertController
            if let confirmDeleteInvitation = alertController.actions.first {
                confirmDeleteInvitation.accessibilityLabel = "confirmDeleteInvitation"
            }
            
            if let cancelDeleteInvitation = alertController.actions.last {
                cancelDeleteInvitation.accessibilityLabel = "cancelDeleteInvitation"
            }
        })
    }
    
    func userAssociatedWithList(listID: Int, listOwner: String, listViewer: String) -> String {
        for accessRecordInDatastore in self.store.accessList {
            if accessRecordInDatastore.id == listID && accessRecordInDatastore.owner == listOwner && accessRecordInDatastore.viewer == listViewer {
                return accessRecordInDatastore.status
            }
        }
        return "notFound"
    }
    
    func onTapAcceptInvitation() {
        
        if let selectedAccessRecord = self.sharingInvitationViewInst.selectedAccessRecord {
            
            // send request to update DB
            APIClient.handleAccessRecord(action: "updateStatus", listID: selectedAccessRecord.id, listOwner: selectedAccessRecord.owner, listViewer: selectedAccessRecord.viewer, status: selectedAccessRecord.status, completion: { (result) in
                if result == apiResponse.ok {
                    DispatchQueue.main.async {
                        // update the array in the datastore
                        selectedAccessRecord.status = "accepted"
                        self.createArraysForTableView()
                        self.sharingInvitationViewInst.acceptInvitationButton.isEnabled = false
                        self.sharingInvitationViewInst.deleteInvitationButton.isEnabled = false
                    }
                } else {
                    Utilities.showAlertMessage("The system was unable to process this invitation.", viewControllerInst: self)
                }
            })
        }
    }

    func showAddInvitation() {
        let alertController = UIAlertController(title: "New Invitation to View My Shopping List", message: "", preferredStyle: UIAlertControllerStyle.alert)
        //Add text field
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Recipient's Sign in Name"
            textField.accessibilityLabel = "textField"
        }
        alertController.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.default){ action -> Void in
            if let invitationRecipient = ((alertController.textFields?.first)! as UITextField).text {
                if let myList = self.store.myLists.first {
                    if invitationRecipient.isEmpty {
                        Utilities.showAlertMessage("A new invitation was not created because the recipient's sign in name was not provided.", viewControllerInst: self)
                    } else {
                        // check to see if it is a duplicate
                        if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                            let userStatus = self.userAssociatedWithList(listID: myList.id, listOwner: userName, listViewer: invitationRecipient)
                            if userStatus == "accepted" {
                                Utilities.showAlertMessage("'\(invitationRecipient)' can already view your list.", viewControllerInst: self)
                            } else if userStatus == "pending" {
                                Utilities.showAlertMessage("'\(invitationRecipient)' is already invited to view your list.", viewControllerInst: self)
                            } else {
                                // insert a record with the sender's listID, the recipients username and status = pending
                                APIClient.handleAccessRecord(action: "insert", listID: myList.id, listOwner: userName, listViewer: invitationRecipient, status: "pending", completion: { (result) in
                                    if result == apiResponse.ok {
                                        DispatchQueue.main.async {
                                            // update the array in the datastore
                                            let accessRecordinst = AccessRecord(id: myList.id, owner: userName, viewer: invitationRecipient, status: "pending")
                                            self.store.accessList.append(accessRecordinst)
                                            self.createArraysForTableView()
                                        }
                                    } else if result == apiResponse.userNameInvalid {
                                        Utilities.showAlertMessage("The user name provided does not exist in GetThisAgain.", viewControllerInst: self)
                                    } else {
                                        Utilities.showAlertMessage("The system was unable to process this invitation.", viewControllerInst: self)
                                    }
                                })
                            }
                        }
                    }
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        self.present(alertController, animated: true, completion: {
            // accessibility labels for buttons in alertController
            if let sendInvitation = alertController.actions.first {
                sendInvitation.accessibilityLabel = "sendInvitation"
            }
            
            if let cancelInvitation = alertController.actions.last {
                cancelInvitation.accessibilityLabel = "cancelInvitation"
            }
        })
    }
    
    func createArraysForTableView() {
        
        self.sharingInvitationViewInst.selectedAccessRecord = nil
        self.sharingInvitationViewInst.deleteInvitationButton.isEnabled = false
        
        OperationQueue.main.addOperation {
            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                self.sharingInvitationViewInst.accessListInvitations[0] = self.store.accessList.filter(
                    { $0.owner == userName && $0.viewer != userName && $0.status == "pending" } )
                self.sharingInvitationViewInst.accessListInvitations[1] = self.store.accessList.filter(
                    { $0.viewer == userName && $0.owner != userName && $0.status == "pending" } )
                
                // add messages when no record exists
                self.sharingInvitationViewInst.accessListInvitations[0].isEmpty ? (self.sharingInvitationViewInst.accessListInvitations[0] = [AccessRecord(id: -1, owner: "", viewer: "No pending invitations found.", status: "empty")]) : ()
                self.sharingInvitationViewInst.accessListInvitations[1].isEmpty ? (self.sharingInvitationViewInst.accessListInvitations[1] = [AccessRecord(id: -1, owner: "No pending invitations found.", viewer: "", status: "empty")]) : ()
                
                self.sharingInvitationViewInst.invitationsTableView.reloadData()
            }
        }
    }
}
