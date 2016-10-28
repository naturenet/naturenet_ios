//
//  ExploreViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/19/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class ExploreViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    var collectionView: UICollectionView!
    var observerIdsGallery : NSMutableArray = []
    var commentsDictArrayGallery : NSMutableArray = []
    var observationCommentsArrayGallery : NSArray = []
    var observationIdsGallery : NSMutableArray = []
    
    var observationUpdatedAtTimestampsArrayGallery : NSMutableArray = []
    
    var exploreObservationsImagesArray : NSMutableArray = []
    
    var observerAvatarsArray : NSMutableArray = []
    var observerAvatarsUrlArray : NSMutableArray = []
    var observerNamesArray : NSMutableArray = []
    var observerAffiliationsArray : NSMutableArray = []
    var observationTextArray : NSMutableArray = []
    
    var projectNames : NSMutableArray = []
    var affiliationDictionary : NSMutableDictionary = [:]
    
    var observationsCount : Int = 0
    
    let newObsAndDIViewtemp = NewObsAndDIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        
//        let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(ExploreViewController.dismissVC))
//        navigationItem.leftBarButtonItem = barButtonItem
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            
            navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        self.navigationItem.title="Explore"
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //Setting up collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 172, height: 172)
        
        collectionView = UICollectionView(frame: UIScreen.mainScreen().bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView!.backgroundColor = UIColor.whiteColor()
        collectionView.alwaysBounceVertical=true
        
        //Registering custom Cell
        self.collectionView.registerNib(UINib(nibName: "ExploreCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ExploreCell")
        //self.view.addSubview(collectionView)
        collectionView!.decelerationRate = UIScrollViewDecelerationRateFast
        
        self.view.addSubview(collectionView)
        
        
        self.getObservations()
        
//        for i in 0 ..< observerIdsGallery.count
//        {
//            let usersRootRef = FIRDatabase.database().referenceWithPath("users/\(observerIdsGallery[i])")
//            //Firebase(url:USERS_URL+"\(observerIdsfromMapView[i])")
//            usersRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//                
//                print(usersRootRef)
//                //print(snapshot.value.count)
//                //self.observerNamesArray = []
//                self.observerAffiliationsArray.removeAllObjects()
//                
//                if !(snapshot.value is NSNull)
//                {
//                    if((snapshot.value!.objectForKey("affiliation")) != nil && (snapshot.value!.objectForKey("affiliation")) as! String != "")
//                    {
//                        let observerAffiliationString = snapshot.value!.objectForKey("affiliation") as! String
//                        let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/"+observerAffiliationString)
//                        //Firebase(url:FIREBASE_URL + "sites/"+aff!)
//                        sitesRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//                            
//                            
//                            print(sitesRootRef)
//                            print(snapshot.value)
//                            
//                            if !(snapshot.value is NSNull)
//                            {
//                                print(snapshot.value!.objectForKey("name"))
//                                if(snapshot.value!.objectForKey("name") != nil)
//                                {
//                                    //cell.exploreDate.text = snapshot.value!.objectForKey("name") as? String
//                                    self.observerAffiliationsArray.addObject((snapshot.value!.objectForKey("name") as? String)!)
//                                }
//                                else
//                                {
//                                    self.observerAffiliationsArray.addObject("No Affiliation")
//                                }
//                                
//                                
//                                
//                            }
//                            self.collectionView.reloadData()
//                            }, withCancelBlock: { error in
//                                print(error.description)
//                                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
//                                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
//                                alert.addAction(action)
//                                self.presentViewController(alert, animated: true, completion: nil)
//
//                        })
//
//                        
//                        //self.observerAffiliationsArray.addObject(observerAffiliationString)
//                    }
//                    else
//                    {
//                        self.observerAffiliationsArray.addObject("No Affiliation")
//                    }
//                    if((snapshot.value!.objectForKey("display_name")) != nil)
//                    {
//                        let observerDisplayNameString = snapshot.value!.objectForKey("display_name") as! String
//                        self.observerNamesArray.addObject(observerDisplayNameString)
//                    }
//                    else
//                    {
//                        self.observerNamesArray.addObject("No Diaplay Name")
//                    }
//                    
//                    
//                    if((snapshot.value!.objectForKey("avatar")) != nil)
//                    {
//                        print(snapshot.value!)
//                        let observerAvatar = snapshot.value!.objectForKey("avatar")
//                        print(observerAvatar)
//                        let observerAvatarUrl  = NSURL(string: observerAvatar as! String)
//                        if(UIApplication.sharedApplication().canOpenURL(observerAvatarUrl!) == true)
//                        {
//                            //self.observerAvatarsArray.addObject(NSData(contentsOfURL: observerAvatarUrl!)!)
//                            self.observerAvatarsUrlArray.addObject(observerAvatarUrl!)
//                        }
//                        else
//                        {
//                            let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
//                            
//                            
//                            //self.observerAvatarsArray.addObject(NSData(contentsOfURL: tempImageUrl!)!)
//                            self.observerAvatarsUrlArray.addObject(tempImageUrl!)
//                        }
//                        //let observerAvatarData = NSData(contentsOfURL: observerAvatarUrl!)
//                    }
//                    else
//                    {
//                        let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
//                        
//                        //self.observerAvatarsArray.addObject(NSData(contentsOfURL: tempImageUrl!)!)
//                        self.observerAvatarsUrlArray.addObject(tempImageUrl!)
//                        
//                    }
//                    
//                }
//                
//                }, withCancelBlock: { error in
//                    print(error.description)
//                    let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
//                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
//                    alert.addAction(action)
//                    self.presentViewController(alert, animated: true, completion: nil)
//
//            })
//            
//        }
        
    }
    
    func getObservations()
    {
        let observationsRootRef = FIRDatabase.database().referenceWithPath("observations")
        observationsRootRef.queryOrderedByChild("updated_at").queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in
            
            print(observationsRootRef)
            print(snapshot.value!)
            print(snapshot.value!.allValues)
            
            if !(snapshot.value is NSNull)
            {
                for i in 0 ..< snapshot.value!.count
                {
                    let observationData = snapshot.value!.allValues[i] as! NSDictionary
                    print(observationData)
                    
                    if(observationData.objectForKey("updated_at") != nil)
                    {
                        let obsUpdatedAt = observationData.objectForKey("updated_at") as! NSNumber
                        self.observationUpdatedAtTimestampsArrayGallery.addObject(obsUpdatedAt)
                        
                    }
                    else
                    {
                        self.observationUpdatedAtTimestampsArrayGallery.addObject(0)
                    }
                    
                    if(observationData.objectForKey("comments") != nil)
                    {
                        let tempcomments = observationData.objectForKey("comments") as! NSDictionary
                        print(tempcomments)
                        let commentsKeysArray = tempcomments.allKeys as NSArray
                        self.commentsDictArrayGallery.addObject(commentsKeysArray)
                        
                        print(self.commentsDictArrayGallery)
                        
                        print(observationData.objectForKey("id"))
                        
                       
                    }
                    else
                    {
                        let tempcomments = NSArray()
                        self.commentsDictArrayGallery.addObject(tempcomments)
        
                    }
                    
                    
                    var obsId = "";
                    if(observationData.objectForKey("id") != nil)
                    {
                        obsId = observationData.objectForKey("id") as! String
                        print(obsId)
                        self.observationIdsGallery.addObject(obsId)
                    }
                    else
                    {
                        self.observationIdsGallery.addObject("")
                    }
                    
                    var observationImageAndText: NSDictionary = [:]
                    
                    if(observationData.objectForKey("data") != nil)
                    {
                        observationImageAndText = observationData.objectForKey("data") as! NSDictionary
                    }
                    else
                    {
                        let tempDic = NSDictionary()
                        observationImageAndText = tempDic
                    }
                    
                    if(observationImageAndText["image"] != nil)
                    {
                        
                        print(observationImageAndText["image"])
                        let imageURLString = observationImageAndText["image"] as! String
                        //let aString: String = "This is my string"
                        //let newimageURLString = imageURLString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        self.exploreObservationsImagesArray.addObject(imageURLString)
                    }
                    else
                    {
                        self.exploreObservationsImagesArray.addObject("")
                    }
                    if(observationImageAndText["text"] != nil)
                    {
                        //print(observationImageAndText["text"])
                        self.observationTextArray.addObject(observationImageAndText["text"]!)
                    }
                    else
                    {
                        self.observationTextArray.addObject("No Description")
                    }
                    
                    var observerId = ""
                    if(observationData.objectForKey("observer") != nil)
                    {
                        observerId = observationData.objectForKey("observer") as! String
                        //print(observerId)
                        self.observerIdsGallery.addObject(observerId)
                    }
                    else
                    {
                        self.observerIdsGallery.addObject("")
                    }
                    
                    if(observationData.objectForKey("activity") != nil)
                    {
                        
                        let obsActivity = observationData.objectForKey("activity") as! String
                        
                        let activitiesRootRef = FIRDatabase.database().referenceWithPath("activities/\(obsActivity)")
                        //Firebase(url:FIREBASE_URL + "activities")
                        activitiesRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                            
                            print(activitiesRootRef)
                            print(snapshot.value!)
                            
                            if !(snapshot.value is NSNull)
                            {
                                
                                if(snapshot.value!.objectForKey("name") != nil)
                                {
                                    
                                self.projectNames.addObject(snapshot.value!.objectForKey("name")!)
                                    
                                }
                                
                                
                            }
                            
                            
                            }, withCancelBlock: { error in
                                print(error.description)
                                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                                alert.addAction(action)
                                self.presentViewController(alert, animated: true, completion: nil)
                                
                        })
                        
                        
                    }

                    
                    let usersRootRef = FIRDatabase.database().referenceWithPath("users/\(observerId)")
                    //Firebase(url:USERS_URL+"\(observerIdsfromMapView[i])")
                    usersRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                        
                        print(usersRootRef)
                        //print(snapshot.value.count)
                        
                        if !(snapshot.value is NSNull)
                        {
                            if((snapshot.value!.objectForKey("affiliation")) != nil && (snapshot.value!.objectForKey("affiliation")) as! String != "")
                            {
                                let observerAffiliationString = snapshot.value!.objectForKey("affiliation") as! String
                                let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/"+observerAffiliationString)
                                //Firebase(url:FIREBASE_URL + "sites/"+aff!)
                                sitesRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                                    
                                    
                                    print(sitesRootRef)
                                    print(snapshot.value)
                                    
                                    if !(snapshot.value is NSNull)
                                    {
                                        print(snapshot.value!.objectForKey("name"))
                                        if(snapshot.value!.objectForKey("name") != nil)
                                        {
                                            //cell.exploreDate.text = snapshot.value!.objectForKey("name") as? String
                                            self.observerAffiliationsArray.addObject((snapshot.value!.objectForKey("name") as? String)!)
                                            self.affiliationDictionary.setValue((snapshot.value!.objectForKey("name") as? String)!, forKey: observerId)
                                            
                                        }
                                        else
                                        {
                                            self.observerAffiliationsArray.addObject("No Affiliation")
                                            self.affiliationDictionary.setValue((snapshot.value!.objectForKey("No Affiliation") as? String)!, forKey: observerId)
                                        }
                                        self.collectionView.reloadData()
                                        
                                    }
                                    }, withCancelBlock: { error in
                                        
                                        //self.errorValue = error.localizedDescription
                                        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                                        alert.addAction(action)
                                        self.presentViewController(alert, animated: true, completion: nil)
                                })
                                
                            }
                            else
                            {
                                self.observerAffiliationsArray.addObject("No Affiliation")
                                self.affiliationDictionary.setValue("No Affiliation", forKey: observerId)
                                
                            }
                            if((snapshot.value!.objectForKey("display_name")) != nil)
                            {
                                let observerDisplayNameString = snapshot.value!.objectForKey("display_name") as! String
                                self.observerNamesArray.addObject(observerDisplayNameString)
                            }
                            else
                            {
                                self.observerNamesArray.addObject("No Diaplay Name")
                            }
                            
                            if((snapshot.value!.objectForKey("avatar")) != nil)
                            {
                                print(snapshot.value!)
                                let observerAvatar = snapshot.value!.objectForKey("avatar")
                                print(observerAvatar)
                                let observerAvatarUrl  = NSURL(string: observerAvatar as! String)
                                if(UIApplication.sharedApplication().canOpenURL(observerAvatarUrl!) == true)
                                {
                                    //self.observerAvatarsArray.addObject(NSData(contentsOfURL: observerAvatarUrl!)!)
                                    self.observerAvatarsUrlArray.addObject(observerAvatarUrl!)
                                }
                                else
                                {
                                    let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                                    
                                    
                                    //self.observerAvatarsArray.addObject(NSData(contentsOfURL: tempImageUrl!)!)
                                    self.observerAvatarsUrlArray.addObject(tempImageUrl!)
                                }
                                //let observerAvatarData = NSData(contentsOfURL: observerAvatarUrl!)
                            }
                            else
                            {
                                let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                                
                                //self.observerAvatarsArray.addObject(NSData(contentsOfURL: tempImageUrl!)!)
                                self.observerAvatarsUrlArray.addObject(tempImageUrl!)
                                
                            }
                            
                        }
                        
                        }, withCancelBlock: { error in
                            // self.errorValue = error.localizedDescription
                            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                            alert.addAction(action)
                            self.presentViewController(alert, animated: true, completion: nil)
                            
                    })

                    
                    
                }
                
                self.collectionView.reloadData()
            }
            else
            {
                
            }
            
            
            
            }, withCancelBlock: { error in
                print(error.description)
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
        })

    }
    
    func dismissVC(){
        
        //self.navigationController!.dismissViewControllerAnimated(true, completion: {})
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: {})
        //self.view.window!.rootViewController?.dismissViewControllerAnimated(false, completion: nil)
        //print("abhi")
        
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return observerAffiliationsArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        //let userData = GetUserInfo().getUserInformation(observerIdsGallery[indexPath.row] as! String)
        //print(userData)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ExploreCell", forIndexPath: indexPath) as! ExploreCollectionViewCell
        
        cell.layer.borderColor = UIColor.lightGrayColor().CGColor
        cell.layer.borderWidth = 1.0
        
        let observationsImageUrlString = exploreObservationsImagesArray[indexPath.row] as! String
        print(observationsImageUrlString)
        let newimageURLString = observationsImageUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
        //observerImageUrlData = NSData(contentsOfURL: observerImageUrl)
        let observationsImageUrl  = NSURL(string: newimageURLString)
        //if let observationsImageUrl  = NSURL(string: newimageURLString)
        //{
            //cell.exploreImageView.image = UIImage(data: observerImageUrlData)
            print(observationsImageUrl)
            cell.exploreImageView.kf_setImageWithURL(observationsImageUrl!, placeholderImage: UIImage(named: "default-no-image.png"))
        //}
        cell.bringSubviewToFront(cell.exploreProfileSubView)
        cell.exploreImageView.contentMode = UIViewContentMode.ScaleAspectFit
        
        //cell.exploreProfileIcon.image = UIImage(data: observerAvatarsArray[indexPath.row] as! NSData)
