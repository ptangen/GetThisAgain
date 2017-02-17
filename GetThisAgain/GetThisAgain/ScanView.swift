//
//  ScanView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit
import AVFoundation

class ScanView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    
    let btnStartStop = UIButton()
    let viewReader = UIView()
    
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
        
    }
    
    func startStopReading(sender: AnyObject) {
        print("startStopReading")
        
        if isSessionStart == false {
            
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            //let devices = AVCaptureDevice.devices()
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
                    print("adding output to session ")
                    // Add input to the session.
                    captureSession.addInput(input)
                    
                    // Add output to the session.
                    captureSession.addOutput(metaDataOutput);
                }
                
                //output
                let metadataQueue = DispatchQueue(label: "com.mainqueue.reder")
                
                // Send captured data to the delegate object via a serial queue.
                metaDataOutput.setMetadataObjectsDelegate( self, queue: metadataQueue)
                
                // Set barcode type for which to scan: EAN-13.
                metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code]
                
                //// Add previewLayer and have it show the video data.
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                
                let bounds:CGRect = self.viewReader.layer.bounds
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer.bounds = bounds
                previewLayer.position = CGPoint(x: bounds.midX, y:bounds.midY)
                viewReader.layer.addSublayer(previewLayer)
                
                viewReader.isHidden = false
                captureSession.startRunning()
                btnStartStop.setTitle(" Close Barcode Reader ", for: .normal)
                //print("array \(metaDataOutput.metadataObjectTypes)")
            }
            else{
                btnStartStop.setTitle(" Open Barcode Reader ", for: .normal)
                print("no device found")
                self.alert(setMessage: "no device found")
            }
        } else {
            
            btnStartStop.setTitle(" Open Barcode Reader ", for: .normal)
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
        
        print("processing output")
        
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
                        self.alert(setMessage: strDetected)
                        
                        print("strDetected: \(strDetected), barcode type = \(barcodeType)")
                    } else {
                        print("Failed to capture barcode, try again.")
                    }
                    break
                }
            }
        }
    }
    
    func alert(setMessage: String){
        let alert : UIAlertController = UIAlertController(title: "BarCode", message: "\(setMessage)", preferredStyle: .alert)
        let actionOK:UIAlertAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.captureSession.startRunning()
        }
        alert.addAction(actionOK)
        //self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func layoutForm(){
        self.backgroundColor = UIColor.lightGray
        
        // view reader
        self.addSubview(self.viewReader)
        self.viewReader.translatesAutoresizingMaskIntoConstraints = false
        self.viewReader.backgroundColor = UIColor.yellow
        self.viewReader.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        self.viewReader.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        self.viewReader.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        self.viewReader.bottomAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        // sign in button
        self.addSubview(self.btnStartStop)
        self.btnStartStop.translatesAutoresizingMaskIntoConstraints = false
        self.btnStartStop.setTitle(" Open Barcode Reader ", for: .normal)
        self.btnStartStop.backgroundColor = UIColor.brown
        //self.btnStartStop.isEnabled = false
        //self.btnStartStop.alpha = 0.3
        
        self.btnStartStop.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20).isActive = true
        self.btnStartStop.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -110).isActive = true
    }
}

