//
//  SignInView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/2/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit
import LocalAuthentication

protocol SignInViewDelegate: class {
    func openTabDisplay()
    func showAlertMessage(_: String)
}

class SignInView: UIView, UITextFieldDelegate {

    weak var delegate: SignInViewDelegate?
    
    // controls
    let welcomeLabel = UILabel()
    let productLabel = UILabel()
    let userNameField = UITextField()
    let passwordField = UITextField()
    let signInButton = UIButton()
    let touchIDButton = UIButton()
    var logoImage = UIImageView()
    var userNamePopulated:Bool = false
    var passwordPopulated:Bool = false
    let logoBackground = UIView()
    
    let myKeyChainWrapper = KeychainWrapper()
    var laContext = LAContext()
    
    // constraints
    var welcomeLabelYConstraintStart = NSLayoutConstraint()
    var welcomeLabelYConstraintEnd = NSLayoutConstraint()
    
    var productLabelYConstraintStart = NSLayoutConstraint()
    var productLabelYConstraintEnd = NSLayoutConstraint()
    
    var logoBackgroundYConstraintStart = NSLayoutConstraint()
    var logoBackgroundYConstraintEnd = NSLayoutConstraint()
    var logoImageYConstraintStart = NSLayoutConstraint()
    var logoImageYConstraintEnd = NSLayoutConstraint()
    
    var signInButtonRightConstraintStart = NSLayoutConstraint()
    var signInButtonRightConstraintEnd = NSLayoutConstraint()
    var passwordFieldWidthConstraintStart = NSLayoutConstraint()
    var passwordFieldWidthConstraintEnd = NSLayoutConstraint()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.layoutForm()
        
        // add tag and set delegate for client side validation
        self.userNameField.tag = 100
        self.passwordField.tag = 101
        // set delegates
        self.userNameField.delegate = self
        self.passwordField.delegate = self
        
