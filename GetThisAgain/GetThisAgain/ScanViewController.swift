//
//  ScanViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ScanViewController: UIViewController, ScanViewDelegate {
    
    var scanViewInst = ScanView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
        self.scanViewInst.delegate = self
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.scanViewInst.frame = CGRect.zero
        self.view = self.scanViewInst
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Scan the barcode"
        
        // add cancel button to nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonClicked))
        self.navigationItem.rightBarButtonItems = [cancelButton]
        
        //self.scanViewInst.startStopReading(sender: self.scanViewInst.btnStartStop)
    }
    
    func cancelButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
    }
    
    func openItemDetail(item: Item) {
        print(item.barcode)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
