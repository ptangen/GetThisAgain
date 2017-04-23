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
    func buyOnlineTapped(item: MyItem)
}

class ItemDetailView: UIView {

    let store = DataStore.sharedInstance
    weak var delegate: ItemDetailViewDelegate?
    var itemInst: MyItem!
    var updateRecordRequired = Bool()
    
    var editTextButton = UIButton()
    let nameLabel = UILabel()
    let categoryLabel = UILabel()
    var itemImageView = UIImageView()
    var itemImageViewDefaultLeft = NSLayoutConstraint()
    var itemImageViewExpandedLeft = NSLayoutConstraint()
    var itemImageViewDefaultTop = NSLayoutConstraint()
    var itemImageViewExpandedTop = NSLayoutConstraint()
    var itemImageViewDefaultRight = NSLayoutConstraint()
    var itemImageViewExpandedRight = NSLayoutConstraint()
    var itemImageViewDefaultHeight = NSLayoutConstraint()
    var itemImageViewExpandedHeight = NSLayoutConstraint()
    
    let getAgainLabel = UILabel()
    var getAgainPicker = UISegmentedControl()
    
    let shoppingListLabel = UILabel()
    let shoppingListSwitch = UISwitch()
    
    let buyOnlineLabel = UILabel()
    var buyOnlineButton = UIButton()
    
    let activityIndicator = UIView()
    // the activity indicator blocks the tap event so we have to move it off to the side when hidden
    var activityIndicatorXConstraintWhileHidden = NSLayoutConstraint()
    var activityIndicatorXConstraintWhileDisplayed = NSLayoutConstraint()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.accessibilityLabel = "itemDetailViewInst"
        nameLabel.accessibilityLabel = "nameLabel"
        categoryLabel.accessibilityLabel = "categoryLabel"
        
