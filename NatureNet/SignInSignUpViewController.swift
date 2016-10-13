//
//  SignInSignUpViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/23/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase
import Cloudinary
//import SWRevealViewController

class SignInSignUpViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CLUploaderDelegate{
    
    var pageTitle :String!

    @IBOutlet var signInView: UIView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet var joinView: UIView!
    @IBOutlet weak var profileIconImageView: UIImageView!
    @IBOutlet weak var joinUsername: UITextField!
    @IBOutlet weak var joinPassword: UITextField!
    @IBOutlet weak var joinName: UITextField!
    @IBOutlet weak var joinEmail: UITextField!
    @IBOutlet weak var joinAffliation: UILabel!
   
    @IBOutlet weak var affiliationPickerView: UIPickerView!
    
    @IBOutlet weak var viewForHidingPickerView: UIView!
    var sitesArray : NSMutableArray = []
    var sitesIdsArray : NSMutableArray = []
    var AffiliationId : String = ""
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    
   
    
    var tapGesture:UITapGestureRecognizer!
    
    var joinScrollView: UIScrollView!
    
    
    @IBOutlet var consentForm: UIView!
    var isFromHomeVC: Bool = false
   
    @IBOutlet weak var firstConsentButton: UIButton!
    @IBOutlet weak var secondConsentButton: UIButton!
    
    @IBOutlet weak var thirdConsentButton: UIButton!
    
    @IBOutlet weak var fourthConsentButton: UIButton!
    
    var isFirstConsentChecked: Bool = false
    var isSecondConsentChecked: Bool = false
    var isThirdConsentChecked: Bool = false
    var isFourthConsentChecked: Bool = false
    
    var isDefaultImage: Bool = false
    var imageForUpload = NSData()
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.view.backgroundColor = UIColor(white: 1, alpha: 0.5)
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(self.dismissVC))
        navigationItem.leftBarButtonItem = barButtonItem
        //}
        
        self.navigationItem.title=pageTitle
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //self.view.backgroundColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        //self.view.tintColor = UIColor.whiteColor()
        
        textFieldBorder(username)
        textFieldBorder(password)
        
        username.delegate = self
        password.delegate = self
                
        if(pageTitle == "Sign In")
        {
            signInView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            
            signInView.translatesAutoresizingMaskIntoConstraints = true
            signInView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
            self.view.addSubview(signInView)
        }
        else if(pageTitle == "Join NatureNet")
        {
            self.addJoinScrollView()
        }
        
        affiliationPickerView.hidden = true
        viewForHidingPickerView.hidden = true
        

    }
    
    
    
    
    func addJoinScrollView()
    {
        if(joinScrollView == nil)
        {
            joinScrollView = UIScrollView()
        }
        joinScrollView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
        joinScrollView.backgroundColor = UIColor.clearColor()
        joinScrollView.autoresizesSubviews = true
        joinScrollView.contentSize=CGSizeMake(UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height+80)
        
        joinScrollView.translatesAutoresizingMaskIntoConstraints = true
        joinScrollView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.view.addSubview(joinScrollView)
        
        joinView.frame = CGRectMake(joinScrollView.frame.origin.x, joinScrollView.frame.origin.y, joinScrollView.frame.size.width, self.view.frame.size.height)
        joinScrollView.addSubview(joinView)
        
        textFieldBorder(joinUsername)
        textFieldBorder(joinPassword)
        textFieldBorder(joinName)
        textFieldBorder(joinEmail)
        labelBorder(joinAffliation)
        
        joinUsername.delegate = self
        joinPassword.delegate = self
        joinName.delegate = self
        joinEmail.delegate = self
        //joinAffliation.delegate = self
        
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        joinScrollView.userInteractionEnabled = true
        
        let sitesRootRef = FIRDatabase.database().referenceWithPath("sites")//(url:FIREBASE_URL + "sites")
        sitesRootRef.observeEventType(.Value, withBlock: { snapshot in
            
            print(sitesRootRef)
            print(snapshot.value!.count)
            
            if !(snapshot.value is NSNull)
            {
                for i in 0 ..< snapshot.value!.count
                {
                    //print(i)
                    let sites = snapshot.value!.allValues[i] as! NSDictionary
                    print(sites.objectForKey("name"))
                    if(sites.objectForKey("name") != nil)
                    {
                        self.sitesArray.addObject(sites.objectForKey("name")!)
                    }
                    if(sites.objectForKey("id") != nil)
                    {
                        self.sitesIdsArray.addObject(sites.objectForKey("id")!)
                    }

                }
                self.affiliationPickerView.reloadAllComponents()
                
            }
            }, withCancelBlock: { error in
                print(error.description)
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)

        })
        