//        print(observerAvatarsUrlArray[indexPath.row])
        cell.exploreProfileIcon.kf_setImageWithURL(observerAvatarsUrlArray[indexPath.row] as! NSURL, placeholderImage: UIImage(named: "user.png"))
        
//        if(observerNamesArray[indexPath.row] as! String != "")
//        {
            cell.exploreProfileName.text = (observerNamesArray[indexPath.row] as! String)
//        }
//        else
//        {
//            cell.exploreProfileName.text = "No Display Name"
//        }
        
       
        cell.exploreDate.text = affiliationDictionary.objectForKey(observerIdsGallery[indexPath.row]) as! String
        
        
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //print(indexPath)
        let detailedObservationVC = DetailedObservationViewController()
        print(observerAvatarsUrlArray[indexPath.row].absoluteString)
        detailedObservationVC.observerImageUrl = observerAvatarsUrlArray[indexPath.row].absoluteString
        detailedObservationVC.observerDisplayName = observerNamesArray[indexPath.row] as! String;
        detailedObservationVC.observerAffiliation = affiliationDictionary.objectForKey(observerIdsGallery[indexPath.row]) as! String
        detailedObservationVC.observationText = observationTextArray[indexPath.row] as! String;
        
        detailedObservationVC.pageTitle = projectNames[indexPath.row] as! String
        detailedObservationVC.obsupdateddate = observationUpdatedAtTimestampsArrayGallery[indexPath.row] as! NSNumber
        
        let observerImageUrlString = exploreObservationsImagesArray[indexPath.row] as! String
        let newimageURLString = observerImageUrlString.stringByReplacingOccurrencesOfString("upload/t_ios-thumbnail", withString: "upload/t_ios-large", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        detailedObservationVC.observationImageUrl = newimageURLString
        //detailedObservationVC.observationsIdsfromExploreView = observerIdsfromMapView
        detailedObservationVC.observationId = observationIdsGallery[indexPath.row] as! String
        detailedObservationVC.observationCommentsArrayfromExploreView = commentsDictArrayGallery[indexPath.row] as! NSArray
        self.navigationController?.pushViewController(detailedObservationVC, animated: true)
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
