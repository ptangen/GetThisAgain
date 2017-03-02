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
    let btnStartStop = UIButton()
    let viewReader = UIView()
    let statusLabel = UILabel()
    
    // Create a session object.
    var captureSession = AVCaptureSession()
    
    // Create output object.
    var metaDataOutput = AVCaptureMetadataOutput()
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice : AVCaptureDevice?
    
    var isSessionStart = false
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.layoutForm()
        self.btnStartStop.addTarget(self, action: #selector(ScanView.startStopReading), for: UIControlEvents.touchUpInside)
        self.btnStartStop.setTitleColor(UIColor(named: .disabledText), for: .disabled)
        self.statusLabel.text = "Locate the barcode on the item and then enable the barcode reader."
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
                        self.statusLabel.text = "The item was not found in the database."
                        self.startStopReading(sender: self)
                        self.btnStartStop.isEnabled = true
                        self.btnStartStop.backgroundColor = UIColor(named: .blue)
                    }
                }
            })
        }
    }
    
    func startStopReading(sender: AnyObject) {
        //print("startStopReading \(isSessionStart)")
        
        if isSessionStart == false {
            
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            if let deviceDescoverySession = AVCaptureDeviceDiscoverySession.init(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera],
                                                                                 mediaType: AVMediaTypeVideo,
                                                                                 position: AVCaptureDevicePosition.unspecified) {
                
                // Set the captureDevice.
                for device in deviceDescoverySession.devices {
                    // Make sure this particular device supports video
                    if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                        // Finally check the position and confirm we've got the back camera
                        if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                            captureDevice = device
                        }
                    }
                }
            }
            
            if captureDevice != nil {

                // Create input object.
                let input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: captureDevice)
                
                //Session
                if captureSession.canAddOutput(metaDataOutput) && captureSession.canAddInput(input) {
                    //print("adding output to session ")
                    // Add input to the session.
                    captureSession.addInput(input)
                    
                    // Add output to the session.
                    captureSession.addOutput(metaDataOutput)
                }
                
                //output
                let metadataQueue = DispatchQueue(label: "com.mainqueue.reder")
                
                // Send captured data to the delegate object via a serial queue.
                metaDataOutput.setMetadataObjectsDelegate( self, queue: metadataQueue)
                
                // Set barcode type for which to scan: EAN-13.
                metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code]
                
                // Add previewLayer and have it show the video data.
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                // print("preview layer: \(previewLayer.session)") // this output changes when function is called from init
                
                let bounds:CGRect = self.viewReader.layer.bounds
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer.bounds = bounds
                previewLayer.position = CGPoint(x: bounds.midX, y:bounds.midY)
                viewReader.layer.addSublayer(previewLayer)
                
                viewReader.isHidden = false
                captureSession.startRunning()
                
                self.statusLabel.text = "Searching for a barcode..."
                self.btnStartStop.isEnabled = false
                self.btnStartStop.backgroundColor = UIColor.gray
                
                print("array \(metaDataOutput.metadataObjectTypes)")
            } else{
                btnStartStop.setTitle(" Enable Barcode Reader ", for: .normal)
                self.statusLabel.text = "No device found."
            }
        } else {
            btnStartStop.setTitle(" Enable Barcode Reader ", for: .normal)
            self.captureSession.stopRunning()
            previewLayer.removeFromSuperlayer()
        }
        isSessionStart = !isSessionStart
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    //MARK:- AVCaptureMetadataOutputObjectsDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        //print("processing output")
        
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
                    barCodeObject = self.previewLayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    strDetected = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.captureSession.stopRunning()
                    
                    if let strDetected = strDetected {
                        self.getItemInformation(barcodeValue: strDetected)
                        DispatchQueue.main.async {
                            self.statusLabel.text = "Barcode captured. Searching for product information..."
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.statusLabel.text = "Failed to capture barcode, try again."
                        }
                    }
                    break
                }
            }
        }
    }
    
    func layoutForm(){
        self.backgroundColor = UIColor.lightGray
        
        // view reader
        self.addSubview(self.viewReader)
        self.viewReader.translatesAutoresizingMaskIntoConstraints = false
        self.viewReader.backgroundColor = UIColor.white
        self.viewReader.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "barcode_sample.jpg"))
        self.viewReader.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        self.viewReader.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        self.viewReader.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        self.viewReader.bottomAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        // statusLabel
        self.addSubview(self.statusLabel)
        self.statusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusLabel.topAnchor.constraint(equalTo: self.viewReader.bottomAnchor, constant: 20).isActive = true
        self.statusLabel.leftAnchor.constraint(equalTo: self.viewReader.leftAnchor, constant: 0).isActive = true
        self.statusLabel.rightAnchor.constraint(equalTo: self.viewReader.rightAnchor, constant: 0).isActive = true
        self.statusLabel.numberOfLines = 0
        
        // btnStartStop button
        self.addSubview(self.btnStartStop)
        self.btnStartStop.translatesAutoresizingMaskIntoConstraints = false
        self.btnStartStop.setTitle(" Enable Barcode Reader ", for: .normal)
        self.btnStartStop.backgroundColor = UIColor(named: .blue)
        self.btnStartStop.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        self.btnStartStop.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0).isActive = true
    }
}

