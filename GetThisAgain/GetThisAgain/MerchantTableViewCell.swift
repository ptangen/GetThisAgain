//
//  MerchantTableViewCell.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 4/3/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class MerchantTableViewCell: UITableViewCell {

    var nameLabel = UILabel()
    var merchantLabel = UILabel()
    var priceLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // set the fonts
        self.nameLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.medium.rawValue)
        self.priceLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.priceLabel.textColor = UIColor.gray
        self.merchantLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.merchantLabel.textColor = UIColor.gray
        self.merchantLabel.textAlignment = .right
        
        self.cellLayout()
    }
    
    func cellLayout() {
        
        let marginGuide = contentView.layoutMarginsGuide
        
        //nameLabel
        contentView.addSubview(self.nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.topAnchor.constraint(equalTo: marginGuide.topAnchor).isActive = true
        self.nameLabel.leftAnchor.constraint(equalTo: marginGuide.leftAnchor).isActive = true
        self.nameLabel.rightAnchor.constraint(equalTo: marginGuide.rightAnchor).isActive = true
        self.nameLabel.numberOfLines = 0
        
        //priceLabel
        contentView.addSubview(self.priceLabel)
        self.priceLabel.translatesAutoresizingMaskIntoConstraints = false
        self.priceLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 2).isActive = true
        self.priceLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor, constant: 4).isActive = true
        self.priceLabel.leftAnchor.constraint(equalTo: self.nameLabel.leftAnchor).isActive = true
        
        //merchantLabel
        contentView.addSubview(self.merchantLabel)
        self.merchantLabel.translatesAutoresizingMaskIntoConstraints = false
        self.merchantLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 2).isActive = true
        self.merchantLabel.bottomAnchor.constraint(equalTo: marginGuide.bottomAnchor, constant: 4).isActive = true
        self.merchantLabel.leftAnchor.constraint(equalTo: self.priceLabel.rightAnchor, constant: 12).isActive = true
        self.merchantLabel.rightAnchor.constraint(equalTo: self.nameLabel.rightAnchor).isActive = true
    }
}
