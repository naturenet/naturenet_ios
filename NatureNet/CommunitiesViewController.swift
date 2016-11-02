//
//  CommunitiesViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/20/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

class CommunitiesViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var peopleCountLabel: UILabel!
    @IBOutlet weak var peopleTable: UITableView!
    
    var userDisplayNamesArray: NSMutableArray = []
    var userAffiliationsArray: NSMutableArray = []
    var userAffiliationKeysArray: NSMutableArray = []
    var userAvatarURLSArray: NSMutableArray = []
    var userAffiliationDictionary:NSMutableDictionary = [:]
    
    let newObsAndDIView_communities = NewObsAndDIViewController()
    let cgVC_communities = CameraAndGalleryViewController()
    let diAndCVC_communities = DesignIdeasAndChallengesViewController()
    
    var usersCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        self.navigationItem.title="Communities"
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        
        peopleTable.delegate = self
        peopleTable.dataSource = self
        peopleTable.separatorColor = UIColor.grayColor()
        self.peopleTable.tableFooterView = UIView(frame: CGRectZero)
        peopleTable.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        peopleTable.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0)
        
        peopleTable.registerNib(UINib(nibName: "CommunitiesTableViewCell", bundle: nil), forCellReuseIdentifier: "communityCell")
        
        
    
        let communitiesRootRef = FIRDatabase.database().referenceWithPath("users") //Firebase(url:FIREBASE_URL+"users")
        communitiesRootRef.observeEventType(.Value, withBlock: { snapshot in
            
            print(communitiesRootRef)
            //print(snapshot.value.count)
            
            if !(snapshot.value is NSNull)
            {
                let snap = snapshot.value!.allValues as NSArray
                print(snap)
                
                
                let sortedSnapshot = snap.sort({ $0.objectForKey("latest_contribution") as? Int ?? 0 > $1.objectForKey("latest_contribution") as? Int ?? 0})
                print(snap)
                
                for i in 0 ..< snap.count
                {
                    //print(json.allValues[i])
                    let userJsonData = sortedSnapshot[i] as! NSDictionary
                    print(userJsonData)
                    self.usersCount = snapshot.value!.count
                    self.peopleCountLabel.text = "People" + "(" + "\(self.usersCount)" + ")"
                    
                    if(userJsonData.objectForKey("display_name") != nil)
                    {
                        let dn = userJsonData.objectForKey("display_name") as? String
                        self.userDisplayNamesArray.addObject(dn!)
                    }
                    else
                    {
                        self.userDisplayNamesArray.addObject("NO Display Name")
                    }
                    if(userJsonData.objectForKey("affiliation") != nil)
                    {
                        
                        let aff = userJsonData.objectForKey("affiliation") as? String
                        self.userAffiliationKeysArray.addObject(aff!);
                        self.getActivityNames(aff!)
                        
                    }
                    else
                    {
                        self.userAffiliationKeysArray.addObject("NO Affiliation")
                    }
                    if(userJsonData.objectForKey("avatar") != nil)
                    {
                        //let avatarUrlString = userJsonData.objectForKey("avatar") as! String
                        //print(avatarUrlString)
                        //let newavatarUrlString = avatarUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        let av = userJsonData.objectForKey("avatar") as! String
                        self.userAvatarURLSArray.addObject(av)
                    }
                    else
                    {
                        self.userAvatarURLSArray.addObject(NSBundle.mainBundle().URLForResource("user", withExtension: "png")!.absoluteString)
                    }

                }
                self.peopleTable.reloadData()
            }
        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
        //        let usersUrl = NSURL(string: FIREBASE_URL+"users.json")
//        
//        
//        var userData:NSData? = nil
//        do {
//            userData = try NSData(contentsOfURL: usersUrl!, options: NSDataReadingOptions())
//            //print(userData)
//        }
//        catch {
//            print("Handle \(error) here")
//        }
//        
//        if let data = userData {
//            // Convert data to JSON here
//            do{
//                let json: NSDictionary = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
//                
//                print(json)
//                
//                for i in 0 ..< json.count
//                {
//             
//                    //print(json.allValues[i])
//                    let userJsonData = json.allValues[i] as! NSDictionary
//                    print(userJsonData)
//                    usersCount = json.count
//                    peopleCountLabel.text = "People" + "(" + "\(usersCount)" + ")"
//                    
//                    if(userJsonData.objectForKey("display_name") != nil)
//                    {
//                        let dn = userJsonData.objectForKey("display_name") as? String
//                        userDisplayNamesArray.addObject(dn!)
//                    }
//                    else
//                    {
//                        userDisplayNamesArray.addObject("NO Display Name")
//                    }
//                    if(userJsonData.objectForKey("affiliation") != nil)
//                    {
//                        let aff = userJsonData.objectForKey("affiliation") as? String
//                        userAffiliationsArray.addObject(aff!)
//                    }
//                    else
//                    {
//                        userAffiliationsArray.addObject("NO Affiliation")
//                    }
//                    if(userJsonData.objectForKey("avatar") != nil)
//                    {
//                        //let avatarUrlString = userJsonData.objectForKey("avatar") as! String
//                        //print(avatarUrlString)
//                        //let newavatarUrlString = avatarUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
//                        let av = userJsonData.objectForKey("avatar") as! String
//                        userAvatarURLSArray.addObject(av)
//                    }
//                    else
//                    {
//                        userAvatarURLSArray.addObject(NSBundle.mainBundle().URLForResource("user", withExtension: "png")!.absoluteString)
//                    }
//                }
//            }
//            
//            catch let error as NSError {
//                print("json error: \(error.localizedDescription)")
//                let alert = UIAlertController(title: "Alert", message:error.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
//                self.presentViewController(alert, animated: true, completion: nil)
//            }
//
//        }
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        
        if(screenHeight == 667)
        {
            
        }
        else if(screenHeight == 736)
        {
            
        }
        else
        {
            
        }
        //print(newObsAndDIView_communities.view.frame)
        //print(newObsAndDIView_communities.designIdeaButton.frame)
        
        newObsAndDIView_communities.view.frame = CGRectMake(0 ,UIScreen.mainScreen().bounds.size.height-newObsAndDIView_communities.view.frame.size.height-8, UIScreen.mainScreen().bounds.size.width, newObsAndDIView_communities.view.frame.size.height)
        newObsAndDIView_communities.view.translatesAutoresizingMaskIntoConstraints = true
        
        //newObsAndDIView_communities.designIdeaButton.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width-newObsAndDIView_communities.designIdeaButton.frame.size.width-8 ,newObsAndDIView_communities.designIdeaButton.frame.origin.y, newObsAndDIView_communities.designIdeaButton.frame.size.width, newObsAndDIView_communities.designIdeaButton.frame.size.height)
        //newObsAndDIView_communities.view.setNeedsUpdateConstraints()
        
        //print(newObsAndDIView_communities.view.frame)
        //print(newObsAndDIView_communities.designIdeaButton.frame)
        self.view.addSubview(newObsAndDIView_communities.view)
        
        newObsAndDIView_communities.view.center = CGPoint(x: view.bounds.midX, y: UIScreen.mainScreen().bounds.size.height - newObsAndDIView_communities.view.frame.size.height/2 - 8)
        newObsAndDIView_communities.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        
        //self.view.bringSubviewToFront(newObsAndDIView.view)
        newObsAndDIView_communities.camButton.addTarget(self, action: #selector(CommunitiesViewController.openNewObsView_communities), forControlEvents: .TouchUpInside)
        
        newObsAndDIView_communities.designIdeaButton.addTarget(self, action: #selector(CommunitiesViewController.openNewDesignView_communities), forControlEvents: .TouchUpInside)
        
    }
    func getActivityNames(userAffiliationKey: String)
    {
        
        let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/"+userAffiliationKey)
        //Firebase(url:FIREBASE_URL + "sites/"+aff!)
        sitesRootRef.observeEventType(.Value, withBlock: { snapshot in
            
            print(userAffiliationKey)
            print(sitesRootRef)
            print(snapshot.value)
            
            if !(snapshot.value is NSNull)
            {
                
                
                print(snapshot.value!.objectForKey("name"))
                if(snapshot.value!.objectForKey("name") != nil)
                {
                    //self.userAffiliationsArray.addObject(snapshot.value!.objectForKey("name")!)
                    let str = snapshot.value!.objectForKey("name") as! String
                    print(str)
                    self.userAffiliationDictionary.setValue(str, forKey: userAffiliationKey)
                    
                }
                
                
                
            }
            self.peopleTable.reloadData()
            }, withCancelBlock: { error in
                print(error.description)
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                
        })

    }
    func openNewObsView_communities()
    {
        //print("gverver")
        self.addChildViewController(cgVC_communities)
        cgVC_communities.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - cgVC_communities.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, cgVC_communities.view.frame.size.height)
        
        cgVC_communities.closeButton.addTarget(self, action: #selector(ProjectsViewController.closeCamAndGalleryView), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(cgVC_communities.view)
        UIView.animateWithDuration(0.3, animations: {
            
            self.cgVC_communities.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.cgVC_communities.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.cgVC_communities.view.frame.size.height)
            
            //self.cgVC_communities.view.center = CGPoint(x: self.view.bounds.midX, y: UIScreen.mainScreen().bounds.size.height - self.cgVC_communities.view.frame.size.height/2 - 8)
            self.cgVC_communities.view.translatesAutoresizingMaskIntoConstraints = true
            self.cgVC_communities.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
            
        }) { (isComplete) in
            
            self.cgVC_communities.didMoveToParentViewController(self)
            
        }
    }
    func openNewDesignView_communities()
    {
        //print("gverver")
        self.addChildViewController(diAndCVC_communities)
        diAndCVC_communities.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - diAndCVC_communities.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width,diAndCVC_communities.view.frame.size.height)
        
        diAndCVC_communities.closeButton.addTarget(self, action: #selector(ProjectsViewController.closeDiAndChallengesView), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(diAndCVC_communities.view)
        UIView.animateWithDuration(0.3, animations: {
            
            self.diAndCVC_communities.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.diAndCVC_communities.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.diAndCVC_communities.view.frame.size.height)
            
            self.diAndCVC_communities.view.translatesAutoresizingMaskIntoConstraints = true
            self.diAndCVC_communities.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
            
        }) { (isComplete) in
            
            self.diAndCVC_communities.didMoveToParentViewController(self)
            
        }
    }
    func closeCamAndGalleryView()
    {
        cgVC_communities.view.removeFromSuperview()
        cgVC_communities.removeFromParentViewController()
    }
    func closeDiAndChallengesView()
    {
        diAndCVC_communities.view.removeFromSuperview()
        diAndCVC_communities.removeFromParentViewController()
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userAffiliationKeysArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        
        //let cell = tableView.dequeueReusableCellWithIdentifier("communityCell")! as? CommunitiesTableViewCell
        let cell = tableView.dequeueReusableCellWithIdentifier("communityCell", forIndexPath: indexPath) as! CommunitiesTableViewCell
                
        //let cellImageView = UIImageView()
        //cellImageView.contentMode = UIViewContentMode.ScaleAspectFit
        //cellImageView.frame = CGRectMake(10, 2, 40, 40)
        
        //COMEBACK
        if let userIconUrl  = NSURL(string: userAvatarURLSArray[indexPath.row] as! String)
        {
            cell.communitiesPersonImageView?.kf_setImageWithURL(userIconUrl, placeholderImage: UIImage(named: "user.png"))
        } //bug with image aspect ratios, fix with constraints?
        
        /*
        if let userIconUrl  = NSURL(string: userAvatarURLSArray[indexPath.row] as! String),
            userIconData = NSData(contentsOfURL: userIconUrl)
        {
            if(UIApplication.sharedApplication().canOpenURL(userIconUrl) == true)
            {
                cell?.imageView!.image = UIImage(data: userIconData)
            }
            else
            {
                cell?.imageView!.image = UIImage(named: "user.png")
            }
            
        }
        */
        
        //cellImageView.clipsToBounds = true
        //cellImageView.layer.cornerRadius = 20.0
        
        //cell!.contentView.addSubview(cellImageView)
        
        cell.communitiesPersonImageView?.layer.cornerRadius = 20.0
        
        //cell.communitiesPersonNameLabel?.textAlignment = NSTextAlignment.Center
        //cell.communitiesPersonAffiliationLabel?.textAlignment = NSTextAlignment.Center
        
        cell.communitiesPersonNameLabel?.text = userDisplayNamesArray[indexPath.row] as? String
        cell.communitiesPersonAffiliationLabel?.text = userAffiliationDictionary.objectForKey(userAffiliationKeysArray[indexPath.row]) as? String ?? "No Affiliation"
        //cell.imageView!.image = UIImage(named: projIcons[indexPath.row])
        //cell.imageView!.image = imageWithImage(UIImage(named: projIcons[indexPath.row])!, scaledToSize: CGSize(width: 30, height: 30))
        
//        let additionalSeparator = UIView()
//        additionalSeparator.frame = CGRectMake(0,cell.frame.size.height,self.view.frame.size.width,3)
//        additionalSeparator.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
//        cell.addSubview(additionalSeparator)
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
                
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView()
        header.frame = CGRectMake(0, 0, 100, 50)
        header.backgroundColor = UIColor.whiteColor()
        
        let sectionImageView = UIImageView()
        sectionImageView.image = UIImage(named: "5-1 people.png")
        sectionImageView.frame = CGRectMake(4, 10 , 30, 30)
        //sectionImageView.backgroundColor = UIColor.redColor()
        header.addSubview(sectionImageView)
        
        let sectionTitleLabel = UILabel()
        sectionTitleLabel.font = UIFont(name: "Futura", size: 14)!
        sectionTitleLabel.textColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)

        sectionTitleLabel.text = "People" + "(" + "\(usersCount)" + ")"
        sectionTitleLabel.frame = CGRectMake(40, 10, 100, 30)
        
        header.addSubview(sectionTitleLabel)
        
        return header
    }
    
//    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
//    {
//        
//    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return nil
//    }
    
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
