//
//  MapViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/17/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase


class MapViewController: UIViewController, CLLocationManagerDelegate,MKMapViewDelegate{
    
    @IBOutlet var mapAnnotationClickView: UIView!
    @IBOutlet weak var exploreView: UIView!
    @IBOutlet weak var mapAnnotationClickSubView: UIView!
    let locationManager = CLLocationManager()
    @IBOutlet var mapTypeView: UIView!
    
    @IBOutlet weak var observationImageView: UIImageView!
    @IBOutlet weak var observerDisplayName: UILabel!
    @IBOutlet weak var observerAffiliation: UILabel!
    @IBOutlet weak var observerAvatarImageView: UIImageView!
    @IBOutlet weak var observationTextLabel: UILabel!
    var count = 0
    var observationImagesArray : NSMutableArray = []
    var observationTextArray : NSMutableArray = []
    var observerIds : NSMutableArray = []
    
    var observerAvatarUrlString : String = ""
    var observervationUrlString : String = ""
    
    let mapView = MKMapView(frame: UIScreen.mainScreen().bounds)
    var tempAnnotationView : MKAnnotationView!
    
    var likesCount: Int = 0
    var likesCountArray: NSMutableArray = []
    
    var commentsDictArray : NSMutableArray = []
    var commentsDicttoDetailVC : NSDictionary = [:]
    var commentsCountArray: NSMutableArray = []
    
    let newObsAndDIView = NewObsAndDIViewController()
    
    let cgVC = CameraAndGalleryViewController()
    let diAndCVC = DesignIdeasAndChallengesViewController()
    
    var observationIds : NSMutableArray = []
    
    var observationId : String = ""
    
    var locValue = CLLocationCoordinate2D()
    
    var observationProjectNames : NSMutableArray = []
    
    var ProjectName : String = ""
    
    var observationCommentsArray : NSArray = []
    
    var observationUpdatedTimestampsArray : NSMutableArray = []
    var observationUpdatedTimestamp: NSNumber = 0
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var likesCountLabel: UILabel!
    
    @IBOutlet weak var commentsCountLabel: UILabel!
    
