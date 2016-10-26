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
    var observerIdsfromMapView : NSMutableArray = []
    var commentsDictArrayfromMapView : NSMutableArray = []
    var observationCommentsArrayfromMapView : NSArray = []
    var observationIdsfromMapView : NSMutableArray = []
    
    var observationUpdatedAtTimestampsArrayFromMapview = []
    
    var exploreObservationsImagesArray : NSArray!
    
    var observerAvatarsArray : NSMutableArray = []
    var observerAvatarsUrlArray : NSMutableArray = []
    var observerNamesArray : NSMutableArray = []
    var observerAffiliationsArray : NSMutableArray = []
    var observationTextArray : NSMutableArray = []
    
    var projectNames : NSArray = []
    
    var observationsCount : Int = 0
    
    let newObsAndDIViewtemp = NewObsAndDIViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "double_down.png"), style: .Plain, target: self, action: #selector(ExploreViewController.dismissVC))
        navigationItem.leftBarButtonItem = barButtonItem
        
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
        print(observationIdsfromMapView)
        print(observationIdsfromMapView.count)
        print(observerIdsfromMapView)
        print(observerIdsfromMapView.count)
        
        for i in 0 ..< observerIdsfromMapView.count
        {
            let usersRootRef = FIRDatabase.database().referenceWithPath("users/\(observerIdsfromMapView[i])")
            //Firebase(url:USERS_URL+"\(observerIdsfromMapView[i])")
            usersRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                print(usersRootRef)
                //print(snapshot.value.count)
                //self.observerNamesArray = []
                self.observerAffiliationsArray.removeAllObjects()
                
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
                                }
                                else
                                {
                                    self.observerAffiliationsArray.addObject("No Affiliation")
                                }
                                
                                
                                
                            }
                            self.collectionView.reloadData()
                            }, withCancelBlock: { error in
                                print(error.description)
                                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                                alert.addAction(action)
                                self.presentViewController(alert, animated: true, completion: nil)

                        })

                        
                        //self.observerAffiliationsArray.addObject(observerAffiliationString)
                    }
                    else
                    {
                        self.observerAffiliationsArray.addObject("No Affiliation")
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
                    self.observationsCount = self.observationIdsfromMapView.count
                    print(self.observationsCount)
                    //self.collectionView.reloadData()
                    
                }
                
                }, withCancelBlock: { error in
                    print(error.description)
                    let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)

            })
            print(observationsCount)
        }
        print(observerAffiliationsArray)
        print(observerNamesArray)
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
        print(observerAvatarsUrlArray[indexPath.row])
        cell.exploreProfileIcon.kf_setImageWithURL(observerAvatarsUrlArray[indexPath.row] as! NSURL, placeholderImage: UIImage(named: "user.png"))
        
        if(observerNamesArray[indexPath.row] as! String != "")
        {
            cell.exploreProfileName.text = (observerNamesArray[indexPath.row] as! String)
        }
        else
        {
            cell.exploreProfileName.text = "No Display Name"
        }
        
       
        cell.exploreDate.text = (observerAffiliationsArray[indexPath.row] as! String)
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView,
        didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //print(indexPath)
        let detailedObservationVC = DetailedObservationViewController()
        print(observerAvatarsUrlArray[indexPath.row].absoluteString)
        detailedObservationVC.observerImageUrl = observerAvatarsUrlArray[indexPath.row].absoluteString
        detailedObservationVC.observerDisplayName = observerNamesArray[indexPath.row] as! String;
        detailedObservationVC.observerAffiliation = observerAffiliationsArray[indexPath.row] as! String;
        detailedObservationVC.observationText = observationTextArray[indexPath.row] as! String;
        
        detailedObservationVC.pageTitle = projectNames[indexPath.row] as! String
        detailedObservationVC.obsupdateddate = observationUpdatedAtTimestampsArrayFromMapview[indexPath.row] as! NSNumber
        
        let observerImageUrlString = exploreObservationsImagesArray[indexPath.row] as! String
        let newimageURLString = observerImageUrlString.stringByReplacingOccurrencesOfString("upload/t_ios-thumbnail", withString: "upload/t_ios-large", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        detailedObservationVC.observationImageUrl = newimageURLString
        //detailedObservationVC.observationsIdsfromExploreView = observerIdsfromMapView
        detailedObservationVC.observationId = observationIdsfromMapView[indexPath.row] as! String
        detailedObservationVC.observationCommentsArrayfromExploreView = commentsDictArrayfromMapView[indexPath.row] as! NSArray
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
