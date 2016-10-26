//
//  ProjectsViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/20/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase

class ProjectsViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    let newObsAndDIView_projects = NewObsAndDIViewController()
    let cgVC_projects = CameraAndGalleryViewController()
    let diAndCVC_projects = DesignIdeasAndChallengesViewController()
    var projectKeys: NSMutableArray = []
    var projectDescriptionKeys: NSMutableArray = []
    var projectStatusKeys: NSMutableArray = []
    var projectIconKeys: NSMutableArray = []
    var projectIds: NSMutableArray = []
    //var projectGeoIds: NSMutableArray = []
    var isfromObservationVC: Bool = false


    @IBOutlet weak var noProjectsIndicationLabel: UILabel!

    @IBOutlet weak var projectsTableView: UITableView!

    //var projItems: [String] = ["Red Mountain", "Native or Not?","How many Mallards?", "Heron Spotting","Who's Who?", "Tracks"]

    //var projIcons: [String] = ["RedMountain.png", "Native.png","Mallard.png", "Heron.png","Who.png", "Tracks.png"]


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = barButtonItem

        }

        self.navigationItem.title="Projects"

        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        if(isfromObservationVC == true)
        {
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(ProjectsViewController.dismissVC))
            navigationItem.leftBarButtonItem = barButtonItem
        }

        self.projectsTableView.delegate=self
        self.projectsTableView.dataSource=self

        //Registering custom cell
        //menuTableView.registerNib(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        self.projectsTableView.separatorColor = UIColor.grayColor()
        self.projectsTableView.tableFooterView = UIView(frame: CGRectZero)
        self.projectsTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")

        //self.view.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)

        //self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProjectsViewController.ViewTapped)))
        if(isfromObservationVC == false)
        {
            newObsAndDIView_projects.view.frame = CGRectMake(0 ,UIScreen.mainScreen().bounds.size.height-newObsAndDIView_projects.view.frame.size.height-8, UIScreen.mainScreen().bounds.size.width, newObsAndDIView_projects.view.frame.size.height)

            newObsAndDIView_projects.view.translatesAutoresizingMaskIntoConstraints = true
            newObsAndDIView_projects.view.center = CGPoint(x: view.bounds.midX, y: UIScreen.mainScreen().bounds.size.height - newObsAndDIView_projects.view.frame.size.height/2 - 8)
            newObsAndDIView_projects.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]

            self.view.addSubview(newObsAndDIView_projects.view)
            //self.view.bringSubviewToFront(newObsAndDIView.view)
            newObsAndDIView_projects.camButton.addTarget(self, action: #selector(ProjectsViewController.openNewObsView_projects), forControlEvents: .TouchUpInside)

            newObsAndDIView_projects.designIdeaButton.addTarget(self, action: #selector(ProjectsViewController.openNewDesignView_projects), forControlEvents: .TouchUpInside)
        }




//        let geoActivitiesRootRef = FIRDatabase.database().referenceWithPath("geo/activities/")
//        //Firebase(url:FIREBASE_URL + "geo/activities")
//        geoActivitiesRootRef.observeEventType(.Value, withBlock: { snapshot in
//
//            //print(geoActivitiesRootRef)
//            //print(snapshot.value!.count)
//
//
//            if !(snapshot.value is NSNull)
//            {
//                for i in 0 ..< snapshot.value!.count
//                {
//                    let geoActivities = snapshot.value!.allValues[i] as! NSDictionary
//                    print(geoActivities)
//                    //let geoActivity = geoActivities.objectForKey("activity") as! String
//                    let geoActivityId = geoActivities.objectForKey("id") as! String
//
//                    //print(geoActivity)
//                    if(geoActivityId != "")
//                    {
//                        self.projectGeoIds.addObject(geoActivityId)
//                    }
//                    else
//                    {
//                        self.projectGeoIds.addObject("")
//                    }
//
//
//                }
//            }
//
//
//
//            }, withCancelBlock: { error in
//                print(error.description)
//                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
//                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
//                alert.addAction(action)
//                self.presentViewController(alert, animated: true, completion: nil)
//
//        })


        
        getProjectsDetails()

//                    if(self.isfromObservationVC == true)
//                    {
//                        let activitiesRootRef = FIRDatabase.database().referenceWithPath("activities")
//                        //for user's site only: .queryOrderedByChild("sites/\(userAffiliation)").queryEqualToValue(true)
//
//                        activitiesRootRef.observeEventType(.Value, withBlock: { snapshot in
//
//                            //print(snapshot)
//                            //let acesBool = snapshot.childSnapshotForPath("sites/aces").value as! NSNumber
//                            //print(acesBool)
//
//                            print(activitiesRootRef)
//                            print(snapshot.value)
//
//                            if !(snapshot.value is NSNull)
//                            {
//                                for j in 0 ..< snapshot.value!.count
//                                {
//
//
//                                    let activity = snapshot.value!.allKeys[j] as! String
//                                    let activityDictionary = snapshot.value!.objectForKey(activity) as! NSDictionary
//                                    //print(activityDictionary.objectForKey("name"))
//                                    if(activityDictionary.objectForKey("name") != nil)
//                                    {
//                                        //print(geoActivity)
//                                        //print(activity)
//                                        //if(activity == geoActivity)
//                                        //{
//                                            self.projectKeys.addObject(activityDictionary.objectForKey("name")!)
//                                        //}
//                                    }
//                                    
//                                    if(activityDictionary.objectForKey("description") != nil )
//                                    {
//                                        //print(geoActivity)
//                                        //print(activity)
//                                        //if(activity == geoActivity)
//                                        //{
//                                            self.projectDescriptionKeys.addObject(activityDictionary.objectForKey("description")!)
//                                        //}
//                                    }
//                                    
//                                    if(activityDictionary.objectForKey("icon_url") != nil)
//                                    {
//                                        //print(geoActivity)
//                                        //print(activity)
//                                        //if(activity == geoActivity)
//                                        //{
//
//                                            let iconUrlString = activityDictionary.objectForKey("icon_url") as! String
//                                            let newiconUrlString = iconUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
//                                            self.projectIconKeys.addObject(newiconUrlString)
//                                        //}
//                                    }
//                                    if(activityDictionary.objectForKey("status") != nil)
//                                    {
//                                        //print(geoActivity)
//                                        //print(activity)
//                                        //if(activity == geoActivity)
//                                        //{
//                                    self.projectStatusKeys.addObject(activityDictionary.objectForKey("status")!)
//                                        //}
//                                    }
//                                    if(activityDictionary.objectForKey("id") != nil)
//                                    {
//                                        //print(geoActivity)
//                                        //print(activity)
//                                        //if(activity == geoActivity)
//                                        //{
//                                        self.projectIds.addObject(activityDictionary.objectForKey("id")!)
//                                        print(self.projectIds)
//                                        //}
//                                    }
//
//
//
//
//                                }
//                                print(self.projectKeys)
//
//
//
//                                self.projectsTableView.reloadData()
//
//
//                            }
//
//
//
//                            }, withCancelBlock: { error in
//                                print(error.description)
//                                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
//                                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
//                                alert.addAction(action)
//                                self.presentViewController(alert, animated: true, completion: nil)
//
//                        })
//
//                    }
//                    else
//                    {
//                        
//                    }

    }
    func getProjectsDetails()
    {
        //activitiesRootRef
        let activitiesRootRef = FIRDatabase.database().referenceWithPath("activities")
        
        activitiesRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            //print(snapshot)
            //let acesBool = snapshot.childSnapshotForPath("sites/aces").value as! NSNumber
            //print(acesBool)
            
            print(activitiesRootRef)
            print(snapshot.value)
            
            self.projectKeys.removeAllObjects()
            self.projectDescriptionKeys.removeAllObjects()
            self.projectIconKeys.removeAllObjects()
            self.projectStatusKeys.removeAllObjects()
            self.projectIds.removeAllObjects()
            
            if !(snapshot.value is NSNull)
            {
                for j in 0 ..< snapshot.value!.count
                {
                    
                    let valuesArray = snapshot.value!.allKeys as NSArray
                    var reversedValuesArray = valuesArray.reverse()
                    let activity = reversedValuesArray[j] as! String
                    let activityDictionary = snapshot.value!.objectForKey(activity) as! NSDictionary
                    //print(activityDictionary.objectForKey("name"))
                    if(activityDictionary.objectForKey("name") != nil)
                    {
                        //print(geoActivity)
                        //print(activity)
                        //if(activity == geoActivity)
                        //{
                        self.projectKeys.addObject(activityDictionary.objectForKey("name")!)
                        //}
                    }
                    else
                    {
                        self.projectKeys.addObject("")
                    }
                    if(activityDictionary.objectForKey("description") != nil)
                    {
                        //print(geoActivity)
                        //print(activity)
                        //if(activity == geoActivity)
                        //{
                        self.projectDescriptionKeys.addObject(activityDictionary.objectForKey("description")!)
                        //}
                    }
                    else
                    {
                        self.projectDescriptionKeys.addObject("")
                    }
                    if(activityDictionary.objectForKey("icon_url") != nil)
                    {
                        //print(geoActivity)
                        //print(activity)
                        //if(activity == geoActivity)
                        //{
                        
                        let iconUrlString = activityDictionary.objectForKey("icon_url") as! String
                        let newiconUrlString = iconUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        self.projectIconKeys.addObject(newiconUrlString)
                        //}
                    }
                    else
                    {
                        self.projectIconKeys.addObject("")
                    }
                    if(activityDictionary.objectForKey("status") != nil)
                    {
                        //print(geoActivity)
                        //print(activity)
                        //if(activity == geoActivity)
                        //{
                        self.projectStatusKeys.addObject(activityDictionary.objectForKey("status")!)
                        //}
                    }
                    else
                    {
                        self.projectStatusKeys.addObject("")
                    }
                    if(activityDictionary.objectForKey("id") != nil)
                    {
                        //print(geoActivity)
                        //print(activity)
                        //if(activity == geoActivity)
                        //{
                        self.projectIds.addObject(activityDictionary.objectForKey("id")!)
                        //}
                    }
                    else
                    {
                        self.projectIds.addObject("")
                    }
                    
                    
                    
                    
                }
                //print(self.projectKeys)
                
                self.projectsTableView.reloadData()
                
                
            }
            
            
            
            }, withCancelBlock: { error in
                print(error.description)
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                
        })

    }
    
    func dismissVC()
    {
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
    }

    func openNewObsView_projects()
    {
        //print("gverver")
        self.addChildViewController(cgVC_projects)
        cgVC_projects.view.frame = CGRectMake(0, self.view.frame.size.height - cgVC_projects.view.frame.size.height+68, cgVC_projects.view.frame.size.width, cgVC_projects.view.frame.size.height)

        cgVC_projects.closeButton.addTarget(self, action: #selector(ProjectsViewController.closeCamAndGalleryView), forControlEvents: .TouchUpInside)

        self.view.addSubview(cgVC_projects.view)
        UIView.animateWithDuration(0.3, animations: {

            self.cgVC_projects.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.cgVC_projects.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.cgVC_projects.view.frame.size.height)

            self.cgVC_projects.view.translatesAutoresizingMaskIntoConstraints = true
            self.cgVC_projects.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]

        }) { (isComplete) in

            self.cgVC_projects.didMoveToParentViewController(self)

        }
    }
    func openNewDesignView_projects()
    {
        //print("gverver")
        self.addChildViewController(diAndCVC_projects)
        diAndCVC_projects.view.frame = CGRectMake(0, self.view.frame.size.height - diAndCVC_projects.view.frame.size.height+68, diAndCVC_projects.view.frame.size.width, diAndCVC_projects.view.frame.size.height)

        diAndCVC_projects.closeButton.addTarget(self, action: #selector(ProjectsViewController.closeDiAndChallengesView), forControlEvents: .TouchUpInside)

        self.view.addSubview(diAndCVC_projects.view)
        UIView.animateWithDuration(0.3, animations: {

            self.diAndCVC_projects.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.diAndCVC_projects.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.diAndCVC_projects.view.frame.size.height)

            self.diAndCVC_projects.view.translatesAutoresizingMaskIntoConstraints = true
            self.diAndCVC_projects.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]

        }) { (isComplete) in

            self.diAndCVC_projects.didMoveToParentViewController(self)

        }
    }
    func closeCamAndGalleryView()
    {
        cgVC_projects.view.removeFromSuperview()
        cgVC_projects.removeFromParentViewController()
    }
    func closeDiAndChallengesView()
    {
        diAndCVC_projects.view.removeFromSuperview()
        diAndCVC_projects.removeFromParentViewController()
    }
