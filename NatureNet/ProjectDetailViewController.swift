//
//  ProjectDetailViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 4/22/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ProjectDetailViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    let newObsAndDIView_projectDetails = NewObsAndDIViewController()
    let cgVC_projectDetails = CameraAndGalleryViewController()
    let diAndCVC_projectDetails = DesignIdeasAndChallengesViewController()
    
    var projectTitle : String = ""
    var projectIcon : String = ""
    var projectStatus : String = ""
    var projectDescription : String = ""
    var projectIdFromProjectVC: String = ""
    
    @IBOutlet weak var recentContributionLabel: UILabel!
    var observationsImagesArray: NSMutableArray = []
    var observationsTextArray: NSMutableArray = []

    @IBOutlet weak var projectStatusImageView: UIImageView!
    @IBOutlet weak var projectDescriptionTextView: UITextView!
    @IBOutlet weak var projectStatusLabel: UILabel!
    @IBOutlet weak var projectTitleLabel: UILabel!
    @IBOutlet weak var projectIconImageView: UIImageView!
    @IBOutlet weak var projectsCollectionView: UICollectionView!
    
    var observersAvatarArray_proj: NSMutableArray = []
    var observersNamesArray_proj: NSMutableArray = []
    var observersAffiliationsArray_proj: NSMutableArray = []
    
    var observersAvatarUrls_proj: NSMutableArray = []
    
    var likesCount_projects: Int = 0
    var likesCountArray_projects: NSMutableArray = []
    var commentsCountArray_projects: NSMutableArray = []
    var commentsKeysArray_projects: NSArray = []
    
    var observationUpdatedTimestampsArray_proj : NSMutableArray = []
    var observationUpdatedTimestamp_proj: NSNumber = 0
    
    
    var commentsDictArray : NSMutableArray = []
    
    var obsIdsArray : NSMutableArray = []
    
    var projectObservationsNumber : Int = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title=projectTitle
        
        print(projectIcon)
        
        if let projectIconUrl  = NSURL(string: projectIcon)
        {
            projectIconImageView?.kf_setImageWithURL(projectIconUrl, placeholderImage: UIImage(named: "project.png"))
        }
        
        projectTitleLabel.text = projectTitle
        projectStatusLabel.text = projectStatus
        projectDescriptionTextView.text = projectDescription
        
        //Setting up collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 172, height: 172)
        
        projectsCollectionView.collectionViewLayout = layout
        projectsCollectionView.frame = UIScreen.mainScreen().bounds
        projectsCollectionView.dataSource = self
        projectsCollectionView.delegate = self
        projectsCollectionView!.backgroundColor = UIColor.whiteColor()
        projectsCollectionView.alwaysBounceVertical=true
        
        //Registering custom Cell
        self.projectsCollectionView.registerNib(UINib(nibName: "ProjectDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ProjectDetailCell")
        projectsCollectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        let geoObservationsRootRef = FIRDatabase.database().referenceWithPath("observations")
        
        geoObservationsRootRef.queryLimitedToLast(UInt(projectObservationsNumber)).queryOrderedByChild("activity").queryEqualToValue(projectIdFromProjectVC).observeEventType(.Value, withBlock: { snapshot in
            self.commentsDictArray.removeAllObjects()
            self.commentsCountArray_projects.removeAllObjects()
            self.likesCountArray_projects.removeAllObjects()
            self.observationUpdatedTimestampsArray_proj.removeAllObjects()
            self.obsIdsArray.removeAllObjects()
            self.observationsImagesArray.removeAllObjects()
            self.observationsTextArray.removeAllObjects()
            self.observersAffiliationsArray_proj.removeAllObjects()
            self.observersNamesArray_proj.removeAllObjects()
            self.observersAvatarUrls_proj.removeAllObjects()
            
            print(geoObservationsRootRef)
            print(snapshot.value!)
            
            if !(snapshot.value is NSNull)
            {
                
                let tempSnap = snapshot.value!.allValues as NSArray
                print(tempSnap)
                let sort = tempSnap.sort({ $0.objectForKey("updated_at") as! Int > $1.objectForKey("updated_at") as! Int})
                print(sort)
                
                for i in 0 ..< snapshot.value!.count
                {
                    let obsDictionary = sort[i] as! NSDictionary
                    print(obsDictionary)
                    let activity = obsDictionary.objectForKey("activity") as! String
                    print(activity)
                    print(self.projectIdFromProjectVC)
                    
                    if (activity != "")
                    {
                        if (activity == self.projectIdFromProjectVC)
                        {
                            print(obsDictionary)
                            print(obsDictionary.objectForKey("id"))
                            print(obsDictionary.objectForKey("activity"))
                            print(obsDictionary.objectForKey("created_at"))
                            print(obsDictionary.objectForKey("observer"))
                            let observationData = obsDictionary.objectForKey("data") as! NSDictionary
                            
                            print(observationData.objectForKey("image"))
                            
                            if(obsDictionary.objectForKey("comments") != nil)
                            {
                                let commentsDictionary = obsDictionary.objectForKey("comments") as! NSDictionary
                                print(commentsDictionary.allKeys)
                                
                                self.commentsKeysArray_projects = commentsDictionary.allKeys as NSArray
                                print(self.commentsKeysArray_projects)
                                
                                self.commentsDictArray.addObject(self.commentsKeysArray_projects)
                                
                                print(self.commentsDictArray)
                                
                                
                                self.commentsKeysArray_projects = commentsDictionary.allKeys as NSArray
                                print(self.commentsKeysArray_projects)
                                
                                self.commentsCountArray_projects.addObject("\(self.commentsKeysArray_projects.count)")
                            }
                            else
                            {
                                self.commentsCountArray_projects.addObject("0")
                                
                                let tempcomments = NSArray()
                                self.commentsDictArray.addObject(tempcomments)
                            }
                            
                            if (obsDictionary.objectForKey("likes") != nil)
                            {
                                let likesDictionary = obsDictionary.objectForKey("likes") as! NSDictionary
                                print(likesDictionary.allValues)
                                
                                let likesArray = likesDictionary.allValues as NSArray
                                print(likesArray)
                                
                                for l in 0 ..< likesArray.count
                                {
                                    if(likesArray[l] as! NSObject == 1)
                                    {
                                        self.likesCount_projects += 1
                                    }
                                }
                                
                                print(self.likesCount_projects)
                                self.likesCountArray_projects.addObject("\(self.likesCount_projects)")
                            }
                            else
                            {
                                self.likesCountArray_projects.addObject("0")
                            }
                            
                            if (obsDictionary.objectForKey("updated_at") != nil)
                            {
                                print(obsDictionary.objectForKey("updated_at"))
                                let obsUpdatedAt = obsDictionary.objectForKey("updated_at") as! NSNumber
                                self.observationUpdatedTimestampsArray_proj.addObject(obsUpdatedAt)
                                
                            }
                            else
                            {
                                self.observationUpdatedTimestampsArray_proj.addObject(0)
                            }
                            
                            if (obsDictionary.objectForKey("id") != nil)
                            {
                                let obsId = obsDictionary.objectForKey("id") as! String
                                self.obsIdsArray.addObject(obsId)
                            }
                            
                            if (observationData.objectForKey("image") != nil)
                            {
                                let observationUrlString = observationData.objectForKey("image") as! String
                                let newobservationUrlString = observationUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                let observationAvatarUrl  = NSURL(string: newobservationUrlString )
                                
                                if(UIApplication.sharedApplication().canOpenURL(observationAvatarUrl!) == true)
                                {
                                    self.observationsImagesArray.addObject(newobservationUrlString)
                                }
                                else
                                {
                                    let tempImageUrl = NSBundle.mainBundle().URLForResource("default-no-image", withExtension: "png")
                                    self.observationsImagesArray.addObject((tempImageUrl?.absoluteString)!)
                                }
                            }
                            else
                            {
                                let tempImageUrl = NSBundle.mainBundle().URLForResource("default-no-image", withExtension: "png")
                                self.observationsImagesArray.addObject((tempImageUrl?.absoluteString)!)
                            }

                            if (observationData.objectForKey("text") != nil)
                            {
                                self.observationsTextArray.addObject(observationData.objectForKey("text")!)
                            }
                            else
                            {
                                self.observationsTextArray.addObject("")
                            }

                            print(observationData.objectForKey("text"))
                            let obdId = obsDictionary.objectForKey("observer") as! String
                            let usersRootRef = FIRDatabase.database().referenceWithPath("users/\(obdId)")

                            usersRootRef.observeEventType(.Value, withBlock: { snapshot in
                                print(usersRootRef)
                                print(snapshot.value)
                                
                                if !(snapshot.value is NSNull)
                                {
                                    if((snapshot.value!.objectForKey("affiliation")) != nil)
                                    {
                                        let observerAffiliationString = snapshot.value!.objectForKey("affiliation") as! String
                                        let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/"+observerAffiliationString)
                                        
                                        sitesRootRef.observeEventType(.Value, withBlock: { snapshot in
                                            print(sitesRootRef)
                                            print(snapshot.value)
                                            
                                            if !(snapshot.value is NSNull)
                                            {
                                                print(snapshot.value!.objectForKey("name"))
                                                if(snapshot.value!.objectForKey("name") != nil)
                                                {
                                                    self.observersAffiliationsArray_proj.addObject((snapshot.value!.objectForKey("name") as? String)!)
                                                    self.showHideRecentContributionsLabel()
                                                }
                                            }
                                            
                                            self.projectsCollectionView.reloadData()
                                        }, withCancelBlock: { error in
                                            print(error.description)
                                            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                                            alert.addAction(action)
                                            self.presentViewController(alert, animated: true, completion: nil)
                                        })

                                        print(observerAffiliationString)
                                    }
                                    else
                                    {
                                        self.observersAffiliationsArray_proj.addObject("No Affiliation")
                                    }
                                    
                                    if((snapshot.value!.objectForKey("display_name")) != nil)
                                    {
                                        let observerDisplayNameString = snapshot.value!.objectForKey("display_name") as! String
                                        self.observersNamesArray_proj.addObject(observerDisplayNameString)
                                    }
                                    else
                                    {
                                        self.observersNamesArray_proj.addObject("")
                                    }
                                    
                                    if((snapshot.value!.objectForKey("avatar")) != nil)
                                    {
                                        let avatarUrlString = snapshot.value!.objectForKey("avatar") as! String
                                        let newavatarUrlString = avatarUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                                        
                                        let observerAvatar = newavatarUrlString
                                        let observerAvatarUrl  = NSURL(string: observerAvatar )
                                        
                                        if(UIApplication.sharedApplication().canOpenURL(observerAvatarUrl!) == true)
                                        {
                                            self.observersAvatarUrls_proj.addObject(observerAvatar)
                                        }
                                        else
                                        {
                                            let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                                            self.observersAvatarUrls_proj.addObject((tempImageUrl?.absoluteString)!)
                                        }
                                        
                                    }
                                    else
                                    {
                                        let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                                        self.observersAvatarUrls_proj.addObject((tempImageUrl?.absoluteString)!)
                                    }
                                }
                                
                                print(self.observationsImagesArray.count)
                                print(self.observersNamesArray_proj.count)
                                self.showHideRecentContributionsLabel()
                                
                            }, withCancelBlock: { error in
                                print(error.description)
                                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                                alert.addAction(action)
                                self.presentViewController(alert, animated: true, completion: nil)
                            })
                        }

                        self.showHideRecentContributionsLabel()
                    }
                }
            }
            else
            {
                self.showHideRecentContributionsLabel()
            }
        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })
        

        newObsAndDIView_projectDetails.view.frame = CGRectMake(0 ,UIScreen.mainScreen().bounds.size.height-newObsAndDIView_projectDetails.view.frame.size.height-8, UIScreen.mainScreen().bounds.size.width, newObsAndDIView_projectDetails.view.frame.size.height)
        newObsAndDIView_projectDetails.view.translatesAutoresizingMaskIntoConstraints = true
        newObsAndDIView_projectDetails.view.center = CGPoint(x: view.bounds.midX, y: UIScreen.mainScreen().bounds.size.height - newObsAndDIView_projectDetails.view.frame.size.height/2 - 8)
        newObsAndDIView_projectDetails.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        
        self.view.addSubview(newObsAndDIView_projectDetails.view)
        newObsAndDIView_projectDetails.camButton.addTarget(self, action: #selector(ProjectsViewController.openNewObsView_projects), forControlEvents: .TouchUpInside)
        newObsAndDIView_projectDetails.designIdeaButton.addTarget(self, action: #selector(ProjectsViewController.openNewDesignView_projects), forControlEvents: .TouchUpInside)
    }
    
    func openNewObsView_projects()
    {
        self.addChildViewController(cgVC_projectDetails)
        cgVC_projectDetails.view.frame = CGRectMake(0, self.view.frame.size.height - cgVC_projectDetails.view.frame.size.height+68, cgVC_projectDetails.view.frame.size.width, cgVC_projectDetails.view.frame.size.height)
        cgVC_projectDetails.closeButton.addTarget(self, action: #selector(ProjectDetailViewController.closeCamAndGalleryView), forControlEvents: .TouchUpInside)
        self.view.addSubview(cgVC_projectDetails.view)
        
        UIView.animateWithDuration(0.3, animations: {
            self.cgVC_projectDetails.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.cgVC_projectDetails.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.cgVC_projectDetails.view.frame.size.height)
            self.cgVC_projectDetails.view.translatesAutoresizingMaskIntoConstraints = true
            self.cgVC_projectDetails.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        }) { (isComplete) in
            self.cgVC_projectDetails.didMoveToParentViewController(self)
        }
    }

    func openNewDesignView_projects()
    {
        self.addChildViewController(diAndCVC_projectDetails)
        diAndCVC_projectDetails.view.frame = CGRectMake(0, self.view.frame.size.height - diAndCVC_projectDetails.view.frame.size.height+68, diAndCVC_projectDetails.view.frame.size.width, diAndCVC_projectDetails.view.frame.size.height)
        diAndCVC_projectDetails.closeButton.addTarget(self, action: #selector(ProjectDetailViewController.closeDiAndChallengesView), forControlEvents: .TouchUpInside)
        
        self.view.addSubview(diAndCVC_projectDetails.view)
        UIView.animateWithDuration(0.3, animations: {
            self.diAndCVC_projectDetails.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.diAndCVC_projectDetails.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.diAndCVC_projectDetails.view.frame.size.height)
            self.diAndCVC_projectDetails.view.translatesAutoresizingMaskIntoConstraints = true
            self.diAndCVC_projectDetails.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
            
        }) { (isComplete) in
            self.diAndCVC_projectDetails.didMoveToParentViewController(self)
        }
    }
    
    func closeCamAndGalleryView()
    {
        cgVC_projectDetails.view.removeFromSuperview()
        cgVC_projectDetails.removeFromParentViewController()
    }
    
    func closeDiAndChallengesView()
    {
        diAndCVC_projectDetails.view.removeFromSuperview()
        diAndCVC_projectDetails.removeFromParentViewController()
    }
    
    func showHideRecentContributionsLabel()
    {
        if(self.observersAffiliationsArray_proj.count == 0)
        {
            self.recentContributionLabel.text = "No Recent Contributions"
            self.recentContributionLabel.textAlignment = NSTextAlignment.Center
            self.recentContributionLabel.textColor = UIColor.redColor()
        }
        else
        {
            self.recentContributionLabel.text = "Recent Contributions"
            self.recentContributionLabel.textAlignment = NSTextAlignment.Left
            self.recentContributionLabel.textColor = UIColor.blackColor()
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return observersAffiliationsArray_proj.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProjectDetailCell", forIndexPath: indexPath) as! ProjectDetailCollectionViewCell
        
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1.0
        
        if let projectObservationImageUrl  = NSURL(string: observationsImagesArray[indexPath.row] as! String)
        {
            cell.observationProjectImageView.kf_setImageWithURL(projectObservationImageUrl, placeholderImage: UIImage(named: "default-no-image.png"))
        }
        
        print(observersAvatarUrls_proj[indexPath.row])
        cell.observerAvatarImageView.kf_setImageWithURL(NSURL.fileURLWithPath((observersAvatarUrls_proj[indexPath.row] as? String)!), placeholderImage: UIImage(named: "user.png"))
        
        cell.observerNameLabel.text = observersNamesArray_proj[indexPath.row] as? String
        cell.observerAffiliationLabel.text = observersAffiliationsArray_proj [indexPath.row] as? String
        
        cell.likesCountLabel.text = likesCountArray_projects[indexPath.row] as? String
        cell.commentsCountLabel.text = commentsCountArray_projects[indexPath.row] as? String
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let detailedObsVC = DetailedObservationViewController()
        detailedObsVC.observerDisplayName = observersNamesArray_proj[indexPath.row] as! String
        detailedObsVC.observerAffiliation = observersAffiliationsArray_proj[indexPath.row] as! String
        detailedObsVC.observerImageUrl = observersAvatarUrls_proj[indexPath.row] as! String
        print(observersAvatarUrls_proj[indexPath.row])
        detailedObsVC.observationText = observationsTextArray[indexPath.row] as! String
        detailedObsVC.pageTitle = projectTitle
        
        let observerImageUrlString = observationsImagesArray[indexPath.row] as! String
        let newimageURLString = observerImageUrlString.stringByReplacingOccurrencesOfString("upload/t_ios-thumbnail", withString: "upload/t_ios-large", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        detailedObsVC.observationImageUrl = newimageURLString
        detailedObsVC.observationCommentsArrayfromExploreView = commentsDictArray[indexPath.row] as! NSArray
        detailedObsVC.obsupdateddate = observationUpdatedTimestampsArray_proj[indexPath.row] as! NSNumber
        detailedObsVC.observationId = obsIdsArray[indexPath.row] as! String
        self.navigationController?.pushViewController(detailedObsVC, animated: true)
    }

}
