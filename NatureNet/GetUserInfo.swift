//
//  GetUserInfo.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 10/28/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import Foundation

class GetUserInfo: NSObject
{
    var userDictionary: NSMutableDictionary = [:]
    var userName: String = ""
    var userAvatarURL: NSURL = NSURL()
    var userAffiliation: String = ""
    var errorValue: String = ""
    
    func getUserInformation(observerID: String) ->NSMutableDictionary
    {
        let usersRootRef = FIRDatabase.database().referenceWithPath("users/\(observerID)")
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
                                self.userAffiliation = (snapshot.value!.objectForKey("name") as? String)!
                                
                            }
                            else
                            {
                                self.userAffiliation = "No Affiliation"
                            }
                            self.userDictionary.setObject(self.userAffiliation, forKey: "userAffiliation")
                            
                            
                        }
                        }, withCancelBlock: { error in
                           
                           self.errorValue = error.localizedDescription
                    })
                   
                }
                else
                {
                    self.userAffiliation = "No Affiliation"
                    self.userDictionary.setObject(self.userAffiliation, forKey: "userAffiliation")
                }
                if((snapshot.value!.objectForKey("display_name")) != nil)
                {
                    let observerDisplayNameString = snapshot.value!.objectForKey("display_name") as! String
                    self.userName = observerDisplayNameString
                }
                else
                {
                    self.userName = "No Diaplay Name"
                }
                self.userDictionary.setObject(self.userName, forKey: "userName")
                
                
                if((snapshot.value!.objectForKey("avatar")) != nil)
                {
                    print(snapshot.value!)
                    let observerAvatar = snapshot.value!.objectForKey("avatar")
                    print(observerAvatar)
                    let observerAvatarUrl  = NSURL(string: observerAvatar as! String)
                    if(UIApplication.sharedApplication().canOpenURL(observerAvatarUrl!) == true)
                    {
                        //self.observerAvatarsArray.addObject(NSData(contentsOfURL: observerAvatarUrl!)!)
                        self.userAvatarURL = observerAvatarUrl!
                    }
                    else
                    {
                        let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                        
                        
                        //self.observerAvatarsArray.addObject(NSData(contentsOfURL: tempImageUrl!)!)
                        self.userAvatarURL = tempImageUrl!
                    }
                    //let observerAvatarData = NSData(contentsOfURL: observerAvatarUrl!)
                }
                else
                {
                    let tempImageUrl = NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                    
                    //self.observerAvatarsArray.addObject(NSData(contentsOfURL: tempImageUrl!)!)
                    self.userAvatarURL = tempImageUrl!
                    
                }
                self.userDictionary.setObject(self.userAvatarURL, forKey: "userAvatarURL")

                
            }
            
            }, withCancelBlock: { error in
                self.errorValue = error.localizedDescription
                
        })
        
        return userDictionary
        
    }

}
