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
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.sharingInvitationViewInst.frame = CGRect.zero
        self.view = self.sharingInvitationViewInst
        self.sharingInvitationViewInst.getInvitationsFromDB()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.store.removeDefaultMessageFromSharedListStatusInvitations(completion: { self.sharingInvitationViewInst.invitationsTableView.reloadData() })
    }
    
    func showAlertMessage(message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
    
    func onTapDeleteInvitation(message: String) {
        print("onTapDeleteInvitation")
        
        let alertController = UIAlertController(title: "Confirmation", message: message, preferredStyle: UIAlertControllerStyle.alert)

        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.default){ action -> Void in
            
            let selectedUserName = self.sharingInvitationViewInst.selectedUserName
            let selectedListID = self.sharingInvitationViewInst.selectedListID
            let selectedSection = self.sharingInvitationViewInst.selectedSection
            
            if selectedSection == 0 {
                // delete invitation to view my list, pass my listID and selectedUsername for SQL statement
                if let myList = self.store.myLists.first {
                    APIClient.handleInvitation(action: "delete", userName: selectedUserName, listID: myList.id, status: "", completion: { (result) in
                        if result == apiResponse.ok {
                            self.store.removeUserNameFromInvitations(slot: self.sharingInvitationViewInst.selectedSection, userName: selectedUserName)
                            self.sharingInvitationViewInst.invitationsTableView.reloadData()
                        } else {
                            Utilities.showAlertMessage("The system was unable to delete the invitation to \(selectedUserName).", viewControllerInst: self)
                        }
                    })
                }
            } else {
                // delete invitation to view someone else's list, pass listID from array and sign in name for SQL statement
                if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                    APIClient.handleInvitation(action: "delete", userName: userName, listID: selectedListID, status: "", completion: { (result) in
                        if result == apiResponse.ok {
                            self.store.removeUserNameFromInvitations(slot: self.sharingInvitationViewInst.selectedSection, userName: selectedUserName)
                            self.sharingInvitationViewInst.invitationsTableView.reloadData()
                        } else {
                            Utilities.showAlertMessage("The system was unable to delete the invitation from \(selectedUserName).", viewControllerInst: self)
                        }
                    })
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func userIsSharingList(listID: Int, userName: String) -> Bool {
        for list in self.store.sharedListStatus[0] {
            if list.listID == listID && list.userName == userName {
                return true
            }
        }
        return false
    }
    
    func userIsInvitedToList(listID: Int, userName: String) -> Bool {
        for list in self.store.invitations[0] {
            if list.listID == listID && list.userName == userName {
                return true
            }
        }
        return false
    }
    
    func onTapAcceptInvitation() {
        
        let listID = self.sharingInvitationViewInst.selectedListID
        let selectedUserName = self.sharingInvitationViewInst.selectedUserName
        
        if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
        
            APIClient.handleInvitation(action: "update", userName: userName, listID: listID, status: "accepted", completion: { (result) in
                if result == apiResponse.ok {
                    // remove invitation
                    self.store.removeUserNameFromInvitations(slot: self.sharingInvitationViewInst.selectedSection, userName: selectedUserName)
                    // add name to list of shared lists
                    if self.store.sharedListStatus.isEmpty == false {
                        self.store.sharedListStatus[1].append((listID: listID, userName: selectedUserName))
                    }
                    self.sharingInvitationViewInst.invitationsTableView.reloadData()
                    
                    // disable accept button as no row is selected.
                    self.sharingInvitationViewInst.acceptInvitationButton.isEnabled = false
                    
                } else {
                    Utilities.showAlertMessage("The system was unable to update the invitation.", viewControllerInst: self)
                }
            })
        }
    }

    func showAddInvitation() {
        let alertController = UIAlertController(title: "New Invitation to View My Shopping List", message: "", preferredStyle: UIAlertControllerStyle.alert)
        //Add text field
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Recipient's Sign in Name"
        }
        alertController.addAction(UIAlertAction(title: "Send", style: UIAlertActionStyle.default){ action -> Void in
            if let invitationRecipient = ((alertController.textFields?.first)! as UITextField).text {
                
                if let myList = self.store.myLists.first {
                if invitationRecipient.isEmpty {
                    Utilities.showAlertMessage("A new invitation was not created because the recipient's sign in name was not provided.", viewControllerInst: self)
                } else if self.userIsSharingList(listID: myList.id, userName: invitationRecipient) {
                    Utilities.showAlertMessage("'\(invitationRecipient)' can already view your list.", viewControllerInst: self)
                } else if self.userIsInvitedToList(listID: myList.id, userName: invitationRecipient) {
                    Utilities.showAlertMessage("'\(invitationRecipient)' is already invited to view your list.", viewControllerInst: self)
                } else {
                    // insert a record with the sender's listID, the recipients username and status = pending
                    
                        APIClient.handleInvitation(action: "insert", userName: invitationRecipient, listID: myList.id, status: "pending", completion: { (result) in
                            if result == apiResponse.ok {
                                self.store.invitations[0].append((listID: myList.id, userName:invitationRecipient)) // update the datastore
                                self.sharingInvitationViewInst.invitationsTableView.reloadData()
                                // // select the new invitation in the tableview
                                // let newID = self.store.getCategoryIDFromLabel(label: newCategoryLabel)
                                // let indexPath = self.store.getCategoryIndexPath(id: newID)
                                // self.editNameViewInst.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                                // // set the new category on the item
                                // self.editNameViewInst.itemInst?.categoryID = newID
                                // self.editNameViewInst.enableDisbleDeleteButton()
                            } else if result == apiResponse.userNameInvalid {
                                Utilities.showAlertMessage("The sign in name provided '\(invitationRecipient)' was not found. Please verify the sign in name and try again.", viewControllerInst: self)
                            } else {
                                Utilities.showAlertMessage("The system was unable to create the invitation.", viewControllerInst: self)
                            }
                        })
                    }
                }
            }
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel))
        self.present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
