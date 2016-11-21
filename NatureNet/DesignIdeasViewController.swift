//
//  DesignIdeasViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/20/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

//should be rewritten using 2d arrays where someArray[0] is challenge and someArray[1] is idea
//for reading and editing simplicity

import UIKit
import Kingfisher
import Firebase

class DesignIdeasViewController: UIViewController ,UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var designIdeasButton: UIButton!
    @IBOutlet weak var designChallengesButton: UIButton!
    
    @IBOutlet weak var designImageView: UIImageView!
    @IBOutlet weak var designLabel: UILabel!
    @IBOutlet weak var designDescrptionLabel: UILabel!
    
    @IBOutlet weak var designTableView: UITableView!
    
    var submitterAffiliation : NSMutableArray = []
    var submitterDisplayName : NSMutableArray = []
    var submitterAvatar : NSMutableArray = []
    var submitterAffiliationDictionary : NSMutableDictionary = [:]
    
    var submitterAffiliation_ideas : NSMutableArray = []
    var submitterDisplayName_ideas : NSMutableArray = []
    var submitterAvatar_ideas : NSMutableArray = []
    var submitterAffiliationDictionary_ideas : NSMutableDictionary = [:]
    
    var submitterAffiliation_challenges : NSMutableArray = []
    var submitterDisplayName_challenges : NSMutableArray = []
    var submitterAvatar_challenges : NSMutableArray = []
    var submitterAffiliationDictionary_challenges : NSMutableDictionary = [:]
    
    
    var contentArray: NSMutableArray = []
    var contentArray_ideas: NSMutableArray = []
    var contentArray_challenges: NSMutableArray = []
    
    var commentsKeysArray: NSArray = []
    
    var commentsCountArray: NSMutableArray = []
    var commentsCountArray_ideas: NSMutableArray = []
    var commentsCountArray_challenges: NSMutableArray = []
    
    var likesCountArray: NSMutableArray = []
    var likesCountArray_ideas: NSMutableArray = []
    var likesCountArray_challenges: NSMutableArray = []
    
    var dislikesCountArray: NSMutableArray = []
    var dislikesCountArray_ideas: NSMutableArray = []
    var dislikesCountArray_challenges: NSMutableArray = []
    
    var statusArray: NSMutableArray = []
    var statusArray_ideas: NSMutableArray = []
    var statusArray_challenges: NSMutableArray = []
    
    var commentsDictArray : NSMutableArray = []
    var commentsDictArray_ideas : NSMutableArray = []
    var commentsDictArray_challenges : NSMutableArray = []
    
    var observationUpdatedTimestampsArray_ideas : NSMutableArray = []
    var observationUpdatedTimestampsArray_challenges : NSMutableArray = []
    var observationUpdatedTimestampsArray : NSMutableArray = []
    var observationUpdatedTimestamp_ideas: NSNumber = 0
    
    let ideasDataRoot = FIRDatabase.database().referenceWithPath("ideas") //Firebase(url: FIREBASE_URL + "ideas")
    let userDataRoot = FIRDatabase.database().referenceWithPath("users") //Firebase(url: FIREBASE_URL + "users")
    let ideaNumber = 10
    
    let CHALLENGE = 0
    let IDEA = 1
    
    var designsCount = 0
    
    
    
    
    //var groupChallengeArray: NSMutableArray = []
    //var groupDesignArray: NSMutableArray = []
    var designIdsArray: NSMutableArray = []
    var designIdsArray_ideas: NSMutableArray = []
    var designIdsArray_challenges: NSMutableArray = []
    
    @IBOutlet weak var recentContributionsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        //self.navigationItem.title="DESIGN IDEAS"
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        designIdeasButton.selected = true
        
        self.navigationItem.title="Design Ideas"
        
        designImageView.image = UIImage(named: "add design ideas.png")
        //designLabel.text = "Design Ideas"
        designDescrptionLabel.text = "Your design ideas can be a new way of using NatureNet in your community, and new mobile technology for learning about sustainability or changes in the environment, or a new feature for the app."
        
        designTableView.delegate = self
        designTableView.dataSource = self
        designTableView.separatorColor = UIColor.clearColor()
        
        designTableView.registerNib(UINib(nibName: "DesignIdeasAndChallengesTableViewCell", bundle: nil), forCellReuseIdentifier: "designIdeasAndChallengesIdentifier")
        
        
        
        //let ideasUrl = NSURL(string: "https://naturenet.firebaseio.com/ideas/-KFSFdMuw_jLEG9ZU-6v.json")
        //let ideasUrl = NSURL(string: DESIGN_URL)
        //removeAllObjectsFromArrays()
        //firebaseForIdeas()
        //updateTable(IDEA)
        //firebaseForChallenges()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        removeAllObjectsFromArrays()
        if(designIdeasButton.selected == true)
        {
            firebaseForIdeas()
            updateTable(IDEA)
        }
        else{
            firebaseForChallenges()
            updateTable(CHALLENGE)
        }
        
        
        
        //updateTable(IDEA)
    }
    
    func removeAllObjectsFromArrays()
    {
        recentContributionsLabel.hidden = true
        contentArray_ideas.removeAllObjects()
        submitterAvatar_ideas.removeAllObjects()
        submitterAffiliation_ideas.removeAllObjects()
        submitterDisplayName_ideas.removeAllObjects()
        observationUpdatedTimestampsArray_ideas.removeAllObjects()
        designIdsArray_ideas.removeAllObjects()
        commentsCountArray_ideas.removeAllObjects()
        likesCountArray_ideas.removeAllObjects()
        dislikesCountArray_ideas.removeAllObjects()
        statusArray_ideas.removeAllObjects()
        commentsDictArray_ideas.removeAllObjects()
        
        contentArray_challenges.removeAllObjects()
        submitterAvatar_challenges.removeAllObjects()
        submitterAffiliation_challenges.removeAllObjects()
        submitterDisplayName_challenges.removeAllObjects()
        observationUpdatedTimestampsArray_challenges.removeAllObjects()
        designIdsArray_challenges.removeAllObjects()
        commentsCountArray_challenges.removeAllObjects()
        likesCountArray_challenges.removeAllObjects()
        dislikesCountArray_challenges.removeAllObjects()
        statusArray_challenges.removeAllObjects()
        commentsDictArray_challenges.removeAllObjects()
        
        submitterAffiliationDictionary_ideas.removeAllObjects()
        submitterAffiliationDictionary_challenges.removeAllObjects()
        
        self.designsCount = 0
    }
    
    @IBAction func getDesignIdeas(sender: UIButton) {
        
        designIdeasButton.selected = true
        designChallengesButton.selected = false
        self.navigationItem.title="Design Ideas"
        
        designImageView.image = UIImage(named: "add design ideas.png")
        //designLabel.text = "DESIGN IDEAS"
        designDescrptionLabel.text = "Your design ideas can be a new way of using NatureNet in your community, and new mobile technology for learning about sustainability or changes in the environment, or a new feature for the app."
        
        
        removeAllObjectsFromArrays()
        firebaseForIdeas()
        updateTable(IDEA)
    }
    
    @IBAction func getDesignChallenges(sender: UIButton) {
        
        designChallengesButton.selected = true
        designIdeasButton.selected = false
        self.navigationItem.title="Design Challenges"
        
        designImageView.image = UIImage(named: "add design challenges.png")
        //designLabel.text = "DESIGN CHALLENGES"
        designDescrptionLabel.text = "A design challenge is a question – for example: How can the NatureNet app collect temperature data?"
        
        removeAllObjectsFromArrays()
        firebaseForChallenges()
        updateTable(CHALLENGE)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return submitterAffiliation.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("designIdeasAndChallengesIdentifier", forIndexPath: indexPath) as! DesignIdeasAndChallengesTableViewCell
        
        cell.contentLabel.text = contentArray[indexPath.row] as? String
        cell.submitterDisplayName.text = submitterDisplayName[indexPath.row] as? String
        cell.submitterAffiliation.text = submitterAffiliationDictionary.objectForKey(submitterAffiliation[indexPath.row]) as? String ?? "No Affiliation"
        
        cell.likesLabel.text = likesCountArray[indexPath.row] as? String
        cell.dislikesLabel.text = dislikesCountArray[indexPath.row] as? String
        cell.commentsLabel.text = commentsCountArray[indexPath.row] as? String
        
        print(submitterAvatar[indexPath.row])
        
        
        let submitterAvatarUrl  = NSURL(string: submitterAvatar[indexPath.row] as! String)
        cell.submitterAvatarView.kf_setImageWithURL(submitterAvatarUrl!, placeholderImage: UIImage(named: "user.png"))
        
        
        if(statusArray[indexPath.row] as! String == "Done")
        {
            cell.statusImageView.image = UIImage(named: "completed.png")
        }
        else
        {
            cell.statusImageView.image = UIImage(named: "4-5 discussing.png")
        }
        
        //        }
        //        else
        //        {
        //            cell.submitterAvatarView.image = UIImage(named: "user.png")
        //        }
        
        
        
        return cell
        
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 130
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let detailedObservationVC = DetailedObservationViewController()
        detailedObservationVC.observerImageUrl = submitterAvatar[indexPath.row] as! String
        detailedObservationVC.observerDisplayName = submitterDisplayName[indexPath.row] as! String
        detailedObservationVC.observerAffiliation =  submitterAffiliationDictionary.objectForKey(submitterAffiliation[indexPath.row]) as? String ?? "No Affiliation"
        detailedObservationVC.pageTitle = self.navigationItem.title!
        //detailedObservationVC.observationImageUrl = NSBundle.mainBundle().URLForResource("default-no-image", withExtension: "png")!.absoluteString
        detailedObservationVC.observationImageUrl = ""
        detailedObservationVC.isfromDesignIdeasView = true
        detailedObservationVC.observationText = contentArray[indexPath.row] as! String
        //        detailedObservationVC.commentsDictfromExploreView = commentsDicttoDetailVC
        //        detailedObservationVC.observationId = obsevationId
        detailedObservationVC.designID = designIdsArray[indexPath.row] as! String
        detailedObservationVC.likesCountFromDesignIdeasView = likesCountArray[indexPath.row].integerValue
        detailedObservationVC.dislikesCountFromDesignIdeasView = dislikesCountArray[indexPath.row].integerValue
        
        detailedObservationVC.obsupdateddate = observationUpdatedTimestampsArray[indexPath.row] as! NSNumber
        
        detailedObservationVC.observationCommentsArrayfromExploreView = commentsDictArray[indexPath.row] as! NSArray
        
        detailedObservationVC.observationId = designIdsArray[indexPath.row] as! String
        self.navigationController?.pushViewController(detailedObservationVC, animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func firebaseForChallenges() -> Void {
        ideasDataRoot.queryLimitedToLast(UInt(ideaNumber)).queryOrderedByChild("group").queryEqualToValue("challenge").observeEventType(.Value, withBlock: { snapshot in
            
            if !(snapshot.value is NSNull)
            {
                let snap = snapshot.value!.allValues as NSArray
                print(snap)
                
                let sortedSnapshot = snap.sort({ $0.objectForKey("updated_at") as! Int > $1.objectForKey("updated_at") as! Int})
                print(snap)
                
                for i in 0 ..< snap.count
                {
                    let designData = sortedSnapshot[i] as! NSDictionary
                    
                    //print(i)
                    
                    print(designData.objectForKey("content"))
                    print(designData.objectForKey("group"))
                    print(designData.objectForKey("id"))
                    
                    
                    let submitter = designData.objectForKey("submitter") as! String
                    //print(submitter)
                    
                    if(designData.objectForKey("group") != nil)
                    {
                            self.designsCount = self.designsCount+1
                     
                            self.parseDesignChallenge(designData)
                            
                            if(designData.objectForKey("content") != nil)
                            {
                                self.contentArray_challenges.addObject(designData.objectForKey("content")!)
                            }
                            else
                            {
                                self.contentArray_challenges.addObject("No Content")
                            }
                            
                            self.parseChallengeUser(submitter)
                            
                        
                        
                    }
                    
                    if i == self.ideaNumber - 1 {
                        // self.finishedDataGathering()
                    }
                    
                }
                
            }
            else
            {
                self.recentContributionsLabel.hidden = false
                self.designsCount = 0
                self.recentContributionsLabel.text = "No Recent Contributions"
                self.recentContributionsLabel.textAlignment = NSTextAlignment.Center
                self.recentContributionsLabel.textColor = UIColor.redColor()
            }
            
            
        })
    }
    
    func firebaseForIdeas() -> Void {
        
        ideasDataRoot.queryLimitedToLast(UInt(ideaNumber)).queryOrderedByChild("group").queryEqualToValue("idea").observeEventType(.Value, withBlock: { snapshot in
            
            if !(snapshot.value is NSNull)
            {
                print("not null")
                
                let snap = snapshot.value!.allValues as NSArray
                print(snap)
                
                let sortedSnapshot = snap.sort({ $0.objectForKey("updated_at") as! Int > $1.objectForKey("updated_at") as! Int})
                print(snap.count)
                
                for i in 0 ..< snap.count
                {
                    let designData = sortedSnapshot[i] as! NSDictionary
                    
                    //print(i)
                    
                    print(designData.objectForKey("content"))
                    print(designData.objectForKey("group"))
                    print(designData.objectForKey("id"))
                    
                    
                    let submitter = designData.objectForKey("submitter") as! String
                    //print(submitter)
                    
                    print(designData.objectForKey("group"))
                    
                    
                    if(designData.objectForKey("group") != nil)
                    {
                        self.designsCount = self.designsCount+1
                        self.parseDesignIdea(designData)
                            
                        if(designData.objectForKey("content") != nil)
                        {
                            self.contentArray_ideas.addObject(designData.objectForKey("content")!)
                        }
                        else
                        {
                            self.contentArray_ideas.addObject("No Content")
                        }
                            
                        self.parseIdeaUser(submitter)
                        
                    }
                    
                    if i == self.ideaNumber - 1 {
                        // self.finishedDataGathering()
                    }
                    
                }
                
            }
            else
            {
                self.recentContributionsLabel.hidden = false
                self.designsCount = 0
                self.recentContributionsLabel.text = "No Recent Contributions"
                self.recentContributionsLabel.textAlignment = NSTextAlignment.Center
                self.recentContributionsLabel.textColor = UIColor.redColor()
            }

            //print("null")
            
        })
    }
    
    func parseDesignChallenge(challenge: NSDictionary) -> Void {
        
        let designId = challenge.objectForKey("id") as? String
        if(designId != nil)
        {
            self.designIdsArray_challenges.addObject(designId!)
        }
        
        if(challenge.objectForKey("comments") != nil)
        {
            let commentsDictionary = challenge.objectForKey("comments") as! NSDictionary
            print(commentsDictionary.allKeys)
            
            self.commentsKeysArray = commentsDictionary.allKeys as NSArray
            print(self.commentsKeysArray)
            
            self.commentsDictArray_challenges.addObject(self.commentsKeysArray)
            
            print(self.commentsDictArray_challenges)
            
            self.commentsCountArray_challenges.addObject("\(self.commentsKeysArray.count)")
            
            
            print(challenge.objectForKey("id"))
        }
        else
        {
            self.commentsCountArray_challenges.addObject("0")
            
            let tempcomments = NSArray()
            self.commentsDictArray_challenges.addObject(tempcomments)
        }
        
        if(challenge.objectForKey("status") != nil)
        {
            let status = challenge.objectForKey("status") as? String
            self.statusArray_challenges.addObject(status!)
        }
        else
        {
            self.statusArray_challenges.addObject("")
        }
        
        if(challenge.objectForKey("updated_at") != nil)
        {
            let obsUpdatedAt = challenge.objectForKey("updated_at") as! NSNumber
            self.observationUpdatedTimestampsArray_challenges.addObject(obsUpdatedAt)
        }
        else
        {
            self.observationUpdatedTimestampsArray_challenges.addObject(0)
        }
        
        if(challenge.objectForKey("likes") != nil)
        {
            let likesDictionary = challenge.objectForKey("likes") as! NSDictionary
            print(likesDictionary.allValues)
            
            let likesArray = likesDictionary.allValues as NSArray
            print(likesArray)
            
            var likesCount: Int = 0
            var dislikesCount: Int = 0
            
            for l in 0 ..< likesArray.count
            {
                if(likesArray[l] as! NSObject == 1)
                {
                    likesCount += 1
                }
                else
                {
                    dislikesCount += 1
                }
            }
            print(likesCount)
            print(dislikesCount)
            
            self.likesCountArray_challenges.addObject("\(likesCount)")
            self.dislikesCountArray_challenges.addObject("\(dislikesCount)")
            
        }
        else
        {
            self.likesCountArray_challenges.addObject("0")
            self.dislikesCountArray_challenges.addObject("0")
        }
    }
    
    func parseDesignIdea(idea: NSDictionary) -> Void {
        
        //print(idea.count)
        let designId = idea.objectForKey("id") as? String
        if(designId != nil)
        {
            self.designIdsArray_ideas.addObject(designId!)
        }
        
        if(idea.objectForKey("comments") != nil)
        {
            let commentsDictionary = idea.objectForKey("comments") as! NSDictionary
            print(commentsDictionary.allKeys)
            
            self.commentsKeysArray = commentsDictionary.allKeys as NSArray
            print(self.commentsKeysArray)
            
            self.commentsDictArray_ideas.addObject(self.commentsKeysArray)
            
            print(self.commentsDictArray_ideas)
            
            self.commentsCountArray_ideas.addObject("\(self.commentsKeysArray.count)")
            
            
            print(idea.objectForKey("id"))
        }
        else
        {
            self.commentsCountArray_ideas.addObject("0")
            
            let tempcomments = NSArray()
            self.commentsDictArray_ideas.addObject(tempcomments)
        }
        
        if(idea.objectForKey("status") != nil)
        {
            let status = idea.objectForKey("status") as? String
            self.statusArray_ideas.addObject(status!)
        }
        else
        {
            self.statusArray_ideas.addObject("")
        }
        
        if(idea.objectForKey("updated_at") != nil)
        {
            let obsUpdatedAt = idea.objectForKey("updated_at") as! NSNumber
            self.observationUpdatedTimestampsArray_ideas.addObject(obsUpdatedAt)
        }
        else
        {
            self.observationUpdatedTimestampsArray_ideas.addObject(0)
        }
        
        if(idea.objectForKey("likes") != nil)
        {
            let likesDictionary = idea.objectForKey("likes") as! NSDictionary
            print(likesDictionary.allValues)
            
            let likesArray = likesDictionary.allValues as NSArray
            print(likesArray)
            
            var likesCount: Int = 0
            var dislikesCount: Int = 0
            
            for l in 0 ..< likesArray.count
            {
                if(likesArray[l] as! NSObject == 1)
                {
                    likesCount += 1
                }
                else
                {
                    dislikesCount += 1
                }
            }
            print(likesCount)
            print(dislikesCount)
            
            self.likesCountArray_ideas.addObject("\(likesCount)")
            self.dislikesCountArray_ideas.addObject("\(dislikesCount)")
            
        }
        else
        {
            self.likesCountArray_ideas.addObject("0")
            self.dislikesCountArray_ideas.addObject("0")
        }
    }
    
    func parseChallengeUser(id: String) -> Void {
        
        if(id != "")
        {
            userDataRoot.queryOrderedByChild("id").queryEqualToValue(id).observeEventType(.Value, withBlock: { snapshot in
                if !(snapshot.value is NSNull) {
                    
                    let submitterInfo = snapshot.value!.allValues[0]
                    
                    if((submitterInfo.objectForKey("affiliation")) != nil)
                    {
                        let submiterAffiliationString = submitterInfo.objectForKey("affiliation") as! String
                        
                        self.getActivityNames(submiterAffiliationString, ideaOrChallenge: false)
                        
                        self.submitterAffiliation_challenges.addObject(submiterAffiliationString)
                        
                    }
                    else
                    {
                        self.submitterAffiliation_challenges.addObject("No Affiliation")
                    }
                    
                    if((submitterInfo.objectForKey("display_name")) != nil)
                    {
                        let submitterDisplayNameString = submitterInfo.objectForKey("display_name") as! String
                        
                        self.submitterDisplayName_challenges.addObject(submitterDisplayNameString)
                    }
                    else
                    {
                        self.submitterDisplayName_challenges.addObject("")
                    }
                    
                    //print(observerAffiliation)
                    //print(observerDisplayName)
                    if((submitterInfo.objectForKey("avatar")) != nil)
                    {
                        let submitterUrlString = submitterInfo.objectForKey("avatar") as! String
                        print(submitterUrlString)
                        let newsubmitterUrlString = submitterUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        
                        self.submitterAvatar_challenges.addObject(newsubmitterUrlString)
                    }
                    else
                    {
                        let tempImageUrl = ""//NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                        self.submitterAvatar_challenges.addObject(tempImageUrl)
                        
                    }
                    
                }
                
                self.recentContributionsLabel.hidden = true
                self.updateTable(self.CHALLENGE)
                
                
            })
            
            
        }
        
    }
    
    func getActivityNames(userAffiliation:String, ideaOrChallenge:Bool)
    {
        let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/"+userAffiliation)
        //Firebase(url:FIREBASE_URL + "sites/"+aff!)
        sitesRootRef.observeEventType(.Value, withBlock: { snapshot in
            
            
            print(sitesRootRef)
            print(snapshot.value)
            
            if !(snapshot.value is NSNull)
            {
                
                
                print(snapshot.value!.objectForKey("name"))
                if(snapshot.value!.objectForKey("name") != nil)
                {
                    //self.observerAffiliationLabel.text = snapshot.value!.objectForKey("name") as? String
                    if(ideaOrChallenge == true)
                    {
                    self.submitterAffiliationDictionary_ideas.setValue(snapshot.value!.objectForKey("name") as! String, forKey: userAffiliation)
                        self.updateTable(self.IDEA)
                    }
                    else{
                        
                        self.submitterAffiliationDictionary_challenges.setValue(snapshot.value!.objectForKey("name") as! String, forKey: userAffiliation)
                        self.updateTable(self.CHALLENGE)
                    }
                    
                }
                
                
                
            }
            self.recentContributionsLabel.hidden = false
            
            }, withCancelBlock: { error in
                print(error.description)
                let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                
        })

    }
    
    func parseIdeaUser(id: String) -> Void {
        //let greeting = "Hello, " + id + "!"
        //return greeting
        
        
        if(id != "")
        {
            userDataRoot.queryOrderedByChild("id").queryEqualToValue(id).observeEventType(.Value, withBlock: { snapshot in
                if !(snapshot.value is NSNull) {
                    
                    let submitterInfo = snapshot.value!.allValues[0]
                    
                    if((submitterInfo.objectForKey("affiliation")) != nil)
                    {
                        let submiterAffiliationString = submitterInfo.objectForKey("affiliation") as! String
                        
                        self.getActivityNames(submiterAffiliationString, ideaOrChallenge: true)
                        
                        self.submitterAffiliation_ideas.addObject(submiterAffiliationString)
                        
                    }
                    else
                    {
                        self.submitterAffiliation_ideas.addObject("No Affiliation")
                    }
                    
                    if((submitterInfo.objectForKey("display_name")) != nil)
                    {
                        let submitterDisplayNameString = submitterInfo.objectForKey("display_name") as! String
                        
                        self.submitterDisplayName_ideas.addObject(submitterDisplayNameString)
                    }
                    else
                    {
                        self.submitterDisplayName_ideas.addObject("")
                    }
                    
                    //print(observerAffiliation)
                    //print(observerDisplayName)
                    if((submitterInfo.objectForKey("avatar")) != nil)
                    {
                        let submitterUrlString = submitterInfo.objectForKey("avatar") as! String
                        print(submitterUrlString)
                        let newsubmitterUrlString = submitterUrlString.stringByReplacingOccurrencesOfString("upload", withString: "upload/t_ios-thumbnail", options: NSStringCompareOptions.LiteralSearch, range: nil)
                        
                        self.submitterAvatar_ideas.addObject(newsubmitterUrlString)
                    }
                    else
                    {
                        let tempImageUrl = ""//NSBundle.mainBundle().URLForResource("user", withExtension: "png")
                        self.submitterAvatar_ideas.addObject(tempImageUrl)
                        
                    }
                    
                   
                }
                
                self.recentContributionsLabel.hidden = true
                 self.updateTable(self.IDEA)
                
                
            })
            
            
        }
    }
    
    func updateTable(designType: Int) -> Void {
        
        
        
        if(designType == CHALLENGE) {
            contentArray = contentArray_challenges
            submitterAvatar = submitterAvatar_challenges
            submitterAffiliation = submitterAffiliation_challenges
            submitterAffiliationDictionary = submitterAffiliationDictionary_challenges
            submitterDisplayName = submitterDisplayName_challenges
            observationUpdatedTimestampsArray = observationUpdatedTimestampsArray_challenges
            designIdsArray = designIdsArray_challenges
            commentsCountArray = commentsCountArray_challenges
            likesCountArray = likesCountArray_challenges
            dislikesCountArray = dislikesCountArray_challenges
            statusArray = statusArray_challenges
            commentsDictArray = commentsDictArray_challenges
            
        } else {
            contentArray = contentArray_ideas
            submitterAvatar = submitterAvatar_ideas
            submitterAffiliation = submitterAffiliation_ideas
            submitterAffiliationDictionary = submitterAffiliationDictionary_ideas
            print(submitterAffiliationDictionary.count)
            submitterDisplayName = submitterDisplayName_ideas
            
            observationUpdatedTimestampsArray = observationUpdatedTimestampsArray_ideas
            
            print(contentArray)
            print(submitterDisplayName)
            
            
            designIdsArray = designIdsArray_ideas
            commentsCountArray = commentsCountArray_ideas
            likesCountArray = likesCountArray_ideas
            dislikesCountArray = dislikesCountArray_ideas
            statusArray = statusArray_ideas
            commentsDictArray = commentsDictArray_ideas
            
        }
        
        
        
        
        print(commentsCountArray)
        print(likesCountArray)
        print(dislikesCountArray)
        print(submitterAffiliation.count)
        
        self.designTableView.reloadData()
        
        print(self.designsCount)
        
        
        if(self.designsCount == 0)
        {
            self.recentContributionsLabel.text = "No Recent Contributions"
            self.recentContributionsLabel.textAlignment = NSTextAlignment.Center
            self.recentContributionsLabel.textColor = UIColor.redColor()
        }
        else
        {
            self.recentContributionsLabel.text = "Recent Contributions"
            self.recentContributionsLabel.textAlignment = NSTextAlignment.Left
            self.recentContributionsLabel.textColor = UIColor.blackColor()
            
        }
        
    }
    
}