//
//  UploadImageToCloudinary.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 4/20/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Cloudinary

class UploadImageToCloudinary: UIViewController,CLUploaderDelegate {
    
    var Cloudinary:CLCloudinary!
    var gotUploaded = false
    
    var observationImage:UIImage?
    var selectedCloset:String?
    var alreadyDidSaveForLater = false
    
    var forUpload = NSData()
    
    func uploadToCloudinary(image: NSData) {
        let infoPath = NSBundle.mainBundle().pathForResource("Info.plist", ofType: nil)!
        let info = NSDictionary(contentsOfFile: infoPath)!
        Cloudinary = CLCloudinary(url: info.objectForKey("CloudinaryAccessUrl") as! String)
        let uploader = CLUploader(Cloudinary, delegate: self)
        uploader.upload(image, options: nil, withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
    }
    
    func onCloudinaryCompletion(successResult:[NSObject : AnyObject]!, errorResult:String!, code:Int, idContext:AnyObject!) {
        
        if (errorResult == nil) {
            let publicId = successResult["public_id"] as! String
            let url = successResult["secure_url"] as? String
            print("now cloudinary uploaded, public id is: \(publicId) and \(url), ready for uploading media")
            if(url != "")
            {
                let userDefaults = NSUserDefaults.standardUserDefaults()
                userDefaults.setValue(url, forKey: "observationImageUrl")
            }
        }
        else {
            print(errorResult.localizedLowercaseString)
        }
        
    }
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:AnyObject!) {
        //do any progress update you may need
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) as Float
        
        print("uploading to cloudinary... wait! \(progress * 100)%")
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("\(progress * 100)", forKey: "progress")
    }
}


