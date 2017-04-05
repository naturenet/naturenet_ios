//
//  NewDesignIdeasAndChallengesViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 4/19/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase

class NewDesignIdeasAndChallengesViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextViewDelegate{
    
    var picker:UIImagePickerController?=UIImagePickerController()
    var popover:UIPopoverController?=nil
    var design: String = ""
    
    var isDesignIdea: Bool = false
    @IBOutlet weak var activityIndicator_design: UIActivityIndicatorView!

    @IBOutlet weak var photoAndGalleryView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var ideaOrChallengeImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if(isDesignIdea == true)
        {
            self.navigationItem.title="Design Idea"
            design = "idea"
        }
        else
        {
            self.navigationItem.title="Design Challenge"
            design = "challenge"
        }
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(NewDesignIdeasAndChallengesViewController.dismissVC))
        navigationItem.leftBarButtonItem = barButtonItem
        
        let rightBarButtonItem = UIBarButtonItem(title: "Send", style: .Plain, target: self, action: #selector(NewDesignIdeasAndChallengesViewController.postDesign))
        rightBarButtonItem.tintColor = UIColor.whiteColor()
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        picker!.delegate=self
        textView.delegate = self
        
        textView.text = "Please Enter Description here"
        textView.textColor = UIColor.lightGrayColor()
        
        self.view.bringSubviewToFront(activityIndicator_design)
    }

    func textViewDidBeginEditing(textView: UITextView) {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = nil
            textView.textColor = UIColor.blackColor()
        }
    }

    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Description for Design Idea/Challenge"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n")
        {
            textView.resignFirstResponder()
            return false
        }

        return true
        
    }

    func dismissVC(){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        
    }
    
    override func viewWillAppear(animated: Bool) {
        textView.becomeFirstResponder()
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
    
    func postDesign()
    {
        if(textView.text != "")
        {
            activityIndicator_design.startAnimating()
            let userDefaults = NSUserDefaults.standardUserDefaults()
            var userID: String = ""

            if(userDefaults.objectForKey("userID") != nil)
            {
                userID = (userDefaults.objectForKey("userID") as? String)!
            }

            var email = ""
            var password = ""
            
            if(userDefaults.objectForKey("email") as? String != nil || userDefaults.objectForKey("password") as? String != nil)
            {
                email = decodeString((userDefaults.objectForKey("email") as? String)!)
                password = decodeString((userDefaults.objectForKey("password") as? String)!)
            }
            
            print(userID)
            let refUser = FIRAuth.auth()!
            refUser.signInWithEmail(email, password: password, completion: { authData, error in
                if (error != nil) {
                    
                    print("\(error)")
                    var alert = UIAlertController()
                    
                    if(email == "")
                    {
                        alert = UIAlertController(title: "Alert", message:"Please Login to continue" ,preferredStyle: UIAlertControllerStyle.Alert)
                    }
                    else
                    {
                        alert = UIAlertController(title: "Alert", message:error.debugDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                    }
                    
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
                    self.activityIndicator_design.stopAnimating()
                }
                else
                {
                    let ref = FIRDatabase.database().referenceWithPath("ideas")
                    let autoID = ref.childByAutoId()
                    print(autoID.key)
                    let designData = [
                        "id": autoID.key as AnyObject,
                        "content": self.textView.text as AnyObject,
                        "group": self.design as AnyObject,
                        "status": "Doing",
                        "submitter": userID as AnyObject,
                        "source": "ios",
                        "created_at": FIRServerValue.timestamp(),
                        "updated_at": FIRServerValue.timestamp()
                    ]
                    autoID.setValue(designData)
                    
                    let alert = UIAlertController(title: "Alert", message: "Design Idea Posted Successfully", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.activityIndicator_design.stopAnimating()
                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Text to continue", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func openCamera(sender: UIButton) {
        self.openCam()
    }

    @IBAction func openGallery(sender: UIButton) {
        self.openGlry()
    }
    
    func openCam()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera))
        {
            picker!.sourceType = UIImagePickerControllerSourceType.Camera
            self .presentViewController(picker!, animated: true, completion: nil)
        }
        else
        {
            openGlry()
        }
    }

    func openGlry()
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
        print("****##",info[UIImagePickerControllerOriginalImage])
        
        ideaOrChallengeImageView.image = (info[UIImagePickerControllerOriginalImage] as? UIImage)!
        
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController)
    {
        print("picker cancel.")
        picker .dismissViewControllerAnimated(true, completion: nil)
    }
}
