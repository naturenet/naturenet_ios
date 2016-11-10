//
//  RearViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/17/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class RearViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var menuItems: [String] = ["Explore","Gallery", "Projects","Design Ideas","Communities"]
    var menuItemsImages: [String] = ["observations navy.png","gallery.png", "project.png","design ideas.png","community.png"]
    var logoutArray:[String] = []
    var logoutImagesArray: [String] = []
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileView: UIView!
    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet var profileDetailsView: UIView!
    
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profileAffliationLabel: UILabel!
    
    var allowOnce : Bool = true
    
    
    @IBOutlet weak var versionAndBuildLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        menuTableView.delegate=self
        menuTableView.dataSource=self
        
        //Registering custom cell
        menuTableView.registerNib(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        menuTableView.separatorColor = UIColor.clearColor()
        menuTableView.scrollEnabled = false
        
        profileView.backgroundColor=UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        //profileView.backgroundColor = UIColor.redColor()
        profileView.translatesAutoresizingMaskIntoConstraints = true
        profileView.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        self.navigationController?.navigationBarHidden=true
        
        profileImageView.layer.cornerRadius = 30.0
        profileImageView.clipsToBounds = true
        profileDetailsView.hidden = true
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject_version: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
        
        let nsObject_build: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"]
        
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject_version as! String
        let build = nsObject_build as! String
        
        print(version)
        print(build)
        
        versionAndBuildLabel.text = "NatureNet \(version).\(build)"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if(section == 0)
        {
            count = menuItems.count
        }
        else if(section == 1)
        {
            count = logoutArray.count
        }
        return count
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuTableViewCell
        if(indexPath.section==0)
        {
            cell.menuItemTitle.text = menuItems[indexPath.row]
            cell.menuItemIcon.image = UIImage(named: menuItemsImages[indexPath.row])
        }
        else if(indexPath.section == 1)
        {
            cell.menuItemTitle.text = logoutArray[indexPath.row]
            cell.menuItemIcon.image = UIImage(named: logoutImagesArray[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var newFrontViewController: UINavigationController?
        
        
        if ((indexPath.section == 0) && (indexPath.row == 0)) {
            
            let mapVC = MapViewController()
            newFrontViewController = UINavigationController(rootViewController: mapVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            
        }
        else if ((indexPath.section == 0) && (indexPath.row == 1)) {
            
            let eVC = ExploreViewController() //change this to your class name
            
            newFrontViewController = UINavigationController(rootViewController: eVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            
        }
        else if ((indexPath.section == 0) && (indexPath.row == 2)) {
            
            let pVC = ProjectsViewController()
            newFrontViewController = UINavigationController(rootViewController: pVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            
        }
        else if ((indexPath.section == 0) && (indexPath.row == 3)) {
            
            let diVC = DesignIdeasViewController()
            newFrontViewController = UINavigationController(rootViewController: diVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            
        }
        else if ((indexPath.section == 0) && (indexPath.row == 4)) {
            
            let cVC = CommunitiesViewController()
            newFrontViewController = UINavigationController(rootViewController: cVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            
        }
        else if ((indexPath.section == 1) && (indexPath.row == 0)) {
            
            //NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
            //[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
            
            let userDefaults = NSUserDefaults.standardUserDefaults()
            let laterUploads = userDefaults.objectForKey("observationsForLater")
            NSUserDefaults.standardUserDefaults().removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
            userDefaults.setObject(laterUploads, forKey: "observationsForLater")
            
            try! FIRAuth.auth()!.signOut()
            
            
            if(menuItems.count > 0)
            {
                logoutArray.removeAtIndex(0)
                logoutImagesArray.removeAtIndex(0)
                profileImageView.image = UIImage(named:"user.png")
            }
            menuTableView.reloadData()
            allowOnce = true
            
            let homeVC = HomeViewController()
            newFrontViewController = UINavigationController(rootViewController: homeVC)
            revealViewController().pushFrontViewController(newFrontViewController, animated: true)
            
        }
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var headerHeight = CGFloat()
        if(section == 0)
        {
            headerHeight = 0
        }
        else{
            headerHeight = 44
        }
        return headerHeight
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clearColor()
        return v
    }
    
    @IBAction func signInAction(sender: UIButton) {
        
        let signInSignUpVC=SignInSignUpViewController()
        let signInSignUpNavVC = UINavigationController()
        signInSignUpVC.pageTitle="Sign In"
        signInSignUpNavVC.viewControllers = [signInSignUpVC]
        self.presentViewController(signInSignUpNavVC, animated: true, completion: nil)
        
        
    }

    @IBAction func joinAction(sender: UIButton) {
        
        let signInSignUpVC=SignInSignUpViewController()
        let signInSignUpNavVC = UINavigationController()
        signInSignUpVC.pageTitle="Join NatureNet"
        signInSignUpNavVC.viewControllers = [signInSignUpVC]
        self.presentViewController(signInSignUpNavVC, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if((userDefaults.stringForKey("isSignedIn")) == "true")
        {
            //allowOnce = true
            profileDetailsView.hidden = false
            signInButton.hidden = true
            joinButton.hidden = true
            
            if(allowOnce == true)
            {
                allowOnce = false
                logoutArray.insert("Logout", atIndex: 0)
                logoutImagesArray.insert("shutdown.png", atIndex: 0)
                
                menuTableView.reloadData()
            }
            
            
            
            if let userAffiliation = userDefaults.stringForKey("userAffiliation"){
                
                //print(userAffiliation)
                //profileAffliationLabel.text = userAffiliation
                
                let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/" + userAffiliation) //.queryEqualToValue(userAffiliation)//(url:FIREBASE_URL + "sites/"+userAffiliation)
                sitesRootRef.observeEventType(.Value, withBlock: { snapshot in
                    
                    print(sitesRootRef)
                    print(snapshot.value)
                    
                    if !(snapshot.value is NSNull)
                    {
                        
                        
                        print(snapshot.value!.objectForKey("name"))
                        if(snapshot.value!.objectForKey("name") != nil)
                        {
                            self.profileAffliationLabel.text = snapshot.value!.objectForKey("name") as? String
                        }
                        
                    }
                    else
                    {
                        self.profileAffliationLabel.text = userAffiliation
                    }
                   
                    }, withCancelBlock: { error in
                        print(error.description)
                        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)

                })

                
                
            
            }
            if let userDisplayName = userDefaults.stringForKey("userDisplayName"){
                
                profileNameLabel.text = userDisplayName
                //print(userDisplayName)
                
            }
            if let usersAvatar = userDefaults.stringForKey("usersAvatar"){
                
                
                let usersAvatarUrl  = NSURL(string: usersAvatar )
                //if(UIApplication.sharedApplication().canOpenURL(usersAvatarUrl!) == true)
                //{
                    //let usersAvatarData = NSData(contentsOfURL: usersAvatarUrl!)
                    //profileImageView.image = UIImage(data: usersAvatarData!)
                    profileImageView.kf_setImageWithURL(usersAvatarUrl!, placeholderImage: UIImage(named: "user.png"))
//                }
//                else
//                {
//                    profileImageView.image = UIImage(named:"user.png")
//                }

                
            }
            
            
            
        }
        else
        {
            if(logoutArray.count > 0)
            {
                logoutArray.removeAtIndex(0)
                logoutImagesArray.removeAtIndex(0)
            }
            
            
            
            profileDetailsView.hidden = true
            signInButton.hidden = false
            joinButton.hidden = false
            
            
        }
    }
    
    @IBAction func infoButtonTouched(sender: AnyObject) {
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.Left
        
        var licenseString = "Various third party software was used in the creation of this app. They are as follow:"
        
        
        licenseString += "\n\nCloudinary\nhttps://github.com/cloudinary/cloudinary_ios"
        
        licenseString += "\n\nFirebase\nhttps://www.firebase.com"
        
        licenseString += "\n\nKingfisher\nhttps://github.com/onevcat/Kingfisher"
        
        let alertController = UIAlertController(title: "License Information", message: licenseString, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
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
