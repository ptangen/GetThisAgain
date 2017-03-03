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
    let barcodeReader = UIView()
    let barcodeStatusLabel = UILabel()
    let barcodeReaderBorderWidth: CGFloat = 8.0
    
    let snapshotView = UIView()
    let snapshotStatusLabel = UILabel()
    
    // Create a session object.
    var captureSession = AVCaptureSession()
    
    // Create output object.
    var metaDataOutput = AVCaptureMetadataOutput()
    
    var barcodePreviewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice : AVCaptureDevice?
    
    var isBarcodeSessionStart = false
    var isSnapshotSessionStart = false
    
    // camera
    var captureSessionCamera:AVCaptureSession?
    var snapshotPreviewLayer:AVCaptureVideoPreviewLayer?
    var videoCaptureDevice: AVCaptureDevice?
    var input: AnyObject?
    
    override init(frame:CGRect){
        super.init(frame: frame)
        self.layoutForm()
        self.barcodeStatusLabel.text = "Locate the barcode on the item and then enable the barcode reader."
        
        // gesture recognizer for barcodeReader
        let tapReader = UITapGestureRecognizer(target: self, action: #selector(startStopBarcodePreview))
        self.barcodeReader.addGestureRecognizer(tapReader)
        self.barcodeReader.isUserInteractionEnabled = true
        self.barcodeReader.layer.borderWidth = 8
        self.barcodeReader.layer.borderColor = UIColor.white.cgColor
        
        // gesture recognizer for snapshotView
        let tapCamera = UITapGestureRecognizer(target: self, action: #selector(startStopSnapshotPreview))
        self.snapshotView.addGestureRecognizer(tapCamera)
        self.snapshotView.isUserInteractionEnabled = true
        self.snapshotView.layer.borderWidth = 8
        self.snapshotView.layer.borderColor = UIColor.white.cgColor
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
            
            self.videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
            do {
                input = try AVCaptureDeviceInput(device: self.videoCaptureDevice)
            } catch {
                print("video device error")
            }
            self.captureSessionCamera = AVCaptureSession()
            self.captureSessionCamera?.addInput(input as! AVCaptureInput)
            self.snapshotPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSessionCamera)
            self.snapshotPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.snapshotPreviewLayer?.frame = CGRect(x: 0, y: 0, width: self.snapshotView.frame.width, height: self.snapshotView.frame.height)
            self.captureSessionCamera?.startRunning()
            self.snapshotView.layer.addSublayer(self.snapshotPreviewLayer!)

        } else {
            print("stop camera")
            self.captureSessionCamera?.stopRunning()
            self.snapshotPreviewLayer?.removeFromSuperlayer()
        }
        isSnapshotSessionStart = !isSnapshotSessionStart
    }
    
    func startStopBarcodePreview() {
        //print("startStopBarcodePreview \(isBarcodeSessionStart)")
        
        if isBarcodeSessionStart == false {
            
            self.isSnapshotSessionStart ? self.startStopSnapshotPreview() : () // stop the snapshot preview
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
                barcodePreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                // print("preview layer: \(barcodePreviewLayer.session)") // this output changes when function is called from init
                
                let bounds = CGRect(x: 0, y: 0, width: self.barcodeReader.layer.bounds.width - (barcodeReaderBorderWidth * 2),
                                    height: self.barcodeReader.layer.bounds.height - (barcodeReaderBorderWidth * 2))
                barcodePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                barcodePreviewLayer.bounds = bounds
                barcodePreviewLayer.position = CGPoint(x: bounds.midX + barcodeReaderBorderWidth, y:bounds.midY + barcodeReaderBorderWidth)
                barcodeReader.layer.addSublayer(barcodePreviewLayer)
                
                barcodeReader.isHidden = false
                captureSession.startRunning()
                
                self.barcodeStatusLabel.text = "Searching for a barcode..."
                
                print("array \(metaDataOutput.metadataObjectTypes)")
            } else {
                self.barcodeStatusLabel.text = "No device found."
            }
        } else {
            self.captureSession.stopRunning()
            barcodePreviewLayer.removeFromSuperlayer()
        }
        isBarcodeSessionStart = !isBarcodeSessionStart
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
                    barCodeObject = self.barcodePreviewLayer.transformedMetadataObject(for: metadata as! AVMetadataMachineReadableCodeObject)
                    strDetected = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.captureSession.stopRunning()
                    
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
        self.barcodeReader.backgroundColor = UIColor.white
        self.barcodeReader.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "barcode_sample.jpg"))
        self.barcodeReader.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        self.barcodeReader.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        self.barcodeReader.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        self.barcodeReader.bottomAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        // barcodeStatusLabel
        self.addSubview(self.barcodeStatusLabel)
        self.barcodeStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        self.barcodeStatusLabel.topAnchor.constraint(equalTo: self.barcodeReader.bottomAnchor, constant: 20).isActive = true
        self.barcodeStatusLabel.leftAnchor.constraint(equalTo: self.barcodeReader.leftAnchor, constant: 0).isActive = true
        self.barcodeStatusLabel.rightAnchor.constraint(equalTo: self.barcodeReader.rightAnchor, constant: 0).isActive = true
        self.barcodeStatusLabel.numberOfLines = 0
        
        // snapshotView
        self.addSubview(self.snapshotView)
        self.snapshotView.translatesAutoresizingMaskIntoConstraints = false
        self.snapshotView.backgroundColor = UIColor.white
        self.snapshotView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "camera.png"))
        self.snapshotView.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 60).isActive = true
        self.snapshotView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        self.snapshotView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20).isActive = true
        self.snapshotView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
    }
}

