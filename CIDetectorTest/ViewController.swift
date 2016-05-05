//
//  ViewController.swift
//  CIDetectorTest
//
//  Created by Patrick on 5/4/16.
//  Copyright © 2016. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var detectFace: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var smileIndicator: NSTextField!
    
    var appleFaces = [[String:AnyObject?]]()
    let detector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    
    @IBOutlet weak var faceView: NSImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        smileIndicator.font = NSFont.systemFontOfSize(22.0)
        let names = ["jony", "phil", "craig"]
        for name in names {
            appleFaces.append(["name": name.capitalizedString, "picture": NSImage(named: name)])
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // MARK: - Tableview Methods
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return appleFaces.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        // Get Face
        let appleFace = appleFaces[row]
        
        /* GUARD: Is there a name key in the current dictionary? */
        guard let name = appleFace["name"] as? String else {
            print("Error: key 'name' not found")
            return nil
        }
        
        // Construct cell
        let cell = tableView.makeViewWithIdentifier("NameCellID", owner: nil) as? NSTableCellView
        cell!.textField?.stringValue = name
        return cell
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        displayImage()
        
        performUIUpdatesOnMain {
            self.smileIndicator.stringValue = ""
        }
    }
    
    // MARK: - Face/Smile Detection Method
    @IBAction func detectSmile(sender: AnyObject) {
        var resultImage: CIImage?
        /* GUARD: is a row selected? */
        guard (tableView.selectedRow >= 0) else {
            return
        }
        
        if tableView.selectedRow == -1 {
            return
        }
        
        let appleFace = appleFaces[tableView.selectedRow]
        
        /* GUARD: is there an NSImage on the appleFace ? */
        guard let NSImageToDetect = appleFace["picture"] as? NSImage else {
            return
        }
        
        
        /* GUARD: Did the image convert to a CIImage successfully? */
        guard let imageToDetect = NSImageToDetect.toCIImage() else {
            print("Error converting to CIImage")
            return
        }

        let faceFeature = (detector.featuresInImage(imageToDetect,options: [ CIDetectorSmile: true ])).first as! CIFaceFeature
        
        resultImage = drawOverlayForFaceFeature(imageToDetect, overlayBounds: faceFeature.bounds)
        
        performUIUpdatesOnMain {
            self.faceView.image = resultImage!.toNSImage()
            self.displaySmileIndicator(faceFeature)
        }
    
    }
    
    // MARK: - Image Manipulation Methods
    func drawOverlayForFaceFeature(image: CIImage, overlayBounds: CGRect) -> CIImage {
        var overlay = CIImage(color: CIColor(red: 1.0, green: 0, blue: 0, alpha: 0.3))
        overlay = overlay.imageByCroppingToRect(overlayBounds)
        return overlay.imageByCompositingOverImage(image)
    }
    
    func displaySmileIndicator(feature: CIFaceFeature) {
        if feature.hasSmile {
            self.smileIndicator.stringValue = "😀"
        } else {
            self.smileIndicator.stringValue = "😐"
        }
    }
    
    func displayImage() {
        let row = tableView.selectedRow
        if row == -1 {
            return
        }
        let appleFace = appleFaces[row]
        
        /* GUARD: Is there a picture on the current dictionary? */
        guard let picture = appleFace["picture"] as? NSImage else {
            print("Error: No picture on current entry")
            return
        }
        
        performUIUpdatesOnMain {
            self.faceView.image = picture
        }
    }
    
}

// MARK: - Conversion Methods

extension CIImage {
     func toNSImage() -> NSImage {
        let rep = NSCIImageRep(CIImage: self)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
    
        return nsImage
    }
}

extension NSImage {
    func toCIImage() -> CIImage? {
        let resultImage = CIImage()
        let tiffData = self.TIFFRepresentation!
        if let bitmapImageRep = NSBitmapImageRep(data: tiffData), resultImage = CIImage(bitmapImageRep: bitmapImageRep) {
            return resultImage
        }
        return resultImage
    }
}

