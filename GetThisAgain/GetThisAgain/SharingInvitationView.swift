//
//  SharingInvitationView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/24/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol SharingInvitationViewDelegate: class {
    func onTapDeleteInvitation(message: String)
    func showAlertMessage(message: String)
}

class SharingInvitationView: UIView, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: SharingInvitationViewDelegate?
    let store = DataStore.sharedInstance
    let invitationsTableView = UITableView()
    let sectionTitles = ["People you invited to view your list", "People that invited you to view their list"]
    var deleteInvitationButton = UIButton()
    var selectedSection = String()
    var selectedUserName = String()
    var selectedListID = Int()
    var tabDescription = UILabel()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        self.tabDescription.text = "Send invitations to people to share your shopping list with them. Accept invitations from people that want to share their list with you."
        self.tabDescription.numberOfLines = 0
        
        self.invitationsTableView.delegate = self
        self.invitationsTableView.dataSource = self
        
        // deleteInvitationButton
        self.deleteInvitationButton.addTarget(self, action: #selector(self.onTapDeleteInvitation), for: UIControlEvents.touchUpInside)
        self.deleteInvitationButton.setTitle(Constants.iconLibrary.delete.rawValue, for: .normal)
        self.deleteInvitationButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.deleteInvitationButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.deleteInvitationButton.setTitleColor(UIColor(named: .disabledText), for: .disabled)
        self.deleteInvitationButton.isEnabled = false
        
        self.pageLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func onTapDeleteInvitation() {
        if let delegate = self.delegate {
            
            if self.selectedSection == "People you invited to view your list" {
                delegate.onTapDeleteInvitation(message: "Are you sure you want to delete the invitation to '\(self.selectedUserName)' to view your shopping list?")
            } else {
                delegate.onTapDeleteInvitation(message: "Are you sure you want to delete the invitation from '\(self.selectedUserName)' to view their shopping list?")
            }
        }
    }
    
    // tableview config
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section] + ":"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.store.invitations.isEmpty {
            return 0
        } else {
            return self.store.invitations[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "prototype")
        
        if let textLabel = cell.textLabel {
            textLabel.text = self.store.invitations[indexPath.section][indexPath.row].userName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.store.invitations[indexPath.section][indexPath.row].userName != "Any invitations sent have been accepted or deleted." && self.store.invitations[indexPath.section][indexPath.row].userName != "You have accepted or deleted any invitations received." {
            self.selectedSection = self.sectionTitles[indexPath.section]
            self.selectedUserName = self.store.sharedListStatus[indexPath.section][indexPath.row].userName
            selectedListID = self.store.sharedListStatus[indexPath.section][indexPath.row].listID
            
            self.deleteInvitationButton.isEnabled = true
        } else {
            self.deleteInvitationButton.isEnabled = false
        }
    }
    
    func pageLayout() {
        
        // tabDescription
        self.addSubview(self.tabDescription)
        self.tabDescription.translatesAutoresizingMaskIntoConstraints = false
        self.tabDescription.topAnchor.constraint(equalTo: self.topAnchor, constant: 72).isActive = true
        self.tabDescription.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 6).isActive = true
        self.tabDescription.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 6).isActive = true
        
        // myItemsTableView
        self.addSubview(self.invitationsTableView)
        self.invitationsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.invitationsTableView.topAnchor.constraint(equalTo: self.tabDescription.bottomAnchor, constant: 60).isActive = true
        self.invitationsTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.invitationsTableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.invitationsTableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // delete user button
        self.addSubview(self.deleteInvitationButton)
        self.deleteInvitationButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteInvitationButton.bottomAnchor.constraint(equalTo: self.invitationsTableView.topAnchor, constant: -4).isActive = true
        self.deleteInvitationButton.rightAnchor.constraint(equalTo: self.invitationsTableView.rightAnchor, constant: -12).isActive = true
    }
    
    func getInvitationsFromDB() {
        self.store.sharedListStatus.removeAll()
        
        APIClient.selectInvitations(completion: { isSuccessful in

            if isSuccessful {
                OperationQueue.main.addOperation {
                    self.invitationsTableView.reloadData()
                }
            } else {
                OperationQueue.main.addOperation {
                    //self.activityIndicator.isHidden = true  TODO: Add spinner
                }
                self.delegate?.showAlertMessage(message: "Unable to retrieve invitations from the server.")
            }
        })
    }
    
}
