//
//  Observation.swift
//  NatureNet
//
//  Created by James B on 6/29/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import Foundation
import Cloudinary
import Firebase

class ObservationForLater : NSObject, NSCoding, CLUploaderDelegate {
    
    var whereitis: String
    var site: String
    var projectID: String
    var projectKey : String
    var observationDescription : String
    var imageData = NSData()
    var imageURL : String
    var observerID : String
    var longitude : Double
    var latitude : Double
    var email : String
    var password : String
    var imageUploaded : Bool
    var toBeRemoved : Bool
    
    let localNotification:UILocalNotification = UILocalNotification()
    
    // MARK: - *** Initialization ***
    init (whereitis:String, site:String, projectID: String, projectKey:String, observationDescription:String, imageData:NSData, imageURL:String = "", observerID:String, longitude:Double, latitude:Double, email:String, password:String, imageUploaded:Bool)
    {
        self.whereitis = whereitis
        self.site = site
        self.projectID = projectID
        self.projectKey = projectKey
        self.observationDescription = observationDescription
        self.imageData = imageData
        self.imageURL = imageURL
        self.observerID = observerID
        self.longitude = longitude
        self.latitude = latitude
        self.email = email
        self.password = password
        self.imageUploaded = imageUploaded
        self.toBeRemoved = false
    }
    
