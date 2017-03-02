//
//  SignInViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/2/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, SignInViewDelegate {

    var signInViewInst = SignInView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.layoutAnimation()
        self.signInViewInst.delegate = self
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(true, animated: .init(true))
        self.signInViewInst.frame = CGRect.zero
        self.view = self.signInViewInst
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlertMessage(_ message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
    
    func openTabDisplay() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        navigationController?.pushViewController(itemsTabViewControllerInst, animated: false) // show destination with nav bar
    }
    
    func layoutAnimation() {
        // kick off animation in the view
        UIView.animate(withDuration: 0.75) {
            self.signInViewInst.welcomeLabelYConstraintStart.isActive = false
            self.signInViewInst.welcomeLabelYConstraintEnd.isActive = true
            
            self.signInViewInst.productLabelYConstraintStart.isActive = false
            self.signInViewInst.productLabelYConstraintEnd.isActive = true
            
            self.signInViewInst.logoBackgroundYConstraintStart.isActive = false
            self.signInViewInst.logoBackgroundYConstraintEnd.isActive = true
            
            self.signInViewInst.logoImageYConstraintStart.isActive = false
            self.signInViewInst.logoImageYConstraintEnd.isActive = true
            
            self.signInViewInst.signInButtonRightConstraintStart.isActive = false
            self.signInViewInst.signInButtonRightConstraintEnd.isActive = true
            
            self.signInViewInst.layoutIfNeeded()
        }
    }
}