//    func ViewTapped()
//    {
//
//    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projectKeys.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        cell.textLabel?.text = projectKeys[indexPath.row] as? String

        //cell.imageView?.frame = CGRectMake(10, 5, 10, 10)
        //cell.imageView?.bounds = CGRectMake(0,0,20,20)
        //cell.imageView?.frame = CGRectMake(0,0,20,20)
        //cell.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        let cellImageView = UIImageView()
        cellImageView.contentMode = UIViewContentMode.ScaleAspectFit
        cellImageView.frame = CGRectMake(10, 2, 40, 40)

        if let projectIconUrl  = NSURL(string: projectIconKeys[indexPath.row] as! String)
        {
            //cellImageView.kf_setImageWithURL(NSURL.fileURLWithPath(projectIconUrl, placeholderImage: UIImage(named: "user.png")))
            //cellImageView.kf_setImageWithURL(NSURL.fileURLWithPath(projectIconUrl, placeholderImage: UIImage(named: "user.png"))
            cellImageView.kf_setImageWithURL(projectIconUrl, placeholderImage: UIImage(named: "project.png"))
        }

        /*
        if let projectIconUrl  = NSURL(string: projectIconKeys[indexPath.row] as! String),
            projectIconData = NSData(contentsOfURL: projectIconUrl)
        {
            cellImageView.image = UIImage(data: projectIconData)
        }
        */

        cellImageView.clipsToBounds = true

        cell.contentView.addSubview(cellImageView)

        cell.textLabel?.textAlignment = NSTextAlignment.Center


        //cell.imageView!.image = UIImage(named: projIcons[indexPath.row])
        //cell.imageView!.image = imageWithImage(UIImage(named: projIcons[indexPath.row])!, scaledToSize: CGSize(width: 30, height: 30))