//        let sitesUrl = NSURL(string: FIREBASE_URL + "sites.json")
//        
//        var sitesData:NSData? = nil
//        do {
//            sitesData = try NSData(contentsOfURL: sitesUrl!, options: NSDataReadingOptions())
//            //print(userData)
//        }
//        catch {
//            print("Handle \(error) here")
//        }
//        
//        if let data = sitesData {
//            // Convert data to JSON here
//            do{
//                let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
//                
//                print(json)
//                
//                for i in 0 ..< json.count
//                {
//                    //print(i)
//                    let sites = json.allValues[i] as! NSDictionary
//                    print(sites.objectForKey("name"))
//                    if(sites.objectForKey("name") != nil)
//                    {
//                        sitesArray.addObject(sites.objectForKey("name")!)
//                    }
//                    if(sites.objectForKey("id") != nil)
//                    {
//                        sitesIdsArray.addObject(sites.objectForKey("id")!)
//                    }
//                    
//                }
//            }
//            catch let error as NSError {
//                print("json error: \(error.localizedDescription)")
//                let alert = UIAlertController(title: "Alert", message:error.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
//        }
        
        //self.view.addSubview(affiliationPickerView)
        
        affiliationPickerView.delegate = self
        affiliationPickerView.dataSource = self
        
        
        joinScrollView.addGestureRecognizer(tapGesture)
        joinAffliation.userInteractionEnabled = true
        
        let affiliationGesture = UITapGestureRecognizer(target: self, action: #selector(self.showPicker))
        joinAffliation.addGestureRecognizer(affiliationGesture)
        //affiliationPickerView.frame = CGRectMake(0, self.view.frame.origin.y - affiliationPickerView.frame.size.height, affiliationPickerView.frame.size.width, affiliationPickerView.frame.size.height)
        //joinAffliation.inputView = affiliationPickerView
        //affiliationPickerView.removeFromSuperview()
        //joinAffliation.becomeFirstResponder()
        
//        let iconGesture = UITapGestureRecognizer(target: self, action: #selector(self.showCamAndGalleryView))
//        profileIconImageView.addGestureRecognizer(iconGesture)
        
        
        
    }
    
    
    @IBAction func showCamAndGallery(sender: UIButton) {
        
        let alert:UIAlertController=UIAlertController(title: "Choose Image", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openCamera()
            
        }
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default)
        {
            UIAlertAction in
            self.openGallary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel)
        {
            UIAlertAction in
            
        }
        
        // Add the actions
        picker?.delegate = self
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        // Present the controller
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: alert)
            popover!.presentPopoverFromRect(self.view.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }

        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGallary()
        }
    }
    
    func openGallary()
    {
        picker!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone
        {
            self.presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            popover=UIPopoverController(contentViewController: picker!)
            popover!.presentPopoverFromRect(self.view.frame, inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
    }
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject])
    {
        picker .dismissViewControllerAnimated(true, completion: nil)
        print(info[UIImagePickerControllerOriginalImage])
        if(info[UIImagePickerControllerOriginalImage] != nil)
        {
            isDefaultImage = false
            profileIconImageView.image=info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        else
        {
            isDefaultImage = true
        }
        
        
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    @IBAction func hidePickerView(sender: UIButton) {
        
        if(viewForHidingPickerView.hidden == false)
        {
            viewForHidingPickerView.hidden = true
            affiliationPickerView.hidden = true
        }
        
    }
    
    //MARK: - Sites PickerView
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sitesArray.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sitesArray[row] as? String
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        joinAffliation.text = sitesArray[row] as? String
        AffiliationId = sitesIdsArray[row] as! String
        print(AffiliationId)
    }
    func showPicker()
    {
        affiliationPickerView.hidden = false
        viewForHidingPickerView.hidden = false
        self.view.bringSubviewToFront(affiliationPickerView)
        self.view.bringSubviewToFront(viewForHidingPickerView)
    }
    
    @IBAction func joinButtonClickedFronSignInView(sender: UIButton) {
    
        signInView.removeFromSuperview()
        addJoinScrollView()

        self.navigationItem.title="Join NatureNet"
    
    }
    func dismissKeyboard()
    {
        joinUsername.resignFirstResponder()
        joinPassword.resignFirstResponder()
        joinName.resignFirstResponder()
        joinEmail.resignFirstResponder()
        joinAffliation.resignFirstResponder()
        
        affiliationPickerView.hidden = true
        viewForHidingPickerView.hidden = true
        
        setViewToMoveUp(false,tempTF: nil)
    }
    func keyboardWillShow(notification: NSNotification) {
        if(joinScrollView != nil)
        {
            joinScrollView.addGestureRecognizer(tapGesture)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if(joinScrollView != nil)
        {
            joinScrollView.removeGestureRecognizer(tapGesture)
        }
    }
    func textFieldBorder(textField: UITextField!)
    {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0).CGColor

        border.frame = CGRect(x: 0, y: textField.frame.size.height - width, width:  textField.frame.size.width, height: textField.frame.size.height)
        
        border.borderWidth = width
        textField.layer.addSublayer(border)
        textField.layer.masksToBounds = true
    }
    func labelBorder(lbl: UILabel)
    {
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0).CGColor
        
        border.frame = CGRect(x: 0, y: lbl.frame.size.height - width, width:  lbl.frame.size.width, height: lbl.frame.size.height)
        
        border.borderWidth = width
        lbl.layer.addSublayer(border)
        lbl.layer.masksToBounds = true
    }
    func buttonBorder(btn: UIButton)
    {
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        if(joinScrollView != nil)
        {
            setViewToMoveUp(false,tempTF: textField)
        }
        return true;
    }
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool // return NO to disallow editing.
    {
        if(joinScrollView != nil)
        {
            if(textField == joinEmail || textField == joinName )
            {
                setViewToMoveUp(true,tempTF: textField)
            }
            
            
        }
        return true
    }
    func setViewToMoveUp(moveUp: Bool, tempTF: UITextField!)
    {
        
        if(joinScrollView != nil && tempTF != nil)
        {
            //UIView.beginAnimations(nil, context: nil)
            //UIView.setAnimationDuration(0.3)
            UIView.animateWithDuration(0.3, animations: {
                
                var tfRect: CGRect!
                tfRect=tempTF.frame
                
                if(moveUp)
                {
                    self.joinScrollView.setContentOffset(CGPointMake(0, tfRect.origin.y-tfRect.size.height*8), animated:true)
                }
                else
                {
                    self.joinScrollView.setContentOffset(CGPointMake(0, 0), animated:true)
                }

                
                }, completion: { finished in
                    
            })
            
        }
    }
    override func viewWillAppear(animated: Bool) {
        
        if(joinScrollView != nil)
        {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInSignUpViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SignInSignUpViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        }
        
        
    }
    override func viewWillDisappear(animated: Bool) {
        
        if(joinScrollView != nil)
        {
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        }
        
    }
    
    func dismissVC(){
        
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {
        
           
        
        })
    }

