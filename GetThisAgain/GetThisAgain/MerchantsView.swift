//
//  MerchantsView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 4/3/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class MerchantsView: UIView, UITableViewDelegate, UITableViewDataSource {
    
    let store = DataStore.sharedInstance
    var itemInst: MyItem!
    var merchants = [Merchant]()
    
    let nameLabel = UILabel()
    let categoryLabel = UILabel()
    var itemImageView = UIImageView()
    
    var merchantsTableView = UITableView()
    
    let activityIndicator = UIView()
    // the activity indicator blocks the tap event so we have to move it off to the side when hidden
    var activityIndicatorXConstraintWhileHidden = NSLayoutConstraint()
    var activityIndicatorXConstraintWhileDisplayed = NSLayoutConstraint()

    override init(frame:CGRect){
        super.init(frame: frame)
        
        self.merchantsTableView.delegate = self
        self.merchantsTableView.dataSource = self
        //self.merchantsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "prototype")
        self.merchantsTableView.register(MerchantTableViewCell.self, forCellReuseIdentifier: "prototype")
  
        self.layoutForm()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.merchants.count
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MerchantTableViewCell(style: .default, reuseIdentifier: "prototype")
        cell.nameLabel.text = self.merchants[indexPath.row].itemName
        cell.priceLabel.text = "$ \(String(self.merchants[indexPath.row].price))"
        cell.merchantLabel.text = self.merchants[indexPath.row].merchant
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let url = URL(string: self.merchants[indexPath.row].url) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                //If you want handle the completion block than
                UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                    print("Open url : \(success)")
                })
            }
        }
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
        
        // categoryLabel
        self.addSubview(self.categoryLabel)
        self.categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.categoryLabel.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 2).isActive = true
        self.categoryLabel.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 6).isActive = true
        self.categoryLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -6).isActive = true
        self.categoryLabel.numberOfLines = 0
        self.categoryLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.xsmall.rawValue)
        
        // merchantsTableView
        self.addSubview(self.merchantsTableView)
        self.merchantsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.merchantsTableView.topAnchor.constraint(equalTo: self.itemImageView.bottomAnchor, constant: 50).isActive = true
        self.merchantsTableView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.merchantsTableView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
        self.merchantsTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
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