//        let additionalSeparator = UIView()
//        additionalSeparator.frame = CGRectMake(0,cell.frame.size.height,self.view.frame.size.width,3)
//        additionalSeparator.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
//        cell.addSubview(additionalSeparator)

        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        //print("project clicked")
        if(isfromObservationVC == false)
        {
            let projectDetailVC = ProjectDetailViewController()
            projectDetailVC.projectTitle = projectKeys[indexPath.row] as! String
            projectDetailVC.projectDescription = projectDescriptionKeys[indexPath.row] as! String
            projectDetailVC.projectStatus = projectStatusKeys[indexPath.row] as! String
            projectDetailVC.projectIcon = projectIconKeys[indexPath.row] as! String
            projectDetailVC.projectIdFromProjectVC = projectIds[indexPath.row] as! String
            self.navigationController?.pushViewController(projectDetailVC, animated: true)
        }
        else
        {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            //userDefaults.setValue(projectGeoIds[indexPath.row] as! String, forKey: "ProjectKey")
            userDefaults.setValue(projectKeys[indexPath.row] as! String, forKey: "ProjectName")
            userDefaults.setValue(projectIds[indexPath.row] as! String, forKey: "ActivityID")
            self.dismissVC()
        }


    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 50
    }
    func imageWithImage(image:UIImage,scaledToSize newSize:CGSize)->UIImage{

        UIGraphicsBeginImageContext( newSize )
        image.drawInRect(CGRect(x: 0,y: 0,width: newSize.width,height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage.imageWithRenderingMode(.AlwaysTemplate)
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
