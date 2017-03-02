//
//  CameraViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
    
    let cameraViewInst = CameraView()
    var updateButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()

        // add cancel button to nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonClicked))
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        // update button
        self.updateButton.style = .plain
        self.updateButton.target = self
        self.updateButton.action = #selector(updateButtonClicked)
        self.updateButton.title = "Update Image"
        self.navigationItem.rightBarButtonItems = [updateButton]
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.cameraViewInst.frame = CGRect.zero
        self.view = self.cameraViewInst
    }
    
    func updateButtonClicked() {
        let itemDetailViewControllerInst = ItemDetailViewController()
        itemDetailViewControllerInst.editMode = true
        itemDetailViewControllerInst.itemInst = self.cameraViewInst.itemInst
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }
    
    func cancelButtonClicked() {
        let itemDetailViewControllerInst = ItemDetailViewController()
        itemDetailViewControllerInst.editMode = true
        itemDetailViewControllerInst.itemInst = self.cameraViewInst.itemInst
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Update Image" // nav bar title
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
