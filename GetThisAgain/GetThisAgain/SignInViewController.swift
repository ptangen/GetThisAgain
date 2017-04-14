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
    
    func onClickSignIn() {
        if let userName = self.signInViewInst.userNameField.text {
            if let password = self.signInViewInst.passwordField.text {
                
                UserDefaults.standard.setValue(self.signInViewInst.userNameField.text, forKey: "userName")
                
                if password == self.signInViewInst.myKeyChainWrapper.myObject(forKey: "v_Data") as? String &&
                    userName == UserDefaults.standard.value(forKey: "userName") as? String {
                    //creds match the keychain and user defaults
                    self.openTabDisplay()
                } else {
                    //creds do not match the locally stored creds, validate creds on the server
                    APIClient.requestAuth(userName: userName, password: password, completion: { response in
                        
                        switch response {
                            
                        case .authenticated:
                            // set the password in the keychain
                            self.signInViewInst.myKeyChainWrapper.mySetObject(password, forKey:kSecValueData)
                            self.signInViewInst.myKeyChainWrapper.writeToKeychain()
                            self.openTabDisplay()
                            
                        case.userNameInvalid:
                            self.signInViewInst.indicateError(fieldName: self.signInViewInst.userNameField)
                            
                        case .passwordInvalid:
                            self.signInViewInst.indicateError(fieldName: self.signInViewInst.passwordField)
                            
                        case.noReply:
                            self.showAlertMessage("The server is not available. Please forward this message to ptangen@ptangen.com")
                            
                        default:
                            break;
                        }
                    }) // end apiClient.requestAuth
                }
            }
        }
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