//    // placeholder position
//    func textRectForBounds(bounds: CGRect) -> CGRect
//    {
//        return CGRectInset(bounds, 12, 0)
//    }
//    
//    // text position
//    func editingRectForBounds(bounds: CGRect) -> CGRect
//    {
//        return CGRectInset(bounds, 12, 0)
//    }
//    func placeholderRectForBounds(bounds: CGRect) -> CGRect
//    {
//        return CGRectInset(bounds, 12, 0)
//    }
    func connectTOFirebase()
    {
        
    }
    
    @IBAction func signInButtonClicked(sender: UIButton) {
        
        signInButton.enabled = false
        
        if(username.text != "" || password.text != "")
        {
        
            let ref = FIRAuth.auth()
            
            ref!.signInWithEmail(username.text!, password: password.text!,
                         completion: { authData, error in
                            if error != nil {
                                // There was an error logging in to this account
                                print("\(error)")
                                let alert = UIAlertController(title: "Alert", message:error!.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                                self.signInButton.enabled = true
                                
                            } else {
                                // We are now logged in
                                print("We are now logged in")
                                //print(authData.providerData)
                                //print(authData.uid)
                                print(authData?.uid)
                                let userID = (authData?.uid)!
                               let userRef = FIRDatabase.database().referenceWithPath("users/\(userID)")
                                
                                userRef.observeEventType(.Value, withBlock: { snapshot in
                                    
                                    print(userRef)
                                    print(snapshot.value)
                                    
                                    if !(snapshot.value is NSNull)
                                    {
                                        
                                            //FireBase Analytics
                                            FIRAnalytics.logEventWithName(kFIREventSelectContent, parameters: [
                                                kFIREventLogin: "Logged In"
                                            ])
                                            
                                            let userAffiliation = snapshot.value!.objectForKey("affiliation")
                                            let userDisplayName = snapshot.value!.objectForKey("display_name")
                                            let usersAvatar = snapshot.value!.objectForKey("avatar")
                                            
                                            let userDefaults = NSUserDefaults.standardUserDefaults()
                                            userDefaults.setValue(userAffiliation, forKey: "userAffiliation")
                                            userDefaults.setValue(userDisplayName, forKey: "userDisplayName")
                                            userDefaults.setValue("true", forKey: "isSignedIn")
                                            userDefaults.setValue(authData?.uid, forKey: "userID")
                                            userDefaults.setValue(self.encodeString(self.username.text!), forKey: "email")
                                            userDefaults.setValue(self.encodeString(self.password.text!), forKey: "password")
                                            //self.encodeString(self.username.text!)
                                            //self.encodeString(self.password.text!)
                                            if(usersAvatar != nil)
                                            {
                                                userDefaults.setValue(usersAvatar, forKey: "usersAvatar")
                                            }
                                            
                                            self.dismissVC()
                                            
                                        

                                        
                                    }
                                    }, withCancelBlock: { error in
                                        print(error.description)
                                        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                                        alert.addAction(action)
                                        self.presentViewController(alert, animated: true, completion: nil)

                                })
                                
//                                let endpoint = NSURL(string: USERS_URL+"\(authData?.uid).json")
//                                
//                                //let endpoint = NSURL(string:"https://naturenet-testing.firebaseio.com/observations.json?orderBy='$key'&limitToFirst=4")
//                                //var data = NSData(contentsOfURL: endpoint!)
//                                print(endpoint)
//                                
//                                var userData:NSData? = nil
//                                do {
//                                    userData = try NSData(contentsOfURL: endpoint!, options: NSDataReadingOptions())
//                                    print(userData)
//                                }
//                                catch {
//                                    print("Handle \(error) here")
//                                }
//                                
//                                if let data = userData {
//                                    // Convert data to JSON here
//                                    do{
//                                        let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
//                                        print(json)
//                                    //let userPublicData = json.objectForKey("public")! as! nsar
//                                        //print(userPublicData)
////                                        for (key, value) in json {
////                                            print("\(key) -> \(value)")
////                                        }
//                                        //print(json["public"]!["affliation"])
//                                        
//                                        //let userPublicData = json["public"] as! NSArray
//                                        if(json != ""){
//                                            
//                                            let userAffiliation = json.objectForKey("affiliation")
//                                            let userDisplayName = json.objectForKey("display_name")
//                                            let usersAvatar = json.objectForKey("avatar")
//                                            
//                                            let userDefaults = NSUserDefaults.standardUserDefaults()
//                                            userDefaults.setValue(userAffiliation, forKey: "userAffiliation")
//                                            userDefaults.setValue(userDisplayName, forKey: "userDisplayName")
//                                            userDefaults.setValue("true", forKey: "isSignedIn")
//                                            userDefaults.setValue(authData?.uid, forKey: "userID")
//                                            userDefaults.setValue(self.username.text, forKey: "email")
//                                            userDefaults.setValue(self.password.text, forKey: "password")
//                                            
//                                            if(usersAvatar != nil)
//                                            {
//                                                userDefaults.setValue(usersAvatar, forKey: "usersAvatar")
//                                            }
//                                            
//                                            self.dismissVC()
//                                            
//                                        }
//                                        
//                                    
//                                        
//                                        
//                                    }catch let error as NSError {
//                                        print("json error: \(error.localizedDescription)")
//                                        let alert = UIAlertController(title: "Alert", message:error.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
//                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                                        self.presentViewController(alert, animated: true, completion: nil)
//                                    }
//
//                                }
                                
                                
//                                Alamofire.request(.GET, "https://naturenet-testing.firebaseio.com/users/\(authData.uid).json")
//                                    .responseJSON { response in
//                                        print(response.request)  // original URL request
//                                        print(response.response) // URL response
//                                        print(response.data)     // server data
//                                        print(response.result)   // result of response serialization
//                                        
//                                        if let JSON = response.result.value {
//                                            print("JSON: \(JSON)")
//                                        }
//                                }
                                self.signInButton.enabled = true
                                
                            }
            })
        }
        else
        {
            
            let alert = UIAlertController(title: "Alert", message: "Please Enter All the Details", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            signInButton.enabled = true
        }
        
    }
    
    func uploadImage() {
        
        var Cloudinary:CLCloudinary!
        
        imageForUpload = Utility.resizeImage(profileIconImageView.image!)
        
        let infoPath = NSBundle.mainBundle().pathForResource("Info.plist", ofType: nil)!
        let info = NSDictionary(contentsOfFile: infoPath)!
        //print(info.objectForKey("CloudinaryAccessUrl"))
        
        Cloudinary = CLCloudinary(url: info.objectForKey("CloudinaryAccessUrl") as! String)
        let uploader = CLUploader(Cloudinary, delegate:self)
        
        uploader.upload(imageForUpload, options: nil, withCompletion:onCloudinaryCompletion, andProgress:onCloudinaryProgress)
        
    }
    
    func onCloudinaryCompletion(successResult:[NSObject : AnyObject]!, errorResult:String!, code:Int, idContext:AnyObject!) {
        if(errorResult == nil) {
            let publicId = successResult["public_id"] as! String
            let url = successResult["secure_url"] as? String
            print("now cloudinary uploaded, public id is: \(publicId) and \(url), ready for uploading media")
            // push media after cloudinary is finished
            //let params = ["link": publicId] as Dictionary<String, Any>
            //self.doPushNew(self.apiService!, params: params)
            let userDefaults = NSUserDefaults.standardUserDefaults()
            if(url != "")
            {
                userDefaults.setValue(url, forKey: "observationImageUrl")
                
                submitUserData()
            }
            
        }
        else {
            let alert = UIAlertController(title: "Alert", message: errorResult.localizedLowercaseString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            joinButton.enabled = true
        }
        
        
    }
    
    
    
    func onCloudinaryProgress(bytesWritten:Int, totalBytesWritten:Int, totalBytesExpectedToWrite:Int, idContext:AnyObject!) {
        //do any progress update you may need
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite) as Float
        //self.updateProgressDelegate?.onUpdateProgress(progress)
        
        print("uploading to cloudinary... wait! \(progress * 100)"+"%")
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setValue("\(progress * 100)", forKey: "progress")
        
        if(progress==100)
        {
            
        }
                
    }
    func submitUserData()
    {
        let myRootRef = FIRAuth.auth()
        // Write data to Firebase
        
        
        myRootRef!.createUserWithEmail(joinEmail.text!, password: joinPassword.text!,
                                       completion: { result, error in
                                        if error != nil {
                                            // There was an error creating the account
                                            let alert = UIAlertController(title: "Alert", message:error!.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                            self.presentViewController(alert, animated: true, completion: nil)
                                            //print(error.description)
                                            self.joinButton.enabled = true
                                            
                                        } else {
                                            
                                            
                                            let uid = result!.uid
                                            print("Successfully created user account with uid: \(uid)")
                                            //                                        let alert = UIAlertController(title: "Alert", message:"Successfully created user account with uid: \(uid)" ,preferredStyle: UIAlertControllerStyle.Alert)
                                            //                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                                            //                                        self.presentViewController(alert, animated: true, completion: nil)
                                            let authref = FIRAuth.auth()//Firebase(url: FIREBASE_URL+"users/")
                                            authref!.signInWithEmail(self.joinEmail.text!, password: self.joinPassword.text!,
                                                completion: { authData, error in
                                                    if error != nil {
                                                        
                                                    }
                                                    else
                                                    {
                                                        print("Successfully logged in by user with uid: \(uid)")
                                                        
                                                        let userDefaults = NSUserDefaults.standardUserDefaults()
                                                        var usersAvatarUrl = userDefaults.objectForKey("observationImageUrl") as? String
                                                        
                                                        let ref = FIRDatabase.database().referenceWithPath("users/")
                                                        
                                                        let usersRef = ref.childByAppendingPath("\(uid)")
                                                        //let usersPubReftoid = usersRef.childByAppendingPath("public")
                                                        
                                                        print(uid)
                                                        print(usersRef)
                                                        print(self.joinUsername.text)
                                                        print(self.AffiliationId)
                                                        print(FIRServerValue.timestamp())
                                                        print(usersAvatarUrl)
                                                        //print(uid)
                                                        
                                                        if(usersAvatarUrl == nil || usersAvatarUrl == "")
                                                        {
                                                            usersAvatarUrl = "https://res.cloudinary.com/university-of-colorado/image/upload/v1470239519/static/default_avatar.png"
                                                        }
                                                        
                                                        let usersPub = ["id": uid as AnyObject,"display_name": self.joinUsername.text as! AnyObject,"affiliation": self.AffiliationId as AnyObject, "created_at": FIRServerValue.timestamp(),"updated_at": FIRServerValue.timestamp(),"avatar":usersAvatarUrl as! AnyObject]
                                                        
                                                        
                                                        usersRef.setValue(usersPub)
                                                        
                                                        //let usersPrivateReftoid = usersRef.childByAppendingPath("private")
                                                        //let usersPrivate = ["email": self.joinEmail.text as! AnyObject]
                                                        //usersRef.setValue(usersPub)
                                                        
                                                        let refPrivate = FIRDatabase.database().referenceWithPath("users-private/")//Firebase(url: FIREBASE_URL+"users-private/")
                                                        
                                                        
                                                        let usersPrivateRef = refPrivate.childByAppendingPath("\(uid)")
                                                        
                                                        //let usersConsentPrivate = ["upload": self.isFirstConsentChecked as AnyObject,"share": self.isSecondConsentChecked as AnyObject,"recording": self.isThirdConsentChecked as AnyObject,"survey": self.isFourthConsentChecked as AnyObject]
                                                        //let usersPubReftoid = usersRef.childByAppendingPath("public")
                                                        //let usersPrivate = ["id": uid as! AnyObject,"name": self.joinName.text as! AnyObject,"consent": usersConsentPrivate as AnyObject, "created_at": FirebaseServerValue.timestamp(),"updated_at": FirebaseServerValue.timestamp()]
                                                        let usersPrivate = ["id": uid as! AnyObject,"name": self.joinName.text as! AnyObject,"created_at": FIRServerValue.timestamp(),"updated_at": FIRServerValue.timestamp()]
                                                        usersPrivateRef.setValue(usersPrivate)
                                                        
                                                        //let userConsent = usersPrivateRef.childByAppendingPath("consent")
                                                        //let usersConsentPrivate = ["required": true as AnyObject]
                                                        //userConsent.setValue(usersConsentPrivate)
                                                        
                                                        //let usersPrivateReftoid = usersRef.childByAppendingPath("private")
                                                        //let usersPrivate = ["email": self.joinEmail.text as! AnyObject]
                                                        //usersRef.setValue(usersPub)
                                                        
                                                        
                                                        //self.dismissVC()
                                                        
                                                        
                                                        
                                                        
                                                        
                                                        //let userDefaults = NSUserDefaults.standardUserDefaults()
                                                        userDefaults.setValue(self.AffiliationId, forKey: "userAffiliation")
                                                        userDefaults.setValue(self.joinUsername.text, forKey: "userDisplayName")
                                                        userDefaults.setValue("true", forKey: "isSignedIn")
                                                        userDefaults.setValue(uid, forKey: "userID")
                                                        userDefaults.setValue(self.encodeString(self.joinEmail.text!), forKey: "email")
                                                        userDefaults.setValue(self.encodeString(self.joinPassword.text!), forKey: "password")
                                                        
                                                        userDefaults.setValue(usersAvatarUrl, forKey: "usersAvatar")
                                                        
                                                        self.dismissVC()
                                                        self.joinButton.enabled = true
                                                        
                                                    }
                                                    
                                            })
                                        }
        })
    }

    
    @IBAction func joinButtonClicked(sender: UIButton) {
        
        joinButton.enabled = false
        
        if(joinUsername.text != "" || joinPassword.text != "" || joinName.text != "" || joinEmail.text != "" || joinAffliation.text != "" )
        {
            
            if(isDefaultImage == false)
            {
                //let upImage = UploadImageToCloudinary()
                //upImage.uploadToCloudinary(Utility.resizeImage(profileIconImageView.image!))
                
                uploadImage()
            }
            else
            {
                submitUserData()
            }
            
        }
        
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Enter All the Details", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("Please Enter All the Details")
            joinButton.enabled = true

        }
        
    }
    
    func encodeString(stringToBeEncoded: String) -> String
    {
        //Encoding and Decoding String
        
        let utf8str = stringToBeEncoded.dataUsingEncoding(NSUTF8StringEncoding)
        let base64Encoded = utf8str?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
       
            
        print("Encoded:  \(base64Encoded)")
           
            
            
            
//            if let base64Decoded = NSData(base64EncodedString: base64Encoded, options:   NSDataBase64DecodingOptions(rawValue: 0))
//                .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })
//            {
//                // Convert back to a string
//                print("Decoded:  \(base64Decoded!)")
//            }
            
        return base64Encoded!
        //}
        
        //return stringToBeEncoded
        
    }
    
    @IBAction func forgotPasswordButtonClicked(sender: UIButton) {
        
        
        let auth = FIRAuth.auth()
        let emailAddress = username.text
        let pwd = password.text
        
        print(pwd)
        
        if(emailAddress != "")
        {
            auth?.sendPasswordResetWithEmail(emailAddress!, completion: { error in
                
                if(error == nil)
                {
                    let alert = UIAlertController(title: "Alert", message: "Password reset email sent successfully!", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
                else
                {
                    let alert = UIAlertController(title: "Alert", message: error?.description, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Enter your Email Address", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

//    alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { action in
//    switch action.style{
//    case .Default:
//    print("default")
//    
//    case .Cancel:
//    print("cancel")
//    
//    case .Destructive:
//    print("destructive")
//    }
//    }))
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
