//
//  ItemDetailView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol ItemDetailViewDelegate: class {
    func openEditName(item: MyItem)
}

class ItemDetailView: UIView {

    let store = DataStore.sharedInstance
    weak var delegate: ItemDetailViewDelegate?
    let nameLabel = UILabel()
    let categoryLabel = UILabel()
    let getAgainLabel = UILabel()
    let shoppingListLabel = UILabel()
    let shoppingListSwitch = UISwitch()
    var getAgainPicker = UISegmentedControl()
    var itemImageView = UIImageView()
    var itemInst: MyItem!
    var editTextButton = UIButton()
    var updateRecordRequired = Bool()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.getAgainLabel.text = "Get This Again"
        self.shoppingListLabel.text = "On Shopping List"
        
        // configure segmented control to pick status for the measure
        self.getAgainPicker.insertSegment(withTitle: GetAgain.label(.no)(), at: 0, animated: false)
        self.getAgainPicker.insertSegment(withTitle: GetAgain.label(.unsure)(), at: 1, animated: false)
        self.getAgainPicker.insertSegment(withTitle: GetAgain.label(.yes)(), at: 2, animated: false)
        self.getAgainPicker.selectedSegmentIndex = 1
        self.getAgainPicker.addTarget(self, action: #selector(self.getThisAgainStatusValueChanged(_:)), for: .valueChanged)
        
        self.shoppingListSwitch.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        
        self.editTextButton.addTarget(self, action: #selector(self.onTapItemNameOrIcon), for: UIControlEvents.touchUpInside)
        self.editTextButton.setTitle(Constants.iconLibrary.mode_edit.rawValue, for: .normal)
        self.editTextButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.editTextButton.setTitleColor(UIColor(named: .blue), for: .normal)
        
        // gesture recognizer for nameLabel
        let tapNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.onTapItemNameOrIcon))
        nameLabel.addGestureRecognizer(tapNameLabel)
        nameLabel.isUserInteractionEnabled = true

        self.layoutForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getThisAgainStatusValueChanged(_ sender:UISegmentedControl!) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.itemInst.setGetAgain(status: .no)
        case 1:
            self.itemInst.setGetAgain(status: .unsure)
        default:
            self.itemInst.setGetAgain(status: .yes)
        }
        self.updateRecordRequired = true
    }
    
    func onTapItemNameOrIcon() {
        self.delegate?.openEditName(item: self.itemInst)
    }
    
    func switchStateDidChange(_ sender:UISwitch!) {
        if let myList = self.store.myLists.first {
            sender.isOn ? (self.itemInst.listID = myList.id) : (self.itemInst.listID = 0)
        }
        self.updateRecordRequired = true
    }
    
    func layoutForm(){
        
        // itemImageView
        self.addSubview(self.itemImageView)
        self.itemImageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true
        self.itemImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.itemImageView.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -4).isActive = true
        self.itemImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        
        // nameLabel
        self.addSubview(self.nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.centerYAnchor.constraint(equalTo: self.itemImageView.centerYAnchor, constant: -10).isActive = true
        self.nameLabel.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 6).isActive = true
        self.nameLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        self.nameLabel.numberOfLines = 0
        
        // editTextButton
        self.addSubview(self.editTextButton)
        self.editTextButton.translatesAutoresizingMaskIntoConstraints = false
        self.editTextButton.bottomAnchor.constraint(equalTo: self.nameLabel.topAnchor, constant: -2).isActive = true
        self.editTextButton.rightAnchor.constraint(equalTo: self.nameLabel.rightAnchor, constant: -6).isActive = true
        
        // categoryLabel
        self.addSubview(self.categoryLabel)
        self.categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.categoryLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 2).isActive = true
        self.categoryLabel.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 6).isActive = true
        self.categoryLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        self.categoryLabel.numberOfLines = 0
        self.categoryLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(12.0))
        
        // getAgainLabel
        self.addSubview(self.getAgainLabel)
        self.getAgainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.getAgainLabel.topAnchor.constraint(equalTo: self.itemImageView.bottomAnchor, constant: 24).isActive = true
        self.getAgainLabel.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -12).isActive = true
        
        // getAgainButtons
        let segmentButtonWidth = ((UIScreen.main.bounds.width/2) / 3) - 3
        self.getAgainPicker.setWidth(segmentButtonWidth, forSegmentAt: 0)
        self.getAgainPicker.setWidth(segmentButtonWidth, forSegmentAt: 1)
        self.getAgainPicker.setWidth(segmentButtonWidth, forSegmentAt: 2)
        self.getAgainPicker.tintColor = UIColor(named: .blue)
        
        self.addSubview(self.getAgainPicker)
        self.getAgainPicker.translatesAutoresizingMaskIntoConstraints = false
        self.getAgainPicker.centerYAnchor.constraint(equalTo: self.getAgainLabel.centerYAnchor, constant: 0).isActive = true
        self.getAgainPicker.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.getAgainPicker.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        // shoppingListLabel
        self.addSubview(self.shoppingListLabel)
        self.shoppingListLabel.translatesAutoresizingMaskIntoConstraints = false
        self.shoppingListLabel.topAnchor.constraint(equalTo: self.getAgainLabel.bottomAnchor, constant: 36).isActive = true
        self.shoppingListLabel.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -12).isActive = true
        
        // shoppingListSwitch
        self.addSubview(self.shoppingListSwitch)
        self.shoppingListSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.shoppingListSwitch.centerYAnchor.constraint(equalTo: self.shoppingListLabel.centerYAnchor, constant: 0).isActive = true
        self.shoppingListSwitch.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.shoppingListSwitch.tintColor = UIColor(named: .blue)
        self.shoppingListSwitch.onTintColor = UIColor(named: .blue)
    }
}
