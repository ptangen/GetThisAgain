//
//  EditNameView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class EditNameView: UIView, UITextViewDelegate {
    
    var itemImageView = UIImageView()
    var nameLabel = UILabel()
    var nameTextView = UITextView()
    var nameTextViewDidChange = false
    var itemExistsInDatastore = false
    var itemInst: MyItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nameLabel.text = "Name"
        self.nameTextView.delegate = self
        self.layoutPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setTextInNameView(textToDisplay: String) {
        // set the comment in the qAnswerView
        if textToDisplay.isEmpty {
            self.nameTextView.text = "Comments"
            self.nameTextView.textColor = UIColor(named: .disabledText)
        } else {
            self.nameTextView.text = textToDisplay
            self.nameTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidBeginEditing(_ nameTextView: UITextView) {
        if nameTextView.textColor == UIColor(named: .disabledText) {
            self.nameTextView.text = nil
            self.nameTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidChange(_ nameTextView: UITextView) {
        self.nameTextViewDidChange = true
    }
    
    func textViewDidEndEditing(_ nameTextView: UITextView) {
        // send text to the DB
        //self.nameTextViewDidChange ? self.updateQAnswer(answer: textView.text) : ()
        if nameTextView.text.isEmpty {
            nameTextView.text = "Comment"
            nameTextView.textColor = UIColor(named: .disabledText)
        }
    }
    
    func layoutPage() {
        
        // itemImageView
        self.addSubview(self.itemImageView)
        self.itemImageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true
        self.itemImageView.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
        self.itemImageView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.48).isActive = true

        // nameTextView
        self.addSubview(self.nameTextView)
        self.nameTextView.translatesAutoresizingMaskIntoConstraints = false
        self.nameTextView.topAnchor.constraint(equalTo: self.itemImageView.bottomAnchor, constant: 50).isActive = true
        self.nameTextView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.nameTextView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.96).isActive = true
        self.nameTextView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        self.nameTextView.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.nameTextView.layer.borderColor = UIColor(named: .blue).cgColor
        self.nameTextView.layer.borderWidth = 1.0
        
        // nameLabel
        self.addSubview(self.nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.bottomAnchor.constraint(equalTo: self.nameTextView.topAnchor, constant: -6).isActive = true
        self.nameLabel.leftAnchor.constraint(equalTo: self.nameTextView.leftAnchor, constant: 0).isActive = true
    }
}