    // MARK: - *** Encoding and Decoding variables ***
    required init(coder decoder: NSCoder) {
        self.whereitis = decoder.decodeObjectForKey("whereitis") as! String
        self.site = decoder.decodeObjectForKey("site") as! String
        self.projectID = decoder.decodeObjectForKey("projectID") as! String
        self.projectKey = decoder.decodeObjectForKey("projectKey") as! String
        self.observationDescription = decoder.decodeObjectForKey("observationDescription") as! String
        self.imageData = decoder.decodeObjectForKey("imageData") as! NSData
        self.imageURL = decoder.decodeObjectForKey("imageURL") as! String
        self.observerID = decoder.decodeObjectForKey("observerID") as! String
        self.longitude = decoder.decodeDoubleForKey("longitude")
        self.latitude = decoder.decodeDoubleForKey("latitude")
        self.email = decoder.decodeObjectForKey("email") as! String
        self.password = decoder.decodeObjectForKey("password") as! String
        self.imageUploaded = decoder.decodeBoolForKey("imageUploaded")
        self.toBeRemoved = decoder.decodeBoolForKey("successfullyPosted")
        
        super.init()
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.site, forKey: "whereitis")
        coder.encodeObject(self.site, forKey: "site")
        coder.encodeObject(self.projectID, forKey: "projectID")
        coder.encodeObject(self.projectKey, forKey: "projectKey")
        coder.encodeObject(self.observationDescription, forKey: "observationDescription")
        coder.encodeObject(self.imageData, forKey: "imageData")
        coder.encodeObject(self.imageURL, forKey: "imageURL")
        coder.encodeObject(self.observerID, forKey: "observerID")
        coder.encodeDouble(self.longitude, forKey: "longitude")
        coder.encodeDouble(self.latitude, forKey: "latitude")
        coder.encodeObject(self.email, forKey: "email")
        coder.encodeObject(self.password, forKey: "password")
        coder.encodeBool(self.imageUploaded, forKey: "imageUploaded")
        coder.encodeBool(self.toBeRemoved, forKey: "successfullyPosted")
    }

    func decodeString(stringToBeDecoded: String) -> String
    {
        //Encoding and Decoding String
        let base64Decoded = NSData(base64EncodedString: stringToBeDecoded, options:   NSDataBase64DecodingOptions(rawValue: 0))
            .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })

        // Convert back to a string
        print("Decoded:  \(base64Decoded!)")
        
        return base64Decoded as! String
    }
    
    // MARK: - *** Uploading Image to Cloudinary ***
    func upload(){
        
        if (!toBeRemoved) {
            let refUser = FIRAuth.auth()
            refUser!.signInWithEmail(decodeString(email), password: decodeString(password), completion: { authData, error in
                if error != nil {
                    
                    print("\(error)")
                    //incorrect password and user not found respectively
                    if(self.email == "" || error?.code == 17009 || error?.code == 17011) {
                        self.successfullyPostedObservation()
                    }
                    //otherwise we can assume that the internet went out again
                    //and leave the object in the array to be tried again later
                }
                else
                {
                    if !self.imageUploaded {
                        //this function will call the firebase post function when it is done
                        self.uploadImage()
                    } else {
                        self.postToFirebase()
                    }
                }
            })
        } else {
            print("already posted")
        }
    }
    
    private func uploadImage() {
        var Cloudinary:CLCloudinary!
        
        let infoPath = NSBundle.mainBundle().pathForResource("Info.plist", ofType: nil)!
        let info = NSDictionary(contentsOfFile: infoPath)!
        
        Cloudinary = CLCloudinary(url: info.objectForKey("CloudinaryAccessUrl") as! String)
        let uploader = CLUploader(Cloudinary, delegate: self)
        
        localNotification.alertAction = "progress"
        localNotification.alertBody = "Observation Image Uploading in Progress"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        uploader.upload(imageData, options: nil, withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
    }
    
    func onCloudinaryCompletion(successResult:[NSObject : AnyObject]!, errorResult:String!, code:Int, idContext:AnyObject!) {
        if (errorResult == nil) {
            let publicId = successResult["public_id"] as! String
            let url = successResult["secure_url"] as? String
            print("now cloudinary uploaded, public id is: \(publicId) and \(url), ready for uploading media")

            // push media after cloudinary is finished
            if(url != "")
            {
                imageURL = url!
                imageUploaded = true
                postToFirebase()
            }
        }
        else
        {
            print(errorResult.localizedLowercaseString)
        }
    }
    
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:AnyObject!) {
        //do any progress update you may need
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) as Float
        UIApplication.sharedApplication().cancelLocalNotification(localNotification)
        
        print("uploading to cloudinary... wait! \(progress * 100)%")
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("\(progress * 100)", forKey: "progress")
        
        if(progress == 100.0)
        {
            localNotification.alertAction = "progress"
            localNotification.alertBody = "Uploading Finished"
            localNotification.fireDate = NSDate(timeIntervalSinceNow: 5)
            UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        }
    }
    
    // MARK: - *** Posting Data to Firebase ***
    private func postToFirebase() {
     
        let ref = FIRDatabase.database().referenceWithPath("observations")
        print(ref.childByAutoId())
        let autoID = ref.childByAutoId()
        
        if(self.projectKey == ""){
            
            self.projectKey = "-ACES_g38"
        }
        
        print(self.projectKey)
        print(self.projectID)
        print(self.latitude)
        print(self.longitude)
        let currentTimestamp = FIRServerValue.timestamp()
        
        let obsDetails = ["data":["image": imageURL as AnyObject, "text" : self.observationDescription as AnyObject],"l":["0": self.latitude as AnyObject, "1" : self.longitude as AnyObject],"id": autoID.key,"activity": self.projectID,"where": self.whereitis,"site": self.site,"observer":self.observerID, "created_at": FIRServerValue.timestamp(),"updated_at": FIRServerValue.timestamp()]
        autoID.setValue(obsDetails)
        
        print(autoID)
        
        let uRef = FIRDatabase.database().referenceWithPath("users/\(self.observerID)")
        uRef.child("latest_contribution").setValue(currentTimestamp)
        
        let aRef = FIRDatabase.database().referenceWithPath("activities/\(self.projectID)")
        aRef.child("latest_contribution").setValue(currentTimestamp)
        
        successfullyPostedObservation()
        
    }
    
    func successfullyPostedObservation() {
        toBeRemoved = true
        
    }
    
    func equals(obs: ObservationForLater) -> Bool
    {
        return
            self.whereitis == obs.whereitis &&
            self.site == obs.site &&
            self.projectID == obs.projectID &&
            self.projectKey == obs.projectKey &&
            self.observationDescription == obs.observationDescription &&
            self.imageData == obs.imageData &&
            self.observerID == obs.observerID &&
            self.longitude == obs.longitude &&
            self.latitude == obs.latitude &&
            self.email == obs.email &&
            self.password == obs.password
    }
    
    
}