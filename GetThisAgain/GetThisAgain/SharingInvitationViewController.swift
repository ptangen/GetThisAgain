//
//  SharingInvitationViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/24/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class SharingInvitationViewController: UIViewController, SharingInvitationViewDelegate {
    
    let store = DataStore.sharedInstance
    let sharingInvitationViewInst = SharingInvitationView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sharingInvitationViewInst.delegate = self
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.sharingInvitationViewInst.frame = CGRect.zero
        self.view = self.sharingInvitationViewInst
        self.sharingInvitationViewInst.getInvitationsFromDB()
    }
    
    func showAlertMessage(message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
    
    func onTapDeleteInvitation(message: String) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
