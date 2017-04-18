//
//  SharingStatusView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/23/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol SharingStatusViewDelegate: class {
    func onTapDeleteUser(message: String)
    func showAlertMessage(message: String)
}

class SharingStatusView: UIView, UITableViewDataSource, UITableViewDelegate  {

    weak var delegate: SharingStatusViewDelegate?
    let store = DataStore.sharedInstance
    let usersWithAccessTableView = UITableView()
    let sectionTitles = ["People that can see my shopping list", "People whose shopping lists I can see"]
    var deleteListFromUserButton = UIButton()
    var selectedSection = Int()
    var selectedAccessRecord: AccessRecord?
    var tabDescription = UILabel()
    var accessListAccepted = Array(repeating: [AccessRecord](), count: 2)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.accessibilityLabel = "sharingStatusViewInst"
        
        self.tabDescription.text = "Review who you are sharing your shopping list with and who is sharing their shopping list with you."
        self.tabDescription.numberOfLines = 0
        
        self.usersWithAccessTableView.delegate = self
        self.usersWithAccessTableView.dataSource = self
        self.usersWithAccessTableView.accessibilityIdentifier = "usersWithAccessTableView"
        
        // deleteListFromUserButton
        self.deleteListFromUserButton.addTarget(self, action: #selector(self.onTapDeleteUser), for: UIControlEvents.touchUpInside)
        self.deleteListFromUserButton.setTitle(Constants.iconLibrary.delete.rawValue, for: .normal)
        self.deleteListFromUserButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.deleteListFromUserButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.deleteListFromUserButton.setTitleColor(UIColor(named: .disabledText), for: .disabled)
        self.deleteListFromUserButton.isEnabled = false
        self.deleteListFromUserButton.accessibilityLabel = "deleteListFromUserButton"
        
        self.pageLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func onTapDeleteUser() {
        if let delegate = self.delegate {
            var message = String()
            if let selectedAccessRecord = self.selectedAccessRecord {
                if self.selectedSection == 0 {
                    message = "Are you sure you want to stop \(selectedAccessRecord.viewer) from viewing your shopping list?"
                } else {
                    message = "Are you sure you want to stop viewing \(selectedAccessRecord.owner)'s shopping list?"
                    selectedAccessRecord.status = "pending"
                }
                delegate.onTapDeleteUser(message: message)
            }
        }
    }
    
    // tableview config
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.accessListAccepted[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // creates a custom label to show the header label. Now there is no wrapping on small screens.
        let label = TableViewHeaderLabel()
        label.text = sectionTitles[section] + ":"
        label.backgroundColor = UIColor(named: .blue)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "prototype")
        
        if let textLabel = cell.textLabel {
            if indexPath.section == 0 {
                self.accessListAccepted[indexPath.section].isEmpty ? (textLabel.text = "none") : (textLabel.text = self.accessListAccepted[indexPath.section][indexPath.row].viewer)
            } else {
                self.accessListAccepted[indexPath.section].isEmpty ? (textLabel.text = "none") : (textLabel.text = self.accessListAccepted[indexPath.section][indexPath.row].owner)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if self.accessListAccepted[indexPath.section].isEmpty {
            self.selectedAccessRecord = nil
            self.deleteListFromUserButton.isEnabled = false
            self.selectedSection = Int()
            
        } else {
            self.selectedSection = indexPath.section
            self.selectedAccessRecord = self.accessListAccepted[indexPath.section][indexPath.row]
            
            // enable/disable the delete button as needed
            if self.accessListAccepted[indexPath.section][indexPath.row].status != "empty" {
                self.deleteListFromUserButton.isEnabled = true
            } else {
                self.deleteListFromUserButton.isEnabled = false
            }
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
        self.addSubview(self.usersWithAccessTableView)
        self.usersWithAccessTableView.translatesAutoresizingMaskIntoConstraints = false
        self.usersWithAccessTableView.topAnchor.constraint(equalTo: self.tabDescription.bottomAnchor, constant: 60).isActive = true
        self.usersWithAccessTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.usersWithAccessTableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.usersWithAccessTableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // delete list from user button
        self.addSubview(self.deleteListFromUserButton)
        self.deleteListFromUserButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteListFromUserButton.bottomAnchor.constraint(equalTo: self.usersWithAccessTableView.topAnchor, constant: -4).isActive = true
        self.deleteListFromUserButton.rightAnchor.constraint(equalTo: self.usersWithAccessTableView.rightAnchor, constant: -12).isActive = true
    }
}
