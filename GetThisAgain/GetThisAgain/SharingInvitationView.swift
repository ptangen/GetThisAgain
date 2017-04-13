//
//  SharingInvitationView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/24/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol SharingInvitationViewDelegate: class {
    func showAddInvitation()
    func onTapAcceptInvitation()
    func onTapDeleteInvitation(message: String)
    func showAlertMessage(message: String)
}

class SharingInvitationView: UIView, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: SharingInvitationViewDelegate?
    let store = DataStore.sharedInstance
    let invitationsTableView = UITableView()
    let sectionTitles = ["People I invited to view my list", "People that invited me to view their list"]
    var addInvitationButton = UIButton()
    var acceptInvitationButton = UIButton()
    var deleteInvitationButton = UIButton()
    var selectedSection = Int()
    var selectedAccessRecord: AccessRecord?
    var tabDescription = UILabel()
    var accessListInvitations = Array(repeating: [AccessRecord](), count: 2)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        self.tabDescription.text = "Send an invitation to share your shopping list with someone else. Accept invitations from people that want to share their list with you."
        self.tabDescription.numberOfLines = 0
        
        self.invitationsTableView.delegate = self
        self.invitationsTableView.dataSource = self
        
        // addInvitationButton
        self.addInvitationButton.addTarget(self, action: #selector(self.onTapAddInvitation), for: UIControlEvents.touchUpInside)
        self.addInvitationButton.setTitle(Constants.iconLibrary.add.rawValue, for: .normal)
        self.addInvitationButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.addInvitationButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.addInvitationButton.isEnabled = true
        
        // acceptInvitationButton
        self.acceptInvitationButton.addTarget(self, action: #selector(self.onTapAcceptInvitation), for: UIControlEvents.touchUpInside)
        self.acceptInvitationButton.setTitle(Constants.iconLibrary.check.rawValue, for: .normal)
        self.acceptInvitationButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.acceptInvitationButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.acceptInvitationButton.setTitleColor(UIColor(named: .disabledText), for: .disabled)
        self.acceptInvitationButton.isEnabled = false
        
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
    
    func onTapAddInvitation() {
        if let delegate = self.delegate {
            delegate.showAddInvitation()
        }
    }
    
    func onTapAcceptInvitation() {
        if let delegate = self.delegate {
            if let selectedAccessRecord = self.selectedAccessRecord {
                selectedAccessRecord.status = "accepted"
            }
            delegate.onTapAcceptInvitation()
        }
    }
    
    func onTapDeleteInvitation() {
        if let delegate = self.delegate {
            if let selectedAccessRecord = self.selectedAccessRecord {
                if self.selectedSection == 0 {
                    delegate.onTapDeleteInvitation(message: "Are you sure you want to delete the invitation to '\(selectedAccessRecord.viewer)' to view your shopping list?")
                } else {
                    delegate.onTapDeleteInvitation(message: "Are you sure you want to delete the invitation from '\(selectedAccessRecord.owner)' to view his/her shopping list?")
                }
            }
        }
    }
    
    // tableview config
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // creates a custom label to show the header label. This supports wrapped labels on small screens.
        let label = TableViewHeaderLabel()
        label.text = sectionTitles[section] + ":"
        label.backgroundColor = UIColor(named: .blue)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // the second section label wraps on small screens so must make the heading taller
        if section == 1 && UIScreen.main.bounds.width < 330.0 {
          return 56
        } else {
           return 36
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accessListInvitations[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "prototype")
        
        if let textLabel = cell.textLabel {
            if indexPath.section == 0 {
                self.accessListInvitations[indexPath.section].isEmpty ? (textLabel.text = "none") : (textLabel.text = self.accessListInvitations[indexPath.section][indexPath.row].viewer)
            } else {
                self.accessListInvitations[indexPath.section].isEmpty ? (textLabel.text = "none") : (textLabel.text = self.accessListInvitations[indexPath.section][indexPath.row].owner)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.accessListInvitations[indexPath.section].isEmpty {
            self.selectedAccessRecord = nil
            self.deleteInvitationButton.isEnabled = false
            self.selectedSection = Int()
        } else {
            self.selectedSection = indexPath.section
            self.selectedAccessRecord = self.accessListInvitations[indexPath.section][indexPath.row]
            self.deleteInvitationButton.isEnabled = true
            
            // enable acceptInvitationButton for invitations received
            indexPath.section == 1 ? (self.acceptInvitationButton.isEnabled = true) : (self.acceptInvitationButton.isEnabled = false)
        }
    }
    
    func pageLayout() {
        
        // tabDescription
        self.addSubview(self.tabDescription)
        self.tabDescription.translatesAutoresizingMaskIntoConstraints = false
        self.tabDescription.topAnchor.constraint(equalTo: self.topAnchor, constant: 72).isActive = true
        self.tabDescription.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 6).isActive = true
        self.tabDescription.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        
        // myItemsTableView
        self.addSubview(self.invitationsTableView)
        self.invitationsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.invitationsTableView.topAnchor.constraint(equalTo: self.tabDescription.bottomAnchor, constant: 60).isActive = true
        self.invitationsTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.invitationsTableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.invitationsTableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // delete invitation button
        self.addSubview(self.deleteInvitationButton)
        self.deleteInvitationButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteInvitationButton.bottomAnchor.constraint(equalTo: self.invitationsTableView.topAnchor, constant: -4).isActive = true
        self.deleteInvitationButton.rightAnchor.constraint(equalTo: self.invitationsTableView.rightAnchor, constant: -12).isActive = true
        
        // accept invitation button
        self.addSubview(self.acceptInvitationButton)
        self.acceptInvitationButton.translatesAutoresizingMaskIntoConstraints = false
        self.acceptInvitationButton.bottomAnchor.constraint(equalTo: self.deleteInvitationButton.bottomAnchor).isActive = true
        self.acceptInvitationButton.rightAnchor.constraint(equalTo: self.deleteInvitationButton.leftAnchor, constant: -18).isActive = true
        
        // add invitation button
        self.addSubview(self.addInvitationButton)
        self.addInvitationButton.translatesAutoresizingMaskIntoConstraints = false
        self.addInvitationButton.bottomAnchor.constraint(equalTo: self.acceptInvitationButton.bottomAnchor).isActive = true
        self.addInvitationButton.rightAnchor.constraint(equalTo: self.acceptInvitationButton.leftAnchor, constant: -18).isActive = true
    }
    
    func createArraysForTableView() {

        self.selectedAccessRecord = nil
        self.deleteInvitationButton.isEnabled = false
        
        OperationQueue.main.addOperation {
            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                self.accessListInvitations[0] = self.store.accessList.filter(
                    { $0.owner == userName && $0.viewer != userName && $0.status == "pending" } )
                self.accessListInvitations[1] = self.store.accessList.filter(
                    { $0.viewer == userName && $0.owner != userName && $0.status == "pending" } )
                
                // add messages when no record exists
                self.accessListInvitations[0].isEmpty ? (self.accessListInvitations[0] = [AccessRecord(id: -1, owner: "", viewer: "No pending invitations found.", status: "empty")]) : ()
                self.accessListInvitations[1].isEmpty ? (self.accessListInvitations[1] = [AccessRecord(id: -1, owner: "No pending invitations found.", viewer: "", status: "empty")]) : ()
                
                self.invitationsTableView.reloadData()
            }
        }
    }
}
