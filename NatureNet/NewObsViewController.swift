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

class NewObsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,CLLocationManagerDelegate{

    @IBOutlet weak var observationDetailsTableView: UITableView!
    @IBOutlet weak var observationImageView: UIImageView!
    var obsImage : UIImage = UIImage(named: "default-no-image.png")!
    
    var items: [String] = ["Select a Project"]
    
    var projectKey : String = ""
    var descText :String = ""
    var userID :String = ""
    
    let locationManager = CLLocationManager()
    var locValue = CLLocationCoordinate2D()
    
    
    @IBOutlet weak var obsProjectLabel: UILabel!
    @IBOutlet weak var obsDescTextView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title="Observation"
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(NewObsViewController.dismissVC))
        navigationItem.leftBarButtonItem = barButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(NewObsViewController.postObservation))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        observationImageView.image = obsImage
        
        //spinner.startAnimating()
        let upImage = UploadImageToCloudinary()
        upImage.uploadToCloudinary(obsImage)
        //spinner.startAnimating()
        
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
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if(userDefaults.objectForKey("ProjectKey") != nil)
        {
            //projectName = (userDefaults.objectForKey("Project") as? String)!
            userDefaults.setValue("", forKey:"ProjectKey")
            userDefaults.setValue("", forKey:"ProjectName")
        }
        
        obsDescTextView.delegate = self
        
        


    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
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
                //userDefaults.setValue("", forKey:"ProjectKey")
                //userDefaults.setValue("", forKey:"ProjectName")
            }
        }
        
    }
    
    func dismissVC(){
        
        //self.navigationController!.dismissViewControllerAnimated(true, completion: {})
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        //self.view.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        //print("abhi")
        
    }
    func postObservation()
    {
        print("post")
        
//        var observations = Firebase(url: "https://naturenet-staging.firebaseio.com/observations")
//        let obs = ["id": uid as! AnyObject,"display_name": self.joinName.text as! AnyObject, "affiliation": self.joinAffliation.text as! AnyObject]
//        observations.setValue(obs)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        descText = obsDescTextView.text
        
        if(userDefaults.objectForKey("ProjectKey") != nil)
        {
            projectKey = (userDefaults.objectForKey("ProjectKey") as? String)!
        }
        else
        {
            
        }
        if(userDefaults.objectForKey("userID") != nil)
        {
            userID = (userDefaults.objectForKey("userID") as? String)!
        }
        else
        {
            
        }
        var projectActivityId = ""
        if(userDefaults.objectForKey("ActivityID") != nil)
        {
            projectActivityId = (userDefaults.objectForKey("ActivityID") as? String)!
        }
        
        //let upImage = UploadImageToCloudinary()
        //upImage.uploadToCloudinary(obsImage)
        
        
        //print((userDefaults.objectForKey("ProjectName") as! String))
        print(projectKey)
        print(descText)
        print(userID)
        print(OBSERVATION_IMAGE_UPLOAD_URL)
        var email = ""
        var password = ""
        var obsImageUrl = ""
        
        if(userDefaults.objectForKey("email") as? String != nil || userDefaults.objectForKey("password") as? String != nil)
        {
            email = (userDefaults.objectForKey("email") as? String)!
            password = (userDefaults.objectForKey("password") as? String)!
        }
        
        
        if(userDefaults.objectForKey("observationImageUrl") as? String != nil)
        {
            obsImageUrl = (userDefaults.objectForKey("observationImageUrl") as? String)!
        }
        
        
        
        
        
        //print(email)
        //print(password)
    
        let refUser = FIRAuth.auth() //Firebase(url: FIREBASE_URL)
        refUser!.signInWithEmail(email, password: password,
                     completion: { authData, error in
                        if error != nil {
                            
                            print("\(error)")
                            var alert = UIAlertController()
                            if(email == "")
                            {
                                alert = UIAlertController(title: "Alert", message:"Please Sign In to continue" ,preferredStyle: UIAlertControllerStyle.Alert)
                            }
                            else
                            {
                                alert = UIAlertController(title: "Alert", message:error?.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                            }

                            //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                            let showMenuAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                                UIAlertAction in
                                //print("OK Pressed")
                                //self.dismissVC()
                                
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
                            let ref = FIRDatabase.database().referenceWithPath("observations")
                            //Firebase(url: POST_OBSERVATION_URL)
                            print(ref.childByAutoId())
                            let autoID = ref.childByAutoId()
                            
                            
                            
                            //let obsRef = ref.childByAutoId().childByAppendingPath(ref.AutoId())
                            //let obsData = autoID.childByAppendingPath("data")
//                            let obsDataDetails = obsData.childByAppendingPath("text")
//                            obsDataDetails.setValue(self.descText)
//                            let obsDataImageDetails = obsData.childByAppendingPath("image")
//                            obsDataImageDetails.setValue(obsImageUrl)
////                            let obsDataIgnoreDetails = obsData.childByAppendingPath("ignore")
////                            obsDataIgnoreDetails.setValue("true")
//                            let obsId = autoID.childByAppendingPath("id")
//                            obsId.setValue(autoID.key)
//                            let obsCreatedAt = autoID.childByAppendingPath("created_at")
//                            obsCreatedAt.setValue(FirebaseServerValue.timestamp())
//                            let obsUpdatedAt = autoID.childByAppendingPath("updated_at")
//                            obsUpdatedAt.setValue(FirebaseServerValue.timestamp())
//                            let obsActivityLocation = autoID.childByAppendingPath("activity_location")
//                            obsActivityLocation.setValue("test")
//
//        
//                            let obsIdKey = autoID.childByAppendingPath("observer")
//                            obsIdKey.setValue(self.userID)
                            
                            //let dataKeys = ["image": obsImageUrl as! AnyObject, "text" : self.descText as AnyObject]
                            //obsData.setValue(dataKeys)
                            //let userDefaults = NSUserDefaults.standardUserDefaults()
                            print(userDefaults.objectForKey("progress"))
                            
                            if(self.projectKey == ""){
                                
                                self.projectKey = "-ACES_g38"
                            }
                            
                            print(self.projectKey)
                            print(self.userID)
                            print(projectActivityId)
                            
                                if(userDefaults.objectForKey("progress") as? String == "100.0")
                                {
                                    let currentTimestamp = FIRServerValue.timestamp()
                                    
                                    let obsDetails = ["data":["image": obsImageUrl as AnyObject, "text" : self.descText as AnyObject],"l":["0": self.locValue.latitude as AnyObject, "1" : self.locValue.longitude as AnyObject],"id": autoID.key,"activity_location": self.projectKey,"observer":self.userID, "created_at": currentTimestamp,"updated_at": currentTimestamp]
                                    autoID.setValue(obsDetails)
                                    
                                    print(autoID)
                                    
                                    print("Timestamp: "+"\(FIRServerValue.timestamp())")
                                    
                                    
                                    let uRef = FIRDatabase.database().referenceWithPath("users/\(self.userID)")
                                    uRef.child("latest_contribution").setValue(currentTimestamp)
                                    
                                    let aRef = FIRDatabase.database().referenceWithPath("activities/\(projectActivityId)")
                                    aRef.child("latest_contribution").setValue(currentTimestamp)
                                    
                                    let alert = UIAlertController(title: "Alert", message:"Observation Posted Successfully" ,preferredStyle: UIAlertControllerStyle.Alert)
                                    //alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                    
                                    if(userDefaults.objectForKey("ObservationDescription") != nil)
                                    {
                                        userDefaults.setValue("", forKey:"ObservationDescription")
                                    }
                                    if(userDefaults.objectForKey("Project") != nil)
                                    {
                                        //projectName = (userDefaults.objectForKey("Project") as? String)!
                                        userDefaults.setValue("", forKey:"ProjectKey")
                                        userDefaults.setValue("", forKey:"ProjectName")
                                    }
                                    
                                    let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                                    {
                                        UIAlertAction in
                                        self.dismissVC()
                                        
                                    }
                                    alert.addAction(dismissAction)
                                    self.presentViewController(alert, animated: true, completion: nil)
                                    
                                    
                                    
                                }
                                else
                                {
                                    let alert = UIAlertController(title: "Alert", message:"Image uploading failed" ,preferredStyle: UIAlertControllerStyle.Alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                    self.presentViewController(alert, animated: true, completion: nil)
                                }
                            
        
                        }})

        //let usersPrivateReftoid = usersRef.childByAppendingPath("private")
        //let usersPrivate = ["email": self.joinEmail.text as! AnyObject]
        //usersRef.setValue(usersPub)
        //OBSERVATION_IMAGE_UPLOAD_URL = ""
        
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
        
        //let obsDetailsVC = NewObservationDetailsViewController()
        let projectVC = ProjectsViewController()
        let navVC = UINavigationController()
        if(indexPath.row == 0)
        {
            //obsDetailsVC.isDescription = false
            projectVC.isfromObservationVC = true
            navVC.viewControllers = [projectVC]
            self.presentViewController(navVC, animated: true, completion: nil)
        }
        
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