        // editTextButton
        self.editTextButton.addTarget(self, action: #selector(self.onTapItemNameOrIcon), for: UIControlEvents.touchUpInside)
        self.editTextButton.setTitle(Constants.iconLibrary.mode_edit.rawValue, for: .normal)
        self.editTextButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.editTextButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.editTextButton.accessibilityLabel = "editTextButton"
        
        // gesture recognizer for nameLabel
        let tapNameLabel = UITapGestureRecognizer(target: self, action: #selector(self.onTapItemNameOrIcon))
        nameLabel.addGestureRecognizer(tapNameLabel)
        nameLabel.isUserInteractionEnabled = true
        
        // gesture recognizer for image
        let tapItemImageView = UITapGestureRecognizer(target: self, action: #selector(self.onTapItemImageView))
        itemImageView.addGestureRecognizer(tapItemImageView)
        itemImageView.isUserInteractionEnabled = true
        
        // getAgain
        self.getAgainLabel.text = "Get This Again?"
        self.getAgainPicker.insertSegment(with: #imageLiteral(resourceName: "circleTimes"), at: 0, animated: false)
        self.getAgainPicker.insertSegment(with: #imageLiteral(resourceName: "circleQuestion"), at: 1, animated: false)
        self.getAgainPicker.insertSegment(with: #imageLiteral(resourceName: "circleCheck"), at: 2, animated: false)
        self.getAgainPicker.selectedSegmentIndex = 1
        self.getAgainPicker.addTarget(self, action: #selector(self.getThisAgainStatusValueChanged(_:)), for: .valueChanged)
        self.getAgainPicker.accessibilityLabel = "getAgainPicker"
        
        // shopping list
        self.shoppingListLabel.text = "On Shopping List"
        self.shoppingListSwitch.addTarget(self, action: #selector(self.switchStateDidChange(_:)), for: .valueChanged)
        self.shoppingListSwitch.accessibilityLabel = "shoppingListSwitch"
        
        // buyOnline
        self.buyOnlineLabel.text = "Buy Online"
        self.buyOnlineLabel.isHidden = true
        self.buyOnlineButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.buyOnlineButton.backgroundColor = .clear
        self.buyOnlineButton.layer.cornerRadius = 5
        self.buyOnlineButton.layer.borderWidth = 1
        self.buyOnlineButton.layer.borderColor = UIColor(named: .blue).cgColor
        self.buyOnlineButton.addTarget(self, action: #selector(self.buyOnlineTapped), for: UIControlEvents.touchUpInside)
        self.buyOnlineButton.isHidden = true

        self.layoutForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func buyOnlineTapped() {
        self.delegate?.buyOnlineTapped(item: self.itemInst)
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
        if let delegate = self.delegate {
            delegate.openEditName(item: self.itemInst)
        }
    }
    
    func onTapItemImageView() {
        
        // enable/disable constraints to so the larger image.
        if self.itemImageViewDefaultHeight.isActive {
            
            // expand the image and hide the other controls
            UIView.animate(withDuration: 0.75) {
            self.itemImageViewDefaultHeight.isActive = false
            self.itemImageViewDefaultRight.isActive = false
            self.itemImageViewDefaultTop.isActive = false
            self.itemImageViewDefaultLeft.isActive = false
            
            self.itemImageViewExpandedHeight.isActive = true
            self.itemImageViewExpandedRight.isActive = true
            self.itemImageViewExpandedTop.isActive = true
            self.itemImageViewExpandedLeft.isActive = true
            
            self.editTextButton.isHidden = true
            self.nameLabel.isHidden = true
            self.categoryLabel.isHidden = true
            self.getAgainLabel.isHidden = true
            self.getAgainPicker.isHidden = true
            self.shoppingListLabel.isHidden = true
            self.shoppingListSwitch.isHidden = true
            self.buyOnlineLabel.isHidden = true
            self.buyOnlineButton.isHidden = true
                
                self.layoutIfNeeded()
            }
            
        } else {
            // show image at default size and show the other controls
            UIView.animate(withDuration: 0.75, animations: {
                self.itemImageViewExpandedHeight.isActive = false
                self.itemImageViewExpandedRight.isActive = false
                self.itemImageViewExpandedTop.isActive = false
                self.itemImageViewExpandedLeft.isActive = false
                
                self.itemImageViewDefaultHeight.isActive = true
                self.itemImageViewDefaultRight.isActive = true
                self.itemImageViewDefaultTop.isActive = true
                self.itemImageViewDefaultLeft.isActive = true
                
                self.layoutIfNeeded()
                
            }, completion: { (value: Bool) in
                self.editTextButton.isHidden = false
                self.nameLabel.isHidden = false
                self.categoryLabel.isHidden = false
                self.getAgainLabel.isHidden = false
                self.getAgainPicker.isHidden = false
                self.shoppingListLabel.isHidden = false
                self.shoppingListSwitch.isHidden = false
                
                if self.itemInst.merchants > 0 {
                    self.buyOnlineLabel.isHidden = false
                    self.buyOnlineButton.isHidden = false
                }
            })
        }
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

        // top anchors for imageView
        self.itemImageViewDefaultTop = self.itemImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24)
        self.itemImageViewDefaultTop.isActive = true
        self.itemImageViewExpandedTop = self.itemImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        self.itemImageViewExpandedTop.isActive = false
        
        // left anchors for imageView
        self.itemImageViewDefaultLeft = self.itemImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8)
        self.itemImageViewDefaultLeft.isActive = true
        self.itemImageViewExpandedLeft = self.itemImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0)
        self.itemImageViewExpandedLeft.isActive = false
        
        // height anchors for imageView
        self.itemImageViewDefaultHeight = self.itemImageView.heightAnchor.constraint(equalToConstant: 200)
        self.itemImageViewDefaultHeight.isActive = true
        self.itemImageViewExpandedHeight = self.itemImageView.heightAnchor.constraint(equalToConstant: 500)
        self.itemImageViewExpandedHeight.isActive = false
        
        // right anchors for imageView
        self.itemImageViewDefaultRight = self.itemImageView.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -4)
        self.itemImageViewDefaultRight.isActive = true
        self.itemImageViewExpandedRight = self.itemImageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
        self.itemImageViewExpandedRight.isActive = false
        
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
        self.categoryLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.xsmall.rawValue)
        
        // getAgainLabel
        self.addSubview(self.getAgainLabel)
        self.getAgainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.getAgainLabel.topAnchor.constraint(equalTo: self.itemImageView.bottomAnchor, constant: 36).isActive = true
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
        self.shoppingListLabel.topAnchor.constraint(equalTo: self.getAgainLabel.bottomAnchor, constant: 48).isActive = true
        self.shoppingListLabel.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -12).isActive = true
        
        // shoppingListSwitch
        self.addSubview(self.shoppingListSwitch)
        self.shoppingListSwitch.translatesAutoresizingMaskIntoConstraints = false
        self.shoppingListSwitch.centerYAnchor.constraint(equalTo: self.shoppingListLabel.centerYAnchor, constant: 0).isActive = true
        self.shoppingListSwitch.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.shoppingListSwitch.tintColor = UIColor(named: .blue)
        self.shoppingListSwitch.onTintColor = UIColor(named: .blue)
        
        // buyOnlineLabel
        self.addSubview(self.buyOnlineLabel)
        self.buyOnlineLabel.translatesAutoresizingMaskIntoConstraints = false
        self.buyOnlineLabel.topAnchor.constraint(equalTo: self.shoppingListLabel.bottomAnchor, constant: 48).isActive = true
        self.buyOnlineLabel.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -12).isActive = true
        
        // buyOnlineButton
        self.addSubview(self.buyOnlineButton)
        self.buyOnlineButton.translatesAutoresizingMaskIntoConstraints = false
        self.buyOnlineButton.centerYAnchor.constraint(equalTo: self.buyOnlineLabel.centerYAnchor, constant: 0).isActive = true
        self.buyOnlineButton.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.buyOnlineButton.rightAnchor.constraint(equalTo: self.getAgainPicker.rightAnchor).isActive = true
        
        // activityIndicator
        self.addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorXConstraintWhileHidden = self.activityIndicator.centerXAnchor.constraint(equalTo: self.leftAnchor, constant: -40)
        self.activityIndicatorXConstraintWhileDisplayed = self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        self.activityIndicatorXConstraintWhileHidden.isActive = true
        self.activityIndicatorXConstraintWhileDisplayed.isActive = false
        self.activityIndicator.heightAnchor.constraint(equalToConstant: 80).isActive = true
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.activityIndicator.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func showActivityIndicator(uiView: UIView) {
        self.activityIndicatorXConstraintWhileHidden.isActive = false
        self.activityIndicatorXConstraintWhileDisplayed.isActive = true
        
        self.activityIndicator.backgroundColor = UIColor(named: .blue)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.clipsToBounds = true
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: 40, y: 40)
        
        self.activityIndicator.addSubview(actInd)
        actInd.startAnimating()
    }
}
