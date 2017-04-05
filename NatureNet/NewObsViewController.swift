//
//  NewObsViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 4/13/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase
import Cloudinary
import MapKit
import CoreLocation
import Cloudinary

class NewObsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,CLLocationManagerDelegate,CLUploaderDelegate {

    @IBOutlet weak var observationDetailsTableView: UITableView!
    @IBOutlet weak var observationImageView: UIImageView!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var whereitisTextView: UITextView!
    var obsImage : UIImage = UIImage(named: "default-no-image.png")!
    
    var items: [String] = ["Select a Project"]
    
    var projectKey : String = ""
    var descText :String = ""
    var userID :String = ""
    
    var imageForUpload = NSData()
    
    let locationManager = CLLocationManager()
    var locValue = CLLocationCoordinate2D()
    var locValueFromPicture = CLLocationCoordinate2D()
    
    var imageURL = ""
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    let localNotification:UILocalNotification = UILocalNotification()
    
    var isFromGallery: Bool = false
    
    var rightBarButtonItem: UIBarButtonItem!
    
    @IBOutlet weak var whereItIsTextViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var obsProjectLabel: UILabel!
    @IBOutlet weak var obsDescTextView: UITextView!
    
    var kHieight: CGFloat = 0.0
    
    var activityID: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title="Observation"
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(NewObsViewController.dismissVC))
        navigationItem.leftBarButtonItem = barButtonItem
        
        //TODO should check that user is logged in when this button is pressed
        rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(NewObsViewController.postObservation))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        observationImageView.image = obsImage
        observationDetailsTableView.delegate = self
        observationDetailsTableView.dataSource = self
        observationDetailsTableView.separatorColor = UIColor.clearColor()
        observationDetailsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        observationDetailsTableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        self.view.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if(isFromGallery)
        {
            if(locValueFromPicture.latitude != 0 || locValueFromPicture.longitude != 0)
            {
                locValue = locValueFromPicture
                print(locValue)
            }
            else
            {
                getSiteLocationAndSetToLocValue()
                
                if CLLocationManager.locationServicesEnabled() {
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    locationManager.startUpdatingLocation()
                }
            }
        }
        else
        {
            getSiteLocationAndSetToLocValue()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
        
        if(userDefaults.objectForKey("ProjectKey") != nil)
        {
            userDefaults.setValue("", forKey:"ProjectKey")
            userDefaults.setValue("", forKey:"ProjectName")
            userDefaults.setValue("", forKey:"ActivityID")
        }
        
        obsDescTextView.delegate = self
        whereitisTextView.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewObsViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NewObsViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)

    }

    func textViewDidBeginEditing(textView: UITextView) {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            if(textView == self.whereitisTextView)
            {
                self.view.frame.origin.y -= (self.kHieight-self.whereitisTextView.frame.size.height)
            }
            else if(textView == self.obsDescTextView)
            {
                self.view.frame.origin.y -= self.kHieight/2
            }
        })
    }
    
    
    func textViewDidEndEditing(textView: UITextView) {
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            UIView.animateWithDuration(0.25, animations: { () -> Void in
            
                if(textView.returnKeyType == UIReturnKeyType.Done) {
                    
                    if(textView == self.whereitisTextView)
                    {
                        self.view.frame.origin.y += (self.kHieight-self.whereitisTextView.frame.size.height)
                    }
                    else if(textView == self.obsDescTextView)
                    {
                        self.view.frame.origin.y += self.kHieight/2
                    }
                }

                textView.resignFirstResponder()
            })
            
            return false
        }
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            kHieight = keyboardSize.size.height
            UIView.animateWithDuration(0.25, animations: { () -> Void in })
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        kHieight = 0.0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func getSiteLocationAndSetToLocValue()
    {
        //Getting lat and long from sites table
        let userDefaults = NSUserDefaults()
        print(userDefaults.objectForKey("userAffiliation"))
        if let userAffiliation = userDefaults.objectForKey("userAffiliation"){
            
            let myRootRef = FIRDatabase.database().referenceWithPath("sites/\(userAffiliation)")
            myRootRef.observeEventType(.Value, withBlock: { snapshot in
                print(snapshot.value!["l"])
                let siteLocationArray = snapshot.value!["l"] as! NSArray
                print(siteLocationArray[0])
                print(siteLocationArray[1])

                self.locValue.latitude = siteLocationArray[0] as! Double
                self.locValue.longitude = siteLocationArray[1] as! Double
            }, withCancelBlock: { error in
                print(error.description)
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            })
        }
    }
    
    func uploadImage() {
        var Cloudinary:CLCloudinary!
        imageForUpload = Utility.resizeImage(obsImage)
        let infoPath = NSBundle.mainBundle().pathForResource("Info.plist", ofType: nil)!
        let info = NSDictionary(contentsOfFile: infoPath)!
        Cloudinary = CLCloudinary(url: info.objectForKey("CloudinaryAccessUrl") as! String)
        let uploader = CLUploader(Cloudinary, delegate: self)
        localNotification.alertAction = "progress"
        localNotification.alertBody = "Observation Image Uploading in Progress"
        localNotification.fireDate = NSDate(timeIntervalSinceNow: 0)
        UIApplication.sharedApplication().scheduleLocalNotification(localNotification)
        uploader.upload(imageForUpload, options: nil, withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
    }
    
    func onCloudinaryCompletion(successResult:[NSObject : AnyObject]!, errorResult:String!, code:Int, idContext:AnyObject!) {
        if(errorResult == nil) {
            let publicId = successResult["public_id"] as! String
            let url = successResult["secure_url"] as? String
            print("now cloudinary uploaded, public id is: \(publicId) and \(url), ready for uploading media")

            if (url != "")
            {
                userDefaults.setValue(url, forKey: "observationImageUrl")
                imageURL = url!
                postToFirebase()
            }
        }
        else
        {
            print(errorResult.localizedLowercaseString)
            saveForLater(false)
            let message = "We'll try to upload this for automatically next time you have a connection."
            let alert = UIAlertController(title: "Image Upload Failed", message: message ,preferredStyle: UIAlertControllerStyle.Alert)
            let showMenuAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.dismissVC()
            }
            alert.addAction(showMenuAction)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:AnyObject!) {
        //do any progress update you may need
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) as Float
        UIApplication.sharedApplication().cancelLocalNotification(localNotification)
        
        print("uploading to cloudinary... wait! \(progress * 100)"+"%")
        
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    override func viewWillAppear(animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if let pName = userDefaults.objectForKey("ProjectName") as? String
        {
            if(pName != "")
            {
                obsProjectLabel.text = "    \(pName)"
            }
        }
        
    }
    
    func dismissVC(){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        
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

    func postObservation()
    {
        print("post")
        self.rightBarButtonItem.enabled = false
        spinner.startAnimating()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        descText = obsDescTextView.text

        if(userDefaults.objectForKey("userID") != nil)
        {
            userID = (userDefaults.objectForKey("userID") as? String)!
        }
        else
        {
            
        }
        
        if(userDefaults.objectForKey("ActivityID") != nil)
        {
            activityID = (userDefaults.objectForKey("ActivityID") as? String)!
            print(activityID)
        }

        print(descText)
        print(userID)
        var email = ""
        var password = ""
        
        if(userDefaults.objectForKey("email") as? String != nil || userDefaults.objectForKey("password") as? String != nil)
        {
            email = decodeString((userDefaults.objectForKey("email") as? String)!)
            password = decodeString((userDefaults.objectForKey("password") as? String)!)
        }
        
        if(userDefaults.objectForKey("observationImageUrl") as? String != nil)
        {
            imageURL = (userDefaults.objectForKey("observationImageUrl") as? String)!
        }
    
        let refUser = FIRAuth.auth()
        refUser!.signInWithEmail(email, password: password, completion: { authData, error in
            if (error != nil) {
                print("\(error)")
                var alert = UIAlertController()
                
                if (email == "" || error?.code == 17009 || error?.code == 17011)
                {
                    alert = UIAlertController(title: "Alert", message:"Please Sign In to continue" ,preferredStyle: UIAlertControllerStyle.Alert)

                    let showMenuAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { UIAlertAction in
                        let signInSignUpVC=SignInSignUpViewController()
                        let signInSignUpNavVC = UINavigationController()
                        signInSignUpVC.pageTitle="Sign In"
                        signInSignUpNavVC.viewControllers = [signInSignUpVC]
                        self.presentViewController(signInSignUpNavVC, animated: true, completion: nil)
                    }
                    
                    // Add the actions
                    alert.addAction(showMenuAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                }
                else
                {
                    var message = (error?.localizedDescription)!
                    message += "\n\nWe'll try to upload this for you automatically next time you have a connection."
                    self.imageForUpload = Utility.resizeImage(self.obsImage)
                    self.saveForLater(false)
                    
                    alert = UIAlertController(title: "Alert", message: message ,preferredStyle: UIAlertControllerStyle.Alert)
                    
                    let showMenuAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        self.dismissVC()
                    }

                    alert.addAction(showMenuAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                
                self.rightBarButtonItem.enabled = true
            }
            else
            {
                //this function will call the firebase post function when it is done
                self.uploadImage()
            }
        })
    }
    
    func postToFirebase() {
        let ref = FIRDatabase.database().referenceWithPath("observations")
        let currentTimestamp = FIRServerValue.timestamp()
        let autoID = ref.childByAutoId()
        
        print(userDefaults.objectForKey("progress"))

        if(self.activityID == "")
        {
            self.activityID = "-ACES_a38"
        }

        var userAffiliation = ""
        
        if(userDefaults.objectForKey("userAffiliation") as? String != nil)
        {
            userAffiliation = (userDefaults.objectForKey("userAffiliation") as? String)!
        }
        
        print(userAffiliation)
        print(self.activityID)
        print(self.locValue.latitude)
        print(self.locValue.longitude)
        let obsDetails = [
            "data": [
                "image": imageURL as AnyObject,
                "text" : self.descText as AnyObject
            ],
            "l":[
                "0": self.locValue.latitude as AnyObject,
                "1" : self.locValue.longitude as AnyObject
            ],
            "id": autoID.key,
            "where": whereitisTextView.text,
            "activity": self.activityID,
            "site": userAffiliation,
            "observer":self.userID,
            "source": "ios",
            "created_at": FIRServerValue.timestamp(),
            "updated_at": FIRServerValue.timestamp()
        ]
        autoID.setValue(obsDetails)
        
        print(autoID)
        
        
        let uRef = FIRDatabase.database().referenceWithPath("users/\(self.userID)")
        uRef.child("latest_contribution").setValue(currentTimestamp)
        
        let aRef = FIRDatabase.database().referenceWithPath("activities/\(activityID)")
        aRef.child("latest_contribution").setValue(currentTimestamp)
        
        let alert = UIAlertController(title: "Alert", message:"Observation Posted Successfully" ,preferredStyle: UIAlertControllerStyle.Alert)
        
        if(userDefaults.objectForKey("ObservationDescription") != nil)
        {
            userDefaults.setValue("", forKey:"ObservationDescription")
        }

        if(userDefaults.objectForKey("Project") != nil)
        {
            userDefaults.setValue("", forKey:"ProjectName")
            userDefaults.setValue("", forKey:"ActivityID")
        }
        
        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.dismissVC()
            
        }
        
        alert.addAction(dismissAction)
        self.presentViewController(alert, animated: true, completion: nil)
        
        self.rightBarButtonItem.enabled = true
        spinner.stopAnimating()
    }
    
    func saveForLater(imageWasUploaded:Bool) {
        
        var forLater : ObservationForLater
        
        var project = ""
        var projectId = ""

        if(userDefaults.objectForKey("ActivityID") != nil)
        {
            projectId = (userDefaults.objectForKey("ActivityID") as? String)!
        }

        if (projectId == "") {
            //Default Free Observation
            projectId = "-ACES_a38"
        }
        project = projectId
        
        let description = obsDescTextView.text
        let observerID = (userDefaults.objectForKey("userID") as? String)!
        let longitude = locValue.longitude
        let latitude = locValue.latitude
        
        var email = ""
        var password = ""
        
        if(userDefaults.objectForKey("email") as? String != nil || userDefaults.objectForKey("password") as? String != nil)
        {
            email = decodeString((userDefaults.objectForKey("email") as? String)!)
            password = decodeString((userDefaults.objectForKey("password") as? String)!)
        }
        
        var userAffiliation = ""
        
        if(userDefaults.objectForKey("userAffiliation") as? String != nil)
        {
            userAffiliation = (userDefaults.objectForKey("userAffiliation") as? String)!
        }
        
        if (imageWasUploaded)
        {
            forLater = ObservationForLater(whereitis:whereitisTextView.text , site:userAffiliation, projectID: projectId, projectKey: project, observationDescription: description, imageData: imageForUpload, imageURL: imageURL ,observerID: observerID, longitude: longitude, latitude: latitude, email: email, password: password, imageUploaded: imageWasUploaded)
        }
        else
        {
            forLater = ObservationForLater(whereitis:whereitisTextView.text, site:userAffiliation, projectID: projectId, projectKey: project, observationDescription: description, imageData: imageForUpload, observerID: observerID, longitude: longitude, latitude: latitude, email: email, password: password, imageUploaded: imageWasUploaded)
        }
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.laterArray.append(forLater)
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = self.items[indexPath.row]
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        cell.frame = CGRectMake(8,cell.frame.size.height+3,self.view.frame.size.width-16,cell.frame.size.height)
        
        let additionalSeparator = UIView()
        additionalSeparator.frame = CGRectMake(0,cell.frame.size.height-3,self.view.frame.size.width,3)
        additionalSeparator.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)

        cell.addSubview(additionalSeparator)

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        let projectVC = ProjectsViewController()
        let navVC = UINavigationController()

        if(indexPath.row == 0)
        {
            projectVC.isfromObservationVC = true
            navVC.viewControllers = [projectVC]
            self.presentViewController(navVC, animated: true, completion: nil)
        }
    }
}