        self.signInButton.addTarget(self, action: #selector(SignInView.onClickSignIn), for: UIControlEvents.touchUpInside)
        self.touchIDButton.addTarget(self, action: #selector(SignInView.touchIDLoginAction), for: UIControlEvents.touchUpInside)
        
        // if we have a stored userName, populate the userName field with that value.
        if let storedUserName = UserDefaults.standard.value(forKey: "userName") as? String {
            userNameField.text = storedUserName as String
            self.userNamePopulated = true
        }
        
        self.touchIDButton.isHidden = true
        
        if laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            self.touchIDButton.isHidden = false
        }
        
        // accessibility labels
        self.accessibilityLabel = "signInView"
        self.userNameField.accessibilityLabel = "userNameField"
        self.passwordField.accessibilityLabel = "passwordField"
        self.signInButton.accessibilityLabel = "signInButton"
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func onClickSignIn() {
        if let userName = self.userNameField.text {
            if let password = self.passwordField.text {
                
                UserDefaults.standard.setValue(self.userNameField.text, forKey: "userName")
                
                if password == myKeyChainWrapper.myObject(forKey: "v_Data") as? String &&
                    userName == UserDefaults.standard.value(forKey: "userName") as? String {
                    //creds match the keychain and user defaults
                    self.delegate?.openTabDisplay()
                } else {
                    //creds do not match the locally stored creds, validate creds on the server
                    APIClient.requestAuth(userName: userName, password: password, completion: { response in
                        
                        switch response {
                            
                        case .authenticated:
                            // set the password in the keychain
                            self.myKeyChainWrapper.mySetObject(password, forKey:kSecValueData)
                            self.myKeyChainWrapper.writeToKeychain()
                            if let delegate = self.delegate {
                                delegate.openTabDisplay()
                            }
                            break;
                            
                        case.userNameInvalid:
                            self.indicateError(fieldName: self.userNameField)
                            break;
                            
                        case .passwordInvalid:
                            self.indicateError(fieldName: self.passwordField)
                            break;
                            
                        case.noReply:
                            self.delegate?.showAlertMessage("The server is not available. Please forward this message to ptangen@ptangen.com")
                            break;
                            
                        default:
                            break;
                        }
                    }) // end apiClient.requestAuth
                }
            }
        }
    }
    
    func touchIDLoginAction() {
        // 1. Check to see if we have a password for the site in the keychain.
        // 2. Check to see if the device has a finger print reader.
        // 3. Check to see if the fingerprint matches, if success, open tab display
        if myKeyChainWrapper.myObject(forKey: "v_Data") != nil {
            if laContext.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil) {
                laContext.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Sign in with Touch ID", reply: { (success : Bool, error : Error? ) -> Void in
                    
                    DispatchQueue.main.async(execute: {
                        if success {
                            self.delegate?.openTabDisplay()
                        }
                        
                        if let error = error {
                            switch(error._code) {
                            case LAError.authenticationFailed.rawValue:
                                self.delegate?.showAlertMessage("Unable to login with fingerprint. Sign in with your user name and password.")
                                break;
                            default:
                                self.delegate?.showAlertMessage("Touch ID may not be configured")
                                break;
                            }
                        }
                    })
                })
            } else {
                self.delegate?.showAlertMessage("Touch ID not available")
            }
        }
    }
    
    func indicateError(fieldName textFieldWithError: UITextField){
        UIView.animate(withDuration: 1, animations: {
            textFieldWithError.backgroundColor = UIColor.red
            textFieldWithError.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { success in
            UIView.animate(withDuration: 1, animations: {  // reset control to original state
                textFieldWithError.backgroundColor = UIColor.white
                textFieldWithError.transform = CGAffineTransform(scaleX: 1.0, y:1.0)
            })
        })
        self.signInButton.isEnabled = false
        self.signInButton.alpha = 0.3
    }
    
    // monitors the userName/password fields and handles the client side validation
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField.tag {
        case 100:   // check to see if email has a value
            if let userNameText = self.userNameField.text {
                if userNameText.utf16.count > 1 {
                    self.userNamePopulated = true
                } else {
                    self.userNamePopulated = false
                }
                self.enableDisableSignIn()
            }
        case 101: // verify password > 1 characters  - the character count is odd, delete counts as a character...
            if let passwordText = self.passwordField.text {
                if passwordText.utf16.count > 1 {
                    self.passwordPopulated = true
                } else {
                    self.passwordPopulated = false
                }
                self.enableDisableSignIn()
            }
        default: break
        }
        return true
    }
    
    func enableDisableSignIn(){
        if self.userNamePopulated && self.passwordPopulated {
            self.signInButton.isEnabled = true
            self.signInButton.becomeFirstResponder()
            self.signInButton.alpha = 1.0
        } else {
            self.signInButton.isEnabled = false
            self.signInButton.alpha = 0.3
        }
    }
    
    func layoutForm(){
        self.backgroundColor = UIColor(named: .blue)
        self.logoBackground.backgroundColor = UIColor.white
        
        // welcome label
        self.addSubview(self.welcomeLabel)
        self.welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.welcomeLabel.text = "Welcome to"
        self.welcomeLabel.textAlignment = .center
        self.welcomeLabel.textColor = UIColor.white
        
        self.welcomeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.welcomeLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.welcomeLabelYConstraintStart = self.welcomeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: -150)
        self.welcomeLabelYConstraintEnd = self.welcomeLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: UIScreen.main.bounds.height / 10)
        self.welcomeLabelYConstraintStart.isActive = true
        
        // productLabel
        self.productLabel.text = "Get This Again"
        self.productLabel.translatesAutoresizingMaskIntoConstraints = false
        self.productLabel.textAlignment = .center
        self.productLabel.textColor = UIColor.white
        self.productLabel.font = UIFont(name: Constants.appFont.bold.rawValue, size: Constants.fontSize.xlarge.rawValue)
        self.addSubview(self.productLabel)
        
        self.productLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.productLabel.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        self.productLabelYConstraintStart = self.productLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: -130)
        self.productLabelYConstraintStart.isActive = true
        self.productLabelYConstraintEnd = self.productLabel.bottomAnchor.constraint(equalTo: self.topAnchor, constant: UIScreen.main.bounds.height / 5)
        self.productLabelYConstraintEnd.isActive = false
        
        // logoBackground
        self.addSubview(self.logoBackground)
        self.logoBackground.translatesAutoresizingMaskIntoConstraints = false
        self.logoBackground.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.logoBackground.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.logoBackground.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        self.logoBackgroundYConstraintStart = self.logoBackground.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height)
        self.logoBackgroundYConstraintStart.isActive = true
        self.logoBackgroundYConstraintEnd = self.logoBackground.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/2)
        self.logoBackgroundYConstraintEnd.isActive = false
        
        // logo
        self.logoImage.image = UIImage(named: "doubleArrows60-3x.png")
        self.addSubview(self.logoImage)
        self.logoImage.translatesAutoresizingMaskIntoConstraints = false
        
        self.logoImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.logoImage.widthAnchor.constraint(equalToConstant: 180).isActive = true
        self.logoImage.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        logoImageYConstraintStart = self.logoImage.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        logoImageYConstraintStart.isActive = true
        logoImageYConstraintEnd = self.logoImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: UIScreen.main.bounds.height/4)
        logoImageYConstraintEnd.isActive = false
        
        // sign in button
        self.addSubview(self.signInButton)
        self.signInButton.translatesAutoresizingMaskIntoConstraints = false
        self.signInButton.setTitle("  Sign In  ", for: .normal)
        self.signInButton.backgroundColor = UIColor(named: .brown)
        self.signInButton.isEnabled = false
        self.signInButton.alpha = 0.3
        
        self.signInButton.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -20).isActive = true
        
        self.signInButtonRightConstraintStart = self.signInButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 110)
        self.signInButtonRightConstraintStart.isActive = true
        self.signInButtonRightConstraintEnd = self.signInButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20)
        self.signInButtonRightConstraintEnd.isActive = false
        
        // passwordField Field
        self.addSubview(self.passwordField)
        self.passwordField.translatesAutoresizingMaskIntoConstraints = false
        self.passwordField.backgroundColor = UIColor.white
        self.passwordField.borderStyle = .bezel
        self.passwordField.placeholder = "password"
        self.passwordField.isSecureTextEntry = true
        
        self.passwordField.rightAnchor.constraint(equalTo: self.signInButton.rightAnchor, constant: 0).isActive = true
        self.passwordField.bottomAnchor.constraint(equalTo: self.signInButton.topAnchor, constant: -15).isActive = true
        
        self.passwordFieldWidthConstraintStart = self.passwordField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4)
        self.passwordFieldWidthConstraintStart.isActive = true
        self.passwordFieldWidthConstraintEnd = self.passwordField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4)
        self.passwordFieldWidthConstraintEnd.isActive = false
        
        // userName Field
        self.addSubview(self.userNameField)
        self.userNameField.translatesAutoresizingMaskIntoConstraints = false
        self.userNameField.backgroundColor = UIColor.white
        self.userNameField.autocorrectionType = .no
        self.userNameField.autocapitalizationType = .none
        self.userNameField.placeholder = "user name"
        self.userNameField.borderStyle = .bezel
        
        self.userNameField.bottomAnchor.constraint(equalTo: self.passwordField.topAnchor, constant: -15).isActive = true
        self.userNameField.widthAnchor.constraint(equalTo: self.passwordField.widthAnchor).isActive = true
        self.userNameField.rightAnchor.constraint(equalTo: self.passwordField.rightAnchor, constant: 0).isActive = true
        
        // touch id button
        self.addSubview(self.touchIDButton)
        self.touchIDButton.translatesAutoresizingMaskIntoConstraints = false
        self.touchIDButton.setBackgroundImage(#imageLiteral(resourceName: "fingerPrint"), for: .normal)
        
        self.touchIDButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        self.touchIDButton.widthAnchor.constraint(equalToConstant: 36).isActive = true
        self.touchIDButton.rightAnchor.constraint(equalTo: self.signInButton.leftAnchor, constant: -20).isActive = true
        self.touchIDButton.topAnchor.constraint(equalTo: self.signInButton.topAnchor, constant: 0).isActive = true

        // all
        self.layoutIfNeeded()
    }
}
