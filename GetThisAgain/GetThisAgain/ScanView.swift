//
//  ScanView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit
import AVFoundation

protocol ScanViewDelegate: class {
    func openItemDetail(item: MyItem, editMode: Bool)
}

class ScanView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: ScanViewDelegate?
    let store = DataStore.sharedInstance
    let previewBorderWidth: CGFloat = 8.0
    
    // barcodeReader
    let barcodeReader = UIView()
    let barcodeStatusLabel = UILabel()
    var captureSessionBarcode = AVCaptureSession()
    var metaDataOutputBarcode = AVCaptureMetadataOutput() // Create output object.
    var previewLayerBarcode = AVCaptureVideoPreviewLayer()
    var captureDeviceBarcode : AVCaptureDevice?
    let backgroundImageBarcode: UIImageView = UIImageView(image: #imageLiteral(resourceName: "barcode_sample.png")) // barcode_sample.png
    var isBarcodeSessionStart = false
    
    // snapshot
    let snapshotView = UIView()
    let snapshotStatusLabel = UILabel()
    var captureSessionSnapshot = AVCaptureSession()
    var previewLayerSnapshot = AVCaptureVideoPreviewLayer()
    var captureDeviceSnapshot: AVCaptureDevice?
    var inputSnapshot: AnyObject?
    let backgroundImageCamera: UIImageView = UIImageView(image: #imageLiteral(resourceName: "camera.png")) // camera.png
    var isSnapshotSessionStart = false
    
    var barcodeReaderTopConstraintInitial = NSLayoutConstraint()
    var barcodeReaderTopConstraintActive = NSLayoutConstraint()
    var barcodeReaderTopConstraintInactive = NSLayoutConstraint()
    
    var barcodeReaderHeightConstraintInitial = NSLayoutConstraint()
    var barcodeReaderHeightConstraintActive = NSLayoutConstraint()
    var barcodeReaderHeightConstraintInactive = NSLayoutConstraint()
    
    var barcodeReaderWidthConstraintInitial = NSLayoutConstraint()
    var barcodeReaderWidthConstraintActive = NSLayoutConstraint()
    var barcodeReaderWidthConstraintInactive = NSLayoutConstraint()
    
    var snapshotViewHeightConstraintInitial = NSLayoutConstraint()
    var snapshotViewHeightConstraintActive = NSLayoutConstraint()
    var snapshotViewHeightConstraintInactive = NSLayoutConstraint()

    var snapshotViewWidthConstraintInitial = NSLayoutConstraint()
    var snapshotViewWidthConstraintActive = NSLayoutConstraint()
    var snapshotViewWidthConstraintInactive = NSLayoutConstraint()
    
    var snapshotViewBottomConstraintInitial = NSLayoutConstraint()
    var snapshotViewBottomConstraintActive = NSLayoutConstraint()
    var snapshotViewBottomConstraintInactive = NSLayoutConstraint()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.layoutForm()
        self.barcodeStatusLabel.text = "Scan the Barcode"
        self.snapshotStatusLabel.text = "Take a Snapshot"
        
        // gesture recognizer for barcodeReader
        let tapReader = UITapGestureRecognizer(target: self, action: #selector(startStopBarcodePreview))
        self.barcodeReader.addGestureRecognizer(tapReader)
        self.barcodeReader.isUserInteractionEnabled = true
        self.barcodeReader.layer.borderWidth = 8
        self.barcodeReader.layer.borderColor = UIColor.clear.cgColor
        
        // gesture recognizer for snapshotView
        let tapCamera = UITapGestureRecognizer(target: self, action: #selector(startStopSnapshotPreview))
        self.snapshotView.addGestureRecognizer(tapCamera)
        self.snapshotView.isUserInteractionEnabled = true
        self.snapshotView.layer.borderWidth = 8
        self.snapshotView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func addSnapshotViewCameraImage(){
        let backgroundImage: UIImageView = UIImageView(frame: self.snapshotView.bounds)  //centerView.bounds)
        backgroundImage.clipsToBounds = true
        backgroundImage.image = #imageLiteral(resourceName: "camera.png")
        backgroundImage.contentMode = .scaleAspectFill
        self.snapshotView.addSubview(backgroundImage)
    }
    
    func getItemInformation(barcodeValue: String) {
        
        if let itemInst = self.store.getItemFromBarcode(barcode: barcodeValue) {
            // we have the item that was scanned in the datastore so show the item detail
            DispatchQueue.main.async {
                self.delegate?.openItemDetail(item: itemInst, editMode: true)
            }
        } else {
            // we dont have the item in the datastore so fetch it from the API
            APIClient.getEandataFromAPI(barcode: barcodeValue, completion: {itemInst in
                if itemInst.barcode != "notFound" {
                    DispatchQueue.main.async {
                        self.delegate?.openItemDetail(item: itemInst, editMode: false)
                    }
                } else {
                    // display not found message
                    DispatchQueue.main.async {
                        self.barcodeStatusLabel.text = "The item was not found in the database."
                        self.startStopBarcodePreview()
                    }
                }
            })
        }
    }
    
    func startStopSnapshotPreview() {
        //print("startStopSnapshotPreview \(isSnapshotSessionStart)")
        
        if isSnapshotSessionStart == false {
            self.isBarcodeSessionStart ? self.startStopBarcodePreview() : () // stop the barcode preview
            
            if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                                 mediaType: AVMediaTypeVideo,
                                                                                 position: AVCaptureDevicePosition.unspecified) {
                // Set the captureDevice.
                for device in deviceDescoverySession.devices {
                    // Make sure this particular device supports video
                    if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                        // Finally check the position and confirm we've got the back camera
                        if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                            self.captureDeviceSnapshot = device
                        }
                    }
                }
            }

            if self.captureDeviceSnapshot != nil {
                
                let input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: self.captureDeviceSnapshot) // Create input object
                
                if (self.captureSessionSnapshot.canAddInput(input)) {  // add input to session
                    self.captureSessionSnapshot.addInput(input)
                    
                }
                
                UIView.animate(withDuration: 0.75, animations: {  // display the preview
                    // resize the snapshotview -> Active
                    self.snapshotViewHeightConstraintInitial.isActive = false
                    self.snapshotViewHeightConstraintInactive.isActive = false
                    self.snapshotViewHeightConstraintActive.isActive = true
                    
                    self.snapshotViewWidthConstraintInitial.isActive = false
                    self.snapshotViewWidthConstraintInactive.isActive = false
                    self.snapshotViewWidthConstraintActive.isActive = true
                    
                    self.snapshotViewBottomConstraintInitial.isActive = false
                    self.snapshotViewBottomConstraintInactive.isActive = false
                    self.snapshotViewBottomConstraintActive.isActive = true
                    
                    // resize the barcode view -? Inactive
                    self.barcodeReaderTopConstraintInitial.isActive = false
                    self.barcodeReaderTopConstraintActive.isActive = false
                    self.barcodeReaderTopConstraintInactive.isActive = true
                    
                    self.barcodeReaderHeightConstraintInitial.isActive = false
                    self.barcodeReaderHeightConstraintActive.isActive = false
                    self.barcodeReaderHeightConstraintInactive.isActive = true
                    
                    self.barcodeReaderWidthConstraintInitial.isActive = false
                    self.barcodeReaderWidthConstraintActive.isActive = false
                    self.barcodeReaderWidthConstraintInactive.isActive = true
                    
                    self.barcodeStatusLabel.text = nil
                    self.barcodeReader.layer.borderColor = UIColor.clear.cgColor
                    
                    self.layoutIfNeeded()
                    
                }, completion: { (true) in
                    self.previewLayerSnapshot = AVCaptureVideoPreviewLayer(session: self.captureSessionSnapshot)
                    self.previewLayerSnapshot.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.previewLayerSnapshot.frame = CGRect(x: self.previewBorderWidth, y: self.previewBorderWidth, width: self.snapshotView.frame.width - (self.previewBorderWidth * 2), height: self.snapshotView.frame.height - (self.previewBorderWidth * 2))

                    self.snapshotView.layer.addSublayer(self.previewLayerSnapshot)
                    self.captureSessionSnapshot.startRunning()
                    
                    // show label and frame
                    self.snapshotStatusLabel.text = "Take a Snapshot"
                    self.snapshotView.layer.borderColor = UIColor.white.cgColor
                })
            } else {
                self.snapshotStatusLabel.text = "No device found."
            }

        } else {
            self.captureSessionSnapshot.stopRunning()
            self.previewLayerSnapshot.removeFromSuperlayer()
        }
        isSnapshotSessionStart = !isSnapshotSessionStart
    }
    
    func startStopBarcodePreview() {
        //print("startStopBarcodePreview \(isBarcodeSessionStart)")
        
        if isBarcodeSessionStart == false {
            
            self.isSnapshotSessionStart ? self.startStopSnapshotPreview() : () // stop the snapshot preview
            captureSessionBarcode.sessionPreset = AVCaptureSessionPresetHigh
            
            if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                                 mediaType: AVMediaTypeVideo,
                                                                                 position: AVCaptureDevicePosition.unspecified) {
                // Set the captureDevice.
                for device in deviceDescoverySession.devices {
                    // Make sure this particular device supports video
                    if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                        // Finally check the position and confirm we've got the back camera
                        if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                            self.captureDeviceBarcode = device
                        }
                    }
                }
            }
            
            if self.captureDeviceBarcode != nil {

                // Create input object.
                let input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: self.captureDeviceBarcode)
                
                //Session
                if captureSessionBarcode.canAddOutput(metaDataOutputBarcode) && captureSessionBarcode.canAddInput(input) {
                    captureSessionBarcode.addInput(input)
                    captureSessionBarcode.addOutput(metaDataOutputBarcode)
                }
                
                //output
                let metadataQueue = DispatchQueue(label: "com.mainqueue.reder")
                
                // Send captured data to the delegate object via a serial queue.
                metaDataOutputBarcode.setMetadataObjectsDelegate( self, queue: metadataQueue)
                
                // Set barcode type for which to scan: EAN-13.
                //metaDataOutputBarcode.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code]
            
                UIView.animate(withDuration: 0.75, animations: {
                    // resize the barcode preview - Active
                    self.barcodeReaderTopConstraintInitial.isActive = false
                    self.barcodeReaderTopConstraintInactive.isActive = false
                    self.barcodeReaderTopConstraintActive.isActive = true
                    
                    self.barcodeReaderHeightConstraintInitial.isActive = false
                    self.barcodeReaderHeightConstraintInactive.isActive = false
                    self.barcodeReaderHeightConstraintActive.isActive = true

                    self.barcodeReaderWidthConstraintInitial.isActive = false
                    self.barcodeReaderWidthConstraintInactive.isActive = false
                    self.barcodeReaderWidthConstraintActive.isActive = true
                
                    // resize the snapshot preview - Inactive
                    self.snapshotViewHeightConstraintInitial.isActive = false
                    self.snapshotViewHeightConstraintActive.isActive = false
                    self.snapshotViewHeightConstraintInactive.isActive = true
                    
                    self.snapshotViewWidthConstraintInitial.isActive = false
                    self.snapshotViewWidthConstraintActive.isActive = false
                    self.snapshotViewWidthConstraintInactive.isActive = true
                    
                    self.snapshotViewBottomConstraintInitial.isActive = false
                    self.snapshotViewBottomConstraintActive.isActive = false
                    self.snapshotViewBottomConstraintInactive.isActive = true
                    
                    self.snapshotStatusLabel.text = nil
                    self.snapshotView.layer.borderColor = UIColor.clear.cgColor
                    
                    self.layoutIfNeeded()
                }, completion: { (true) in
                    // Add previewLayer and show the preview
                    self.previewLayerBarcode = AVCaptureVideoPreviewLayer(session: self.captureSessionBarcode)
                    self.previewLayerBarcode.videoGravity = AVLayerVideoGravityResizeAspectFill
                    self.previewLayerBarcode.frame = CGRect(x: self.previewBorderWidth, y: self.previewBorderWidth, width: self.barcodeReader.frame.width - (self.previewBorderWidth * 2), height: self.barcodeReader.frame.height - (self.previewBorderWidth * 2))
                    self.barcodeReader.layer.addSublayer(self.previewLayerBarcode)
                    
                    self.barcodeReader.isHidden = false
                    self.captureSessionBarcode.startRunning()
                    
                    self.barcodeStatusLabel.text = "Searching for a barcode..."
                    self.barcodeReader.layer.borderColor = UIColor.white.cgColor
                })
                
                //print("array \(metaDataOutputBarcode.metadataObjectTypes)")
            } else {
                self.barcodeStatusLabel.text = "No device found."
            }
        } else {
            self.captureSessionBarcode.stopRunning()
            previewLayerBarcode.removeFromSuperlayer()
        }
        isBarcodeSessionStart = !isBarcodeSessionStart
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK:- AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {

        var barCodeObject: AVMetadataObject!
        var strDetected: String?
        
        //All the bar code types defined here
        let barCodeTypes = [AVMetadataObjectTypeFace,
                            AVMetadataObjectTypeQRCode,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeUPCECode,
                            AVMetadataObjectTypeAztecCode,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeITF14Code,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypeDataMatrixCode,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeInterleaved2of5Code]
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        // Get the object from the metadataObjects array.
        for metadata in metadataObjects! {
            
            for barcodeType in barCodeTypes {
                
                if (metadata as AnyObject).type == barcodeType {
                    barCodeObject = self.previewLayerBarcode.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    strDetected = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.captureSessionBarcode.stopRunning()
                    
                    if let strDetected = strDetected {
                        self.getItemInformation(barcodeValue: strDetected)
                        DispatchQueue.main.async {
                            self.barcodeStatusLabel.text = "Barcode captured. Searching for product information..."
                            self.barcodeReader.layer.borderWidth = 8
                            self.barcodeReader.layer.borderColor = UIColor.green.cgColor
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.barcodeStatusLabel.text = "Failed to capture barcode, try again."
                        }
                    }
                    break
                }
            }
        }
    }
    
    func layoutForm(){
        self.backgroundColor = UIColor.lightGray
        
        // barcode reader
        self.addSubview(self.barcodeReader)
        self.barcodeReader.translatesAutoresizingMaskIntoConstraints = false
        self.barcodeReader.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.barcodeReaderTopConstraintInitial = self.barcodeReader.topAnchor.constraint(equalTo: self.topAnchor, constant: (UIScreen.main.bounds.height/8))
        self.barcodeReaderTopConstraintInitial.isActive = true
        self.barcodeReaderTopConstraintActive = self.barcodeReader.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        self.barcodeReaderTopConstraintActive.isActive = false
        self.barcodeReaderTopConstraintInactive = self.barcodeReader.topAnchor.constraint(equalTo: self.topAnchor, constant: (UIScreen.main.bounds.height/12))
        self.barcodeReaderTopConstraintInactive.isActive = false
        
        self.barcodeReaderWidthConstraintInitial = self.barcodeReader.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2)
        self.barcodeReaderWidthConstraintInitial.isActive = true
        self.barcodeReaderWidthConstraintActive = self.barcodeReader.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        self.barcodeReaderWidthConstraintActive.isActive = false
        self.barcodeReaderWidthConstraintInactive = self.barcodeReader.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/4)
        self.barcodeReaderWidthConstraintInactive.isActive = false
        
        self.barcodeReaderHeightConstraintInitial = self.barcodeReader.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/4)
        self.barcodeReaderHeightConstraintInitial.isActive = true
        self.barcodeReaderHeightConstraintActive = self.barcodeReader.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/2)
        self.barcodeReaderHeightConstraintActive.isActive = false
        self.barcodeReaderHeightConstraintInactive = self.barcodeReader.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/8)
        self.barcodeReaderHeightConstraintInactive.isActive = false
        
        // backgroundImageBarcode
        self.barcodeReader.addSubview(self.backgroundImageBarcode)
        self.backgroundImageBarcode.contentMode = .scaleAspectFit
        self.backgroundImageBarcode.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageBarcode.topAnchor.constraint(equalTo: self.barcodeReader.topAnchor).isActive = true
        self.backgroundImageBarcode.leftAnchor.constraint(equalTo: self.barcodeReader.leftAnchor).isActive = true
        self.backgroundImageBarcode.rightAnchor.constraint(equalTo: self.barcodeReader.rightAnchor).isActive = true
        self.backgroundImageBarcode.bottomAnchor.constraint(equalTo: self.barcodeReader.bottomAnchor).isActive = true
        
        // barcodeStatusLabel
        self.addSubview(self.barcodeStatusLabel)
        self.barcodeStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.barcodeStatusLabel.topAnchor.constraint(equalTo: self.barcodeReader.bottomAnchor, constant: 4).isActive = true
        self.barcodeStatusLabel.leftAnchor.constraint(equalTo: self.barcodeReader.leftAnchor, constant: self.previewBorderWidth).isActive = true
        self.barcodeStatusLabel.numberOfLines = 0
        
        // snapshotView
        self.addSubview(self.snapshotView)
        self.snapshotView.translatesAutoresizingMaskIntoConstraints = false
        self.snapshotView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.snapshotViewHeightConstraintInitial = self.snapshotView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/4)
        self.snapshotViewHeightConstraintInitial.isActive = true
        self.snapshotViewHeightConstraintActive = self.snapshotView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/2)
        self.snapshotViewHeightConstraintActive.isActive = false
        self.snapshotViewHeightConstraintInactive = self.snapshotView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height/8)
        self.snapshotViewHeightConstraintInactive.isActive = false
        
        self.snapshotViewWidthConstraintInitial = self.snapshotView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/2)
        self.snapshotViewWidthConstraintInitial.isActive = true
        self.snapshotViewWidthConstraintActive = self.snapshotView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        self.snapshotViewWidthConstraintActive.isActive = false
        self.snapshotViewWidthConstraintInactive = self.snapshotView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/4)
        self.snapshotViewWidthConstraintInactive.isActive = false
        
        self.snapshotViewBottomConstraintInitial = self.snapshotView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: (UIScreen.main.bounds.height/8 * -1))
        self.snapshotViewBottomConstraintInitial.isActive = true
        self.snapshotViewBottomConstraintActive = self.snapshotView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        self.snapshotViewBottomConstraintActive.isActive = false
        self.snapshotViewBottomConstraintInactive = self.snapshotView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: (UIScreen.main.bounds.height/12 * -1))
        self.snapshotViewBottomConstraintInactive.isActive = false
        
        // backgroundImageCamera
        self.snapshotView.addSubview(self.backgroundImageCamera)
        self.backgroundImageCamera.contentMode = .scaleAspectFit
        self.backgroundImageCamera.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageCamera.topAnchor.constraint(equalTo: self.snapshotView.topAnchor).isActive = true
        self.backgroundImageCamera.leftAnchor.constraint(equalTo: self.snapshotView.leftAnchor).isActive = true
        self.backgroundImageCamera.rightAnchor.constraint(equalTo: self.snapshotView.rightAnchor).isActive = true
        self.backgroundImageCamera.bottomAnchor.constraint(equalTo: self.snapshotView.bottomAnchor).isActive = true
        
        // snapshotStatusLabel
        self.addSubview(self.snapshotStatusLabel)
        self.snapshotStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.snapshotStatusLabel.bottomAnchor.constraint(equalTo: self.snapshotView.topAnchor, constant: -4).isActive = true
        self.snapshotStatusLabel.leftAnchor.constraint(equalTo: self.snapshotView.leftAnchor, constant: self.previewBorderWidth).isActive = true
        self.snapshotStatusLabel.numberOfLines = 0
    }
}