    var observationsLimit : UInt = 10
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(exploreView);
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
           
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            
            navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        let rightbarButtonItem = UIBarButtonItem(image: UIImage(named: "more.png"), style: .Plain, target: self, action: #selector(MapViewController.mapTypes))
        navigationItem.rightBarButtonItem = rightbarButtonItem
        
        
        self.navigationItem.title="NatureNet"
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        //Bottom View to go to Explore View Controller
        exploreView.backgroundColor=UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        exploreView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MapViewController.tappedView)))
        exploreView.userInteractionEnabled = true
        
        activityIndicator.hidden = true

        //Map View
        mapView.frame = CGRectMake(0 , 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height-self.exploreView.frame.height)
        mapView.delegate = self
        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MapViewController.mapViewTapped)))
        mapView.userInteractionEnabled = true
        mapView.mapType = .Satellite
        
        //Location Manager to get current location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        else
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
                    
                    //var locCoord = CLLocationCoordinate2D()
                    self.locValue.latitude = siteLocationArray[0] as! Double
                    self.locValue.longitude = siteLocationArray[1] as! Double
                    
                    self.setMapViewCoordinates(self.locValue)
                    
                    
                    }, withCancelBlock: { error in
                        print(error.description)
                        let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                        alert.addAction(action)
                        self.presentViewController(alert, animated: true, completion: nil)

                })

                
            }
            
        }
        
        
        self.view.addSubview(mapView)
        
        //Annotation View
        mapAnnotationClickView.frame = CGRectMake(0,UIScreen.mainScreen().bounds.size.height-mapAnnotationClickView.frame.size.height, mapAnnotationClickView.frame.size.width, mapAnnotationClickView.frame.size.height)
        mapAnnotationClickSubView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MapViewController.mapAnnotationClickSubViewtapped)))
        mapAnnotationClickSubView.userInteractionEnabled = true
        
        //Getting Observations
        self.getObservations()
        
        //Cam and design Idea buttons view
        newObsAndDIView.view.frame = CGRectMake(0 ,UIScreen.mainScreen().bounds.size.height-newObsAndDIView.view.frame.size.height-exploreView.frame.size.height-8, UIScreen.mainScreen().bounds.size.width, newObsAndDIView.view.frame.size.height)
        newObsAndDIView.view.translatesAutoresizingMaskIntoConstraints = true
        newObsAndDIView.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        self.view.addSubview(newObsAndDIView.view)
        newObsAndDIView.camButton.addTarget(self, action: #selector(MapViewController.openNewObsView), forControlEvents: .TouchUpInside)
        newObsAndDIView.designIdeaButton.addTarget(self, action: #selector(MapViewController.openNewDesignView), forControlEvents: .TouchUpInside)
        
    }
    
    // MARK: - *** Setting MapView Coordinates and getting current location ***
    func setMapViewCoordinates(locationCoord: CLLocationCoordinate2D)
    {
        let regionRadius: CLLocationDistance = 600
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(locationCoord,
                                                                      regionRadius * 4.0, regionRadius * 4.0)
        self.mapView.setRegion(coordinateRegion, animated: true)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        locValue = locations.last!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        
        self.setMapViewCoordinates(locValue)
    }
    
    //Open Camera and Gallery Selection View
    func openNewObsView()
    {
        //print("gverver")
        self.addChildViewController(cgVC)
        
        cgVC.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - cgVC.view.frame.size.height+68, cgVC.view.frame.size.width, cgVC.view.frame.size.height)
        self.view.addSubview(cgVC.view)
        cgVC.closeButton.hidden = true
        UIView.animateWithDuration(0.3, animations: {
        
            self.cgVC.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.cgVC.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.cgVC.view.frame.size.height)
            
            self.cgVC.view.translatesAutoresizingMaskIntoConstraints = true
            self.cgVC.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
        
        }) { (isComplete) in
        
            self.cgVC.didMoveToParentViewController(self)
                    
        }
    }
    
    //Open Design Ideas and challenges Selection View
    func openNewDesignView()
    {
        //print("gverver")
        self.addChildViewController(diAndCVC)
        diAndCVC.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - diAndCVC.view.frame.size.height+68, diAndCVC.view.frame.size.width, diAndCVC.view.frame.size.height)
        diAndCVC.closeButton.hidden = true
        
        self.view.addSubview(diAndCVC.view)
        UIView.animateWithDuration(0.3, animations: {
            
            self.diAndCVC.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - self.diAndCVC.view.frame.size.height+68, UIScreen.mainScreen().bounds.size.width, self.diAndCVC.view.frame.size.height)
            
            self.diAndCVC.view.translatesAutoresizingMaskIntoConstraints = true
            self.diAndCVC.view.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.None, UIViewAutoresizing.FlexibleBottomMargin]
            
        }) { (isComplete) in
            
            self.diAndCVC.didMoveToParentViewController(self)
            
        }
    }
    
    func getObservations()
    {
        
        let observationsRootRef = FIRDatabase.database().referenceWithPath("observations")
        observationsRootRef.queryOrderedByChild("updated_at").queryLimitedToLast(10).observeEventType(.Value, withBlock: { snapshot in
            
            //Empty all the arrays
            self.commentsDictArray.removeAllObjects()
            self.commentsCountArray.removeAllObjects()
            self.likesCount = 0
            self.likesCountArray.removeAllObjects()
            self.observerIds.removeAllObjects()
            self.observationProjectNames.removeAllObjects()
            self.observationTextArray.removeAllObjects()
            self.observationImagesArray.removeAllObjects()
            self.observationIds.removeAllObjects()
            self.observationUpdatedTimestampsArray.removeAllObjects()
            var tagAnnotation = 0;

            
            print(observationsRootRef)
            print(snapshot.value!)
            
            if !(snapshot.value is NSNull)
            {
                for i in 0 ..< snapshot.value!.count
                {
                    let observationData = snapshot.value!.allValues[i] as! NSDictionary
                    print(observationData)
                    
                    if(observationData.objectForKey("updated_at") != nil)
                    {
                        let obsUpdatedAt = observationData.objectForKey("updated_at") as! NSNumber
                        self.observationUpdatedTimestampsArray.addObject(obsUpdatedAt)
                        
                    }
                    else
                    {
                        self.observationUpdatedTimestampsArray.addObject(0)
                    }
                    
                    if(observationData.objectForKey("comments") != nil)
                    {
                        let tempcomments = observationData.objectForKey("comments") as! NSDictionary
                        print(tempcomments)
                        let commentsKeysArray = tempcomments.allKeys as NSArray
                        self.commentsDictArray.addObject(commentsKeysArray)
                        
                        print(self.commentsDictArray)
                        
                        print(observationData.objectForKey("id"))
                        
                        self.commentsCountArray.addObject("\(commentsKeysArray.count)")
                    }
                    else
                    {
                        let tempcomments = NSArray()
                        self.commentsDictArray.addObject(tempcomments)
                        
                        self.commentsCountArray.addObject("0")
                    }
                    
                    if(observationData.objectForKey("likes") != nil)
                    {
                        let likesDictionary = observationData.objectForKey("likes") as! NSDictionary
                        print(likesDictionary.allValues)
                        
                        let likesArray = likesDictionary.allValues as NSArray
                        print(likesArray)
                        
                        
                        for l in 0 ..< likesArray.count
                        {
                            if(likesArray[l] as! NSObject == 1)
                            {
                                self.likesCount += 1
                            }
                        }
                        print(self.likesCount)
                        
                        
                        self.likesCountArray.addObject("\(self.likesCount)")
                        
                        
                    }
                    else
                    {
                        self.likesCountArray.addObject("0")
                    }
                    var obsId = "";
                    if(observationData.objectForKey("id") != nil)
                    {
                        obsId = observationData.objectForKey("id") as! String
                        print(obsId)
                        self.observationIds.addObject(obsId)
                    }
                    else
                    {
                        self.observationIds.addObject("")
                    }
                    
                    var latAndLongs: NSArray = []
                    var observationImageAndText: NSDictionary = [:]
                    latAndLongs = (observationData.objectForKey("l") as? NSArray)!
                    
                    if(((observationData.objectForKey("l") != nil) || (!(observationData.objectForKey("l") is NSNull))) && ((latAndLongs[0].intValue != 0) && (latAndLongs[1].intValue != 0)))
                    {
                        
                        print(latAndLongs[0])
                        print(latAndLongs[1])
                        print(latAndLongs)
                        let annotationLatAndLong = CLLocation(latitude: latAndLongs[0].doubleValue, longitude: latAndLongs[1].doubleValue)
                        
                        self.mapViewCoordinate(annotationLatAndLong, tagForAnnotation: tagAnnotation)
                        tagAnnotation = tagAnnotation+1
                        
                    }
                    else{
                        
                        let tempArr = NSArray()
                        latAndLongs = tempArr
                    }
                    if(observationData.objectForKey("data") != nil)
                    {
                        observationImageAndText = observationData.objectForKey("data") as! NSDictionary
                    }
                    else
                    {
                        let tempDic = NSDictionary()
                        observationImageAndText = tempDic
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
                                    
                                    self.observationProjectNames.addObject(snapshot.value!.objectForKey("name")!)
                                    
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

                   
                    print(self.observationIds)
                    
                    if(observationImageAndText["image"] != nil)
                    {
                        
                        print(observationImageAndText["image"])
                        let imageURLString = observationImageAndText["image"] as! String
                        //let aString: String = "This is my string"
                        //let newimageURLString = imageURLString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        self.observationImagesArray.addObject(imageURLString)
                    }
                    else
                    {
                        self.observationImagesArray.addObject("")
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
                    
                    if(observationData.objectForKey("observer") != nil)
                    {
                        let observerId = observationData.objectForKey("observer") as! String
                        //print(observerId)
                        self.observerIds.addObject(observerId)
                    }
                    else
                    {
                        self.observerIds.addObject("")
                    }
                    

                }
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
    
    func mapTypes()
    {
        mapTypeView.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - mapTypeView.frame.size.width-mapTypeView.frame.size.width/12,64, mapTypeView.frame.size.width, mapTypeView.frame.size.height)
        
        if(count%2 == 0)
        {
            self.view.addSubview(mapTypeView)
        }
        else
        {
            mapTypeView.removeFromSuperview()
        }
        count += 1
        
    }
    
    @IBAction func mapTypeStandard(sender: UIButton) {
        
        mapView.mapType = .Standard
        
    }
    
    @IBAction func mapTypeSatellite(sender: UIButton) {
        
        mapView.mapType = .Satellite
        
    }
    
    func mapViewTapped()
    {
        if let mapTypeViewWithTag = self.view.viewWithTag(9) {
            mapTypeViewWithTag.removeFromSuperview()
            count += 1
        }
        if let exploreViewWithTag = self.view.viewWithTag(8) {
            exploreViewWithTag.removeFromSuperview()
            
        }
        newObsAndDIView.view.frame = CGRectMake(0 ,UIScreen.mainScreen().bounds.size.height-newObsAndDIView.view.frame.size.height-8 - 60, newObsAndDIView.view.frame.size.width, newObsAndDIView.view.frame.size.height)
        cgVC.view.removeFromSuperview()
        cgVC.removeFromParentViewController()
        diAndCVC.view.removeFromSuperview()
        diAndCVC.removeFromParentViewController()
        
    }
    
    func mapViewCoordinate(annotationLocation: CLLocation, tagForAnnotation : Int)
    {
        let initialLocation = CLLocation(latitude: annotationLocation.coordinate.latitude, longitude: annotationLocation.coordinate.longitude)
        
        self.setMapViewCoordinates(locValue)
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(initialLocation.coordinate.latitude, initialLocation.coordinate.longitude)
        annotation.title = String(tagForAnnotation)
        mapView.addAnnotation(annotation)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tappedView(){
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        
        exploreView.backgroundColor=UIColor.lightGrayColor()
        exploreView.userInteractionEnabled = false
        let eVC = ExploreViewController() //change this to your class name
        eVC.exploreObservationsImagesArray = observationImagesArray
        eVC.observerIdsfromMapView = observerIds
        eVC.observationTextArray = observationTextArray
        eVC.commentsDictArrayfromMapView = commentsDictArray
        eVC.observationIdsfromMapView = observationIds
        eVC.observationUpdatedAtTimestampsArrayFromMapview = observationUpdatedTimestampsArray
        eVC.projectNames = observationProjectNames
        
        let exploreNavVC = UINavigationController()
        exploreNavVC.viewControllers = [eVC]
        self.presentViewController(exploreNavVC, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        exploreView.backgroundColor=UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        exploreView.userInteractionEnabled = true
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true

        self.getObservations()
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "MyPin"
        
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        }
        
        // Reuse the annotation if possible
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        let str :String? = annotation.title!
        let tag: Int? = Int(str!)
    
        
        //if annotationView == nil
        //{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "MyPin")
            annotationView!.canShowCallout = false
            annotationView!.contentMode = UIViewContentMode.ScaleAspectFit
            annotationView?.tag = tag!
            
            let annotationImageView = UIImageView(image: UIImage(named:"marker.png"))
            
            var annotationImageRect = annotationImageView.frame as CGRect
            annotationImageRect.size.height = 44
            annotationImageRect.size.width = 44
            
            annotationImageView.frame = annotationImageRect
            annotationView?.frame = annotationImageRect
            
            annotationView?.addSubview(annotationImageView)
            
//        }
//        else
//        {
//            annotationView!.annotation = annotation
//        }
        
        
        return annotationView
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if let annotation = view.annotation as? MKPointAnnotation {
//            mapView.removeAnnotation(annotation)
//        }
    }
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView)
    {
        print("annotation")
        
        UIView.animateWithDuration(0.3, animations: {
           
            self.newObsAndDIView.view.frame = CGRectMake(0 , self.mapAnnotationClickView.frame.origin.y - self.newObsAndDIView.view.frame.size.height-8, self.newObsAndDIView.view.frame.width, self.newObsAndDIView.view.frame.height)
        
            self.view.addSubview(self.mapAnnotationClickView)
            
        })
        likesCountLabel.text = "\(likesCountArray[view.tag])"
        commentsCountLabel.text = "\(commentsCountArray[view.tag])"
        
        observationId = observationIds[view.tag] as! String
        ProjectName = observationProjectNames[view.tag] as! String
        observationUpdatedTimestamp = observationUpdatedTimestampsArray[view.tag] as! NSNumber

        print(commentsDictArray.objectAtIndex(view.tag))
        
        observationCommentsArray = commentsDictArray.objectAtIndex(view.tag)  as! NSArray
        
        observationTextLabel.text = (observationTextArray[view.tag] as! String)
        
        if NSURL(string: observationImagesArray[view.tag] as! String) != nil
        {
            observervationUrlString = observationImagesArray[view.tag] as! String
            let newimageURLString = observervationUrlString.stringByReplacingOccurrencesOfString("upload/", withString: "upload/t_ios-thumbnail/", options: NSStringCompareOptions.LiteralSearch, range: nil)
            let newUrl  = NSURL(string:newimageURLString)
            print(newUrl)
            observationImageView.kf_setImageWithURL(newUrl!, placeholderImage: UIImage(named: "default-no-image.png"))
            
        }
        
        
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        reachability.whenReachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                //                if reachability.isReachableViaWiFi() {
                //                    print("Reachable via WiFi")
                //                } else {
                //                    print("Reachable via Cellular")
                //                }
                print(self.observerIds[view.tag])
                
            let usersRootRef = FIRDatabase.database().referenceWithPath("users/\(self.observerIds[view.tag])")
                print(usersRootRef)
                //Firebase(url:USERS_URL+"\(self.observerIds[view.tag])")
            usersRootRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    print(usersRootRef)
                    //print(snapshot.value!.count)
                    
                    if !(snapshot.value is NSNull)
                    {
                        
                        if((snapshot.value!.objectForKey("affiliation")) != nil)
                        {
                            let observerAffiliationString = snapshot.value!.objectForKey("affiliation") as! String
                            let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/"+observerAffiliationString)
                            //Firebase(url:FIREBASE_URL + "sites/"+aff!)
                            sitesRootRef.observeEventType(.Value, withBlock: { snapshot in
                                
                                
                                print(sitesRootRef)
                                print(snapshot.value)
                                
                                if !(snapshot.value is NSNull)
                                {
                                    
                                    
                                    print(snapshot.value!.objectForKey("name"))
                                    if(snapshot.value!.objectForKey("name") != nil)
                                    {
                                        self.observerAffiliation.text = snapshot.value!.objectForKey("name") as? String
                                    }
                                    
                                    
                                    
                                }
                                
                                }, withCancelBlock: { error in
                                    print(error.description)
                                    let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                                    alert.addAction(action)
                                    self.presentViewController(alert, animated: true, completion: nil)

                            })

                            
                            //self.observerAffiliation.text = observerAffiliationString
                            //observerAffiliationsArray.addObject(observerAffiliationString)
                            //print(observerAffiliationString)
                        }
                        else
                        {
                            self.observerAffiliation.text = "No Affiliation"
                        }
                        
                        if((snapshot.value!.objectForKey("display_name")) != nil)
                        {
                            let observerDisplayNameString = snapshot.value!.objectForKey("display_name") as! String
                            self.observerDisplayName.text = observerDisplayNameString
                            //observerNamesArray.addObject(observerDisplayNameString)
                        }
                        else
                        {
                            self.observerDisplayName.text = ""
                        }
                        
                        //print(observerAffiliation)
                        //print(observerDisplayName)
                        if((snapshot.value!.objectForKey("avatar")) != nil)
                        {
                            let observerAvatar = snapshot.value!.objectForKey("avatar")
                            if let observerAvatarUrl  = NSURL(string: observerAvatar as! String),
                                observerAvatarData = NSData(contentsOfURL: observerAvatarUrl)
                            {
                                self.observerAvatarImageView.image = UIImage(data: observerAvatarData)
                                //observerAvatarsArray.addObject(observerAvatar!)
                                self.observerAvatarUrlString = observerAvatar as! String
                            }
                        }
                        else
                        {
                            self.observerAvatarImageView.image = UIImage(named:"user.png")
                            //observerAvatarsArray.addObject(NSBundle.mainBundle().URLForResource("user", withExtension: "png")!)
                            
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
        }
        reachability.whenUnreachable = { reachability in
            // this is called on a background thread, but UI updates must
            // be on the main thread, like this:
            dispatch_async(dispatch_get_main_queue()) {
                
                let alert = UIAlertController(title: "Alert", message:"Please Check your Internet Connection" ,preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    func mapAnnotationClickSubViewtapped(){
        
        let detailedObservationVC = DetailedObservationViewController()
        detailedObservationVC.observerImageUrl = observerAvatarUrlString
        detailedObservationVC.observerDisplayName = observerDisplayName.text!
        detailedObservationVC.observerAffiliation = observerAffiliation.text!
        print(observerAffiliation.text)
        detailedObservationVC.observationImageUrl = observervationUrlString
        detailedObservationVC.observationText = observationTextLabel.text!
        detailedObservationVC.observationCommentsArrayfromExploreView = observationCommentsArray
        detailedObservationVC.observationId = observationId
        detailedObservationVC.pageTitle = ProjectName
        detailedObservationVC.obsupdateddate = observationUpdatedTimestamp
        self.navigationController?.pushViewController(detailedObservationVC, animated: true)
        
    }
    
    
    func displayShareSheet(shareContent:String) {
        // let activityItem: [AnyObject] = [self.imageView.image as! AnyObject]
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: {})
    }
    @IBAction func likesButtonClicked(sender: UIButton) {
        
        sender.selected = true
        mapAnnotationClickSubViewtapped()
        
    }
    @IBAction func commentsButtonClicked(sender: UIButton) {
        
        mapAnnotationClickSubViewtapped()
        
    }
        
        
}
