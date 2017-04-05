//
//  AppDelegate.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/17/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var viewController: UIViewController?
    var frontNavController : UINavigationController? = nil
    var laterArray : [ObservationForLater] = []

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let homeVC = HomeViewController()
        let rearVC = RearViewController()
        
        frontNavController = UINavigationController(rootViewController: homeVC)
        let rearNavController = UINavigationController(rootViewController: rearVC)
        
        let revealVC: SWRevealViewController = SWRevealViewController(rearViewController: rearNavController, frontViewController: frontNavController)
        self.viewController = revealVC
        
        self.window?.rootViewController = self.viewController
        self.window?.makeKeyAndVisible()
        
        //Initializing Kingfisher Library for image caching
        let cache = KingfisherManager.sharedManager.cache
        cache.maxDiskCacheSize = 10 * 1024 * 1024
        
        //Configuring Firebase
        let filePath = NSBundle.mainBundle().pathForResource("GoogleService-Info", ofType: "plist")
        let options = FIROptions(contentsOfFile: filePath)
        FIRApp.configureWithOptions(options)
        
        //Enabling Firebase persistent data
        FIRDatabase.database().persistenceEnabled = true
        
        //these cannot be purged from the cache
        FIRDatabase.database().referenceWithPath("sites/").keepSynced(true)
        FIRDatabase.database().referenceWithPath("activities/").keepSynced(true)
        
        //Checking Network Connection
        let connectedRef = FIRDatabase.database().referenceWithPath(".info/connected")
        
        //unbundle observations for later from user defaults
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var laterData : NSData
        if userDefaults.objectForKey("observationsForLater") != nil {
            laterData = (NSUserDefaults.standardUserDefaults().objectForKey("observationsForLater") as? NSData)!
            
            laterArray = (NSKeyedUnarchiver.unarchiveObjectWithData(laterData) as? [ObservationForLater])!
        }
        
        //listener for whether we are connected to firebase (and thus likely internet)
        connectedRef.observeEventType(.Value, withBlock: { snapshot in
            if let connected = snapshot.value as? Bool where connected {
                print("Connected")
                //upload any not uploaded observations
                //for all of the things
                for observation in self.laterArray {
                    observation.upload()
                }
            } else {
                print("Not connected")
            }
        })
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil))
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //clean up the upload later queue
        let userDefaults = NSUserDefaults.standardUserDefaults()
        print(laterArray.count)
        
        for (i, _) in laterArray.enumerate().reverse() {
            if laterArray[i].toBeRemoved {
                laterArray.removeAtIndex(i)
            }
        }
        
        //put later array into user defaults for storage
        let laterData = NSKeyedArchiver.archivedDataWithRootObject(laterArray)
        userDefaults.setObject(laterData, forKey: "observationsForLater")
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        application.applicationIconBadgeNumber = 0
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.calendarDayDidChange(_:)), name:NSCalendarDayChangedNotification, object:nil)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.calendarDayDidChange(_:)), name:NSCalendarDayChangedNotification, object:nil)
        //checkCurrentTimeIfNotLogOutTheUser(date,cal: cal)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(AppDelegate.calendarDayDidChange(_:)), name:NSCalendarDayChangedNotification, object:nil)
    }
    
}

