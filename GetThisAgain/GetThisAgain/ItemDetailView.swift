//
//  ItemDetailView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ItemDetailView: UIView {

    let nameLabel = UILabel()
    let getThisAgainLabel = UILabel()
    var getThisAgainPicker = UISegmentedControl()
    let itemImageView = UIImageView()
    var itemInst: Item!
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.getThisAgainLabel.text = "Get This Again"
        
        // configure segmented control to pick status for the measure
        self.getThisAgainPicker.insertSegment(withTitle: GetThisAgain.label(.no)(), at: 0, animated: true)
        self.getThisAgainPicker.insertSegment(withTitle: GetThisAgain.label(.unsure)(), at: 1, animated: true)
        self.getThisAgainPicker.insertSegment(withTitle: GetThisAgain.label(.yes)(), at: 2, animated: true)
        self.getThisAgainPicker.selectedSegmentIndex = 1

        self.layoutForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func statusValueChanged(_ sender:UISegmentedControl!) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            self.itemInst.setGetThisAgain(status: .no)
        case 1:
            self.itemInst.setGetThisAgain(status: .unsure)
        default:
            self.itemInst.setGetThisAgain(status: .yes)
        }
    }
    
    func layoutForm(){
        
        // itemImageView
        self.addSubview(self.itemImageView)
        self.itemImageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true
        self.itemImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        self.itemImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4).isActive = true
        
        // nameLabel
        self.addSubview(self.nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.topAnchor.constraint(equalTo: self.itemImageView.topAnchor).isActive = true
        self.nameLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        self.nameLabel.rightAnchor.constraint(equalTo: self.itemImageView.leftAnchor, constant: -6).isActive = true
        self.nameLabel.numberOfLines = 0
        
        // getThisAgainLabel
        self.addSubview(self.getThisAgainLabel)
        self.getThisAgainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.getThisAgainLabel.topAnchor.constraint(equalTo: self.itemImageView.bottomAnchor, constant: 12).isActive = true
        self.getThisAgainLabel.leftAnchor.constraint(equalTo: self.nameLabel.leftAnchor).isActive = true
        
        // getThisAgainSwitch
        let segmentButtonWidth = (UIScreen.main.bounds.width / 3) - 10
        self.getThisAgainPicker.setWidth(segmentButtonWidth, forSegmentAt: 0)
        self.getThisAgainPicker.setWidth(segmentButtonWidth, forSegmentAt: 1)
        self.getThisAgainPicker.setWidth(segmentButtonWidth, forSegmentAt: 2)
        self.getThisAgainPicker.tintColor = UIColor(named: .blue)
        
        self.addSubview(self.getThisAgainPicker)
        self.getThisAgainPicker.translatesAutoresizingMaskIntoConstraints = false
        self.getThisAgainPicker.topAnchor.constraint(equalTo: self.getThisAgainLabel.bottomAnchor, constant: 12).isActive = true
        self.getThisAgainPicker.leftAnchor.constraint(equalTo: self.getThisAgainLabel.leftAnchor, constant: 0).isActive = true
        self.getThisAgainPicker.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
}
