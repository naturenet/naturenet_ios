//
//  DetailedObservationViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 3/20/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher


class DetailedObservationViewController: UIViewController, UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIScrollViewDelegate{

    @IBOutlet weak var detailObsScrollView: UIScrollView!
    @IBOutlet var detailedObsView: UIView!

    @IBOutlet var likedislikeViewHeight: NSLayoutConstraint!

    @IBOutlet weak var likeButtonLeftToCommentBoxWidth: NSLayoutConstraint!
    @IBOutlet weak var observationImageView: UIImageView!

    @IBOutlet var observationImageViewHeight: NSLayoutConstraint!

    @IBOutlet var detObsViewHeight: NSLayoutConstraint!

    @IBOutlet weak var obsTextLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var observationPostedDateLabel: UILabel!
    var obsupdateddate: NSNumber = 0
    @IBOutlet weak var observationTextLabel: UILabel!
    @IBOutlet weak var observerAffiliationLabel: UILabel!
    @IBOutlet weak var observerDisplayNameLabel: UILabel!
    @IBOutlet weak var observerAvatarImageView: UIImageView!
    var observerImageUrl : String = ""
    var observerDisplayName : String = ""
    var observerAffiliation : String = ""
    var observationImageUrl : String = ""
    var observationText : String = ""
    var isfromMapView : Bool = false
    var isfromDesignIdeasView : Bool = false
    var designID: String = ""
    var isObservationLiked : Bool = false

    var observationId : String = ""
    var commentsDictfromExploreView : NSDictionary = [:]
    var observationCommentsArrayfromExploreView : NSArray = []

    var pageTitle: String = ""

    var commentContext : String = ""

    var likesCount: Int = 0
    var dislikesCount: Int = 0

    @IBOutlet weak var likeButtonForDesign: UIButton!

    @IBOutlet weak var dislikeButtonForDesign: UIButton!

    @IBOutlet weak var likedislikeView: UIView!

    @IBOutlet weak var likesCountLabel: UILabel!

    @IBOutlet weak var dislikesCountLabel: UILabel!

    var likesCountFromDesignIdeasView : Int = 0
    var dislikesCountFromDesignIdeasView : Int = 0
    @IBOutlet weak var likeButtonBesidesCommentBox: UIButton!

    var isUserLiked : Bool = false
    var isUserDisLiked : Bool = false

    @IBOutlet weak var commentTF: UITextField!

    @IBOutlet weak var commentViewBottomContraint: NSLayoutConstraint!
    var detailed_commentsDictArray : NSMutableArray = []
    var detailed_commentsCount: Int = 0
    var commentsArray = [Comment]()

    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentView: UIView!
    
    var userAffiliationDictionary:NSMutableDictionary = [:]
    
    @IBOutlet weak var activityIndicator_comment: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print(observationId)
        self.navigationItem.title=pageTitle

        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]

        self.view.bringSubviewToFront(commentView)
        
        detailedObsView.bringSubviewToFront(commentView)
        detailedObsView.frame = CGRectMake(0,64, detailObsScrollView.frame.size.width, detailedObsView.frame.size.height)
        detailObsScrollView.showsHorizontalScrollIndicator = false
        detailObsScrollView.delegate = self
        self.view.addSubview(detailObsScrollView)
        detailObsScrollView.addSubview(detailedObsView)

        print(UIScreen.mainScreen().bounds)
        print(detailObsScrollView.frame)
        print(detailedObsView.frame)
        print(observationId)
        print(observerImageUrl)
        print(observerDisplayName)
        print(observerAffiliation)
        print(observationImageUrl)
        print(commentsDictfromExploreView)
        print(observationCommentsArrayfromExploreView)

        observationPostedDateLabel.text = ""

        if(obsupdateddate != 0)
        {
            let date = NSDate(timeIntervalSince1970:Double(obsupdateddate)/1000)
            print(date)
            let formatter = NSDateFormatter()
            formatter.locale = NSLocale.currentLocale()
            formatter.timeZone = NSTimeZone.localTimeZone()
            formatter.dateStyle = NSDateFormatterStyle.FullStyle
            formatter.timeStyle = .ShortStyle
            let dateString = formatter.stringFromDate(date)
            print(dateString)
            observationPostedDateLabel.text = dateString
        }
        else
        {
            observationPostedDateLabel.text = ""
        }

        commentsTableView.delegate = self
        commentsTableView.dataSource = self
        commentsTableView.separatorColor = UIColor.clearColor()
        commentsTableView.registerNib(UINib(nibName: "CommentsTableViewCell", bundle: nil), forCellReuseIdentifier: "CommentCell")

        if (isfromDesignIdeasView)
        {
            likedislikeViewHeight.constant = 40
            likedislikeView.hidden = false
            likeButtonBesidesCommentBox.hidden = true
            likeButtonLeftToCommentBoxWidth.constant = 0
            likesCountLabel.text = "\(likesCountFromDesignIdeasView)"
            dislikesCountLabel.text = "\(dislikesCountFromDesignIdeasView)"
            commentContext = "ideas"
            getUpdatedlikestoDesignIdeas()
        }
        else
        {
            commentContext = "observations"
            getLikesToObservations()
            likedislikeViewHeight.constant = 0
            likedislikeView.hidden = true
        }
        
        activityIndicator_comment.startAnimating()
        let observerAvatarUrl  = NSURL(string: observerImageUrl )
        observerAvatarImageView?.kf_setImageWithURL(observerAvatarUrl!, placeholderImage: UIImage(named: "user.png"), optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) in
            
            self.activityIndicator_comment.stopAnimating()
        })
        
        print(observationImageUrl)
        print(observationImageUrl)

        if(observationImageUrl != "")
        {
            let obsImageUrl  = NSURL(string: observationImageUrl )
            observationImageView.kf_setImageWithURL(obsImageUrl! , placeholderImage: UIImage(named: "default-no-image.png"))
        }
        else
        {

            observationImageViewHeight.constant = 0

            func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
                let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
                label.numberOfLines = 0
                label.lineBreakMode = observationTextLabel.lineBreakMode
                label.font = font
                label.text = text

                label.sizeToFit()
                return label.frame.height
            }

            let font = UIFont(name: observationTextLabel.font.fontName, size: 12.0)
            let height = heightForView(observationText, font: font!, width: observationTextLabel.frame.size.width)
            obsTextLabelHeight.constant = height

            print(height)
            print(observationTextLabel.font.fontName)
            print(observationTextLabel.frame.origin.y)
            detObsViewHeight.constant = observationTextLabel.frame.origin.y+height+8

        }
        
        observerDisplayNameLabel.text = observerDisplayName
        observerAffiliationLabel.text = observerAffiliation
        observationTextLabel.text = observationText
        observationTextLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showMoreDescritionText)))
        observationTextLabel.userInteractionEnabled = true
        detailObsScrollView.contentSize=CGSizeMake(detailedObsView.frame.size.width, detailedObsView.frame.size.height+observationTextLabel.frame.size.height)

        print(detailObsScrollView.contentSize)

        observerAvatarImageView.layer.cornerRadius = 30.0
        observerAvatarImageView.clipsToBounds = true
        commentTF.delegate = self
        commentViewBottomContraint.constant = 0.0
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(DetailedObservationViewController.viewTapped)))
        self.view.userInteractionEnabled = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailedObservationViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(DetailedObservationViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);

        getCommentsDetails(observationCommentsArrayfromExploreView)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }

    func showMoreDescritionText()
    {
        let alertController = UIAlertController(title: "Description", message: observationText, preferredStyle: UIAlertControllerStyle.Alert)
        let subview = alertController.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        let alertMessage = alertContentView.subviews.first!.subviews.first!.subviews.first!.subviews[1] as! UILabel
        alertMessage.textAlignment = NSTextAlignment.Left
        alertContentView.backgroundColor = UIColor.whiteColor()
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool // called when 'return' key pressed. return NO to ignore.
    {
        textField.resignFirstResponder()
        if (textField.returnKeyType == UIReturnKeyType.Send) {
            // submit action here
            //return true;
            postCommentOnSendButton()
        }
        return true;
    }

    func viewTapped()
    {
        commentTF.resignFirstResponder()
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool // return NO to disallow editing.
    {
        return true
    }

    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            commentViewBottomContraint.constant = keyboardSize.size.height
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        commentViewBottomContraint.constant = 0.0
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }

    func getLikesToObservations()
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var userID = String()
        
        if(userDefaults.objectForKey("userID") != nil)
        {
            userID = (userDefaults.objectForKey("userID") as? String)!
        }
        
        if(userID != "" || self.observationId != "")
        {
            let observationRootRef = FIRDatabase.database().referenceWithPath("observations/" + String(self.observationId)) //Firebase(url:POST_IDEAS_URL + observationId)
            observationRootRef.observeEventType(.Value, withBlock: { snapshot in

                print(observationRootRef)
                print(snapshot.value)

                if !(snapshot.value is NSNull)
                {

                    if(snapshot.value!.objectForKey("likes") != nil)
                    {
                        let likesDictionary = snapshot.value!.objectForKey("likes") as! NSDictionary
                        print(likesDictionary.allValues)

                        let likesArray = likesDictionary.allValues as NSArray
                        print(likesArray)

                        let userKeys = likesDictionary.allKeys as NSArray
                        print(userKeys)

                        if((userDefaults.stringForKey("isSignedIn")) == "true")
                        {
                            if(userKeys.containsObject(userID))
                            {
                                if(likesDictionary.objectForKey(userID) as! NSObject == 1)
                                {
                                    self.isObservationLiked = true
                                    self.likeButtonBesidesCommentBox.selected = true
                                    self.likeButtonBesidesCommentBox.userInteractionEnabled = false

                                }
                                else
                                {
                                    self.isObservationLiked = false
                                    self.likeButtonBesidesCommentBox.selected = false
                                    self.likeButtonBesidesCommentBox.userInteractionEnabled = true
                                }
                            }
                            else
                            {
                                self.isObservationLiked = false
                                self.likeButtonBesidesCommentBox.selected = false
                                self.likeButtonBesidesCommentBox.userInteractionEnabled = true
                            }

                        }
                        else
                        {
                            self.isObservationLiked = false
                            self.likeButtonBesidesCommentBox.selected = false
                            self.likeButtonBesidesCommentBox.userInteractionEnabled = false
                        }
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

    func getCommentsDetails(obsCommentsArray: NSArray)
    {
        print(obsCommentsArray)
        let myRootRef = FIRDatabase.database().referenceWithPath("comments/")
        myRootRef.queryOrderedByChild("parent").queryEqualToValue("\(self.observationId)").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            print(myRootRef)
            print(self.observationId)
            print(snapshot.value)
            
            if !(snapshot.value is NSNull)
            {
                for j in 0 ..< snapshot.value!.allValues.count
                {
                    var text = "No Comment Text"
                    
                    let snap = snapshot.value!.allValues as NSArray
                    let commentDictionary = snap[j] as! NSDictionary
                    
                    if(commentDictionary["comment"] != nil)
                    {
                        text = commentDictionary["comment"] as! String
                    }
                    
                    let commenter = commentDictionary["commenter"] as! String
                    let timestamp = commentDictionary["updated_at"] as! Int
                    let comment = Comment(commenter: commenter, commentText: text, timestamp: timestamp)
                    self.commentsArray.append(comment)
                }
            }
            
            //sort
            self.commentsArray.sortInPlace({$0.timestamp < $1.timestamp})
            self.commentsTableView.reloadData()
            
        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }

    func getUpdatedComments()
    {
        let ref = FIRDatabase.database()
        var commentsRootRef = FIRDatabase.database().reference()
        
        if(isfromDesignIdeasView == true)
        {
            commentsRootRef = ref.referenceWithPath("ideas/\(self.observationId)")
            
        }
        else
        {
            commentsRootRef = ref.referenceWithPath("observations/" + String(observationId))
        }
        
        commentsRootRef.observeEventType(.Value, withBlock: { snapshot in

            print(commentsRootRef)
            print(snapshot.value)
            
            self.commentsArray.removeAll()
            self.detailed_commentsDictArray.removeAllObjects()

            if !(snapshot.value is NSNull)
            {
                if(snapshot.value!.objectForKey("comments") != nil)
                {
                    let tempcomments = snapshot.value!.objectForKey("comments") as! NSDictionary
                    print(tempcomments)
                    let commentsKeysArray = tempcomments.allKeys as NSArray
                    self.detailed_commentsDictArray.addObject(commentsKeysArray)


                    self.detailed_commentsCount = commentsKeysArray.count
                }
                else
                {
                    let tempcomments = NSArray()
                    self.detailed_commentsDictArray.addObject(tempcomments)

                    self.detailed_commentsCount = 0
                }

                print(self.observationCommentsArrayfromExploreView)
                print(self.detailed_commentsDictArray[0])
                print(self.detailed_commentsCount)

                self.getCommentsDetails(self.detailed_commentsDictArray[0] as! NSArray)
            }
        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)

        })
    }

    func getUpdatedlikestoDesignIdeas()
    {
        let observationRootRef = FIRDatabase.database().referenceWithPath("ideas/" + String(observationId))

        observationRootRef.observeEventType(.Value, withBlock: { snapshot in

            self.likesCount = 0
            self.dislikesCount = 0

            print(observationRootRef)
            print(snapshot.value)

            if !(snapshot.value is NSNull)
            {

                if(snapshot.value!.objectForKey("likes") != nil)
                {
                    let likesDictionary = snapshot.value!.objectForKey("likes") as! NSDictionary
                    print(likesDictionary.allValues)

                    let likesArray = likesDictionary.allValues as NSArray
                    print(likesArray)

                    let userKeys = likesDictionary.allKeys as NSArray
                    print(userKeys)

                    let userDefaults = NSUserDefaults.standardUserDefaults()
                    var userID = String()
                    
                    if(userDefaults.objectForKey("userID") != nil)
                    {
                        userID = (userDefaults.objectForKey("userID") as? String)!
                    }

                    if((userDefaults.stringForKey("isSignedIn")) == "true")
                    {
                        if(userKeys.containsObject(userID))
                        {
                            if(likesDictionary.objectForKey(userID) as! NSObject == 1)
                            {
                                self.isUserLiked = true
                                self.isUserDisLiked = false
                                self.likeButtonForDesign.selected = true
                                self.dislikeButtonForDesign.selected = false

                                self.likeButtonForDesign.userInteractionEnabled = false
                                self.dislikeButtonForDesign.userInteractionEnabled = true
                            }
                            else
                            {
                                self.isUserDisLiked = true
                                self.isUserLiked = false

                                self.likeButtonForDesign.selected = false
                                self.dislikeButtonForDesign.selected = true

                                self.likeButtonForDesign.userInteractionEnabled = true
                                self.dislikeButtonForDesign.userInteractionEnabled = false
                            }
                        }
                        else
                        {
                            self.likeButtonForDesign.selected = false
                            self.dislikeButtonForDesign.selected = false

                            self.likeButtonForDesign.userInteractionEnabled = true
                            self.dislikeButtonForDesign.userInteractionEnabled = true

                        }

                    }
                    else
                    {

                        self.likeButtonForDesign.selected = false
                        self.dislikeButtonForDesign.selected = false

                        self.likeButtonForDesign.userInteractionEnabled = false
                        self.dislikeButtonForDesign.userInteractionEnabled = false
                    }

                    for l in 0 ..< likesArray.count
                    {
                        if(likesArray[l] as! NSObject == 1)
                        {
                            self.likesCount += 1
                        }
                        else
                        {
                            self.dislikesCount += 1
                        }
                    }
                    print(self.likesCount)
                    print(self.dislikesCount)

                }
                else
                {
                    self.likesCount = 0
                    self.dislikesCount = 0
                }

                self.likesCountLabel.text = "\(self.likesCount)"
                self.dislikesCountLabel.text = "\(self.dislikesCount)"

                print(self.likesCount)
                print(self.dislikesCount)
            }



        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    func getActivityNames(userAffiliationKey: String)
    {
        
        let sitesRootRef = FIRDatabase.database().referenceWithPath("sites/"+userAffiliationKey)
        
        sitesRootRef.observeEventType(.Value, withBlock: { snapshot in
            
            print(userAffiliationKey)
            print(sitesRootRef)
            print(snapshot.value)
            
            if !(snapshot.value is NSNull)
            {
                print(snapshot.value!.objectForKey("name"))
                
                if(snapshot.value!.objectForKey("name") != nil)
                {
                    let str = snapshot.value!.objectForKey("name") as! String
                    print(str)
                    self.userAffiliationDictionary.setValue(str, forKey: userAffiliationKey)
                }
            }
            
            self.commentsTableView.reloadData()
        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }

    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("CommentCell", forIndexPath: indexPath) as! CommentsTableViewCell
        cell.commentLabel.text = commentsArray[indexPath.row].commentText as? String
        let geoActivitiesRootRef = FIRDatabase.database().referenceWithPath("users/" + String(self.commentsArray[indexPath.row].commenter))
        
        geoActivitiesRootRef.observeEventType(.Value, withBlock: { snapshot in
            print(geoActivitiesRootRef)
            

            if !(snapshot.value is NSNull)
            {
                if((snapshot.value!.objectForKey("affiliation")) != nil)
                {
                    let observerAffiliationString = snapshot.value!.objectForKey("affiliation") as! String
                    self.getActivityNames(observerAffiliationString)
                    cell.commentorDateLabel.text = self.userAffiliationDictionary.objectForKey(observerAffiliationString) as? String ?? "No Affiliation"
                }
                else
                {
                    cell.commentorDateLabel.text = "No Affiliation"
                }

                if((snapshot.value!.objectForKey("display_name")) != nil)
                {
                    let observerDisplayNameString = snapshot.value!.objectForKey("display_name") as! String
                    cell.commentorNameLabel.text = observerDisplayNameString
                }
                else
                {
                    cell.commentorNameLabel.text = ""
                }
                
                if((snapshot.value!.objectForKey("avatar")) != nil)
                {
                    let observerAvatar = snapshot.value!.objectForKey("avatar")
                    let observerAvatarUrl  = NSURL(string: observerAvatar as! String)
                    cell.commentorAvatarImageView.kf_setImageWithURL(observerAvatarUrl!, placeholderImage: UIImage(named: "user.png"))
                }
                else
                {
                    cell.commentorAvatarImageView.image = UIImage(named:"user.png")
                }
            }
        }, withCancelBlock: { error in
            print(error.description)
            let alert = UIAlertController(title: "Alert", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 90
    }

    func decodeString(stringToBeDecoded: String) -> String
    {
        //Encoding and Decoding String
        let base64Decoded = NSData(base64EncodedString: stringToBeDecoded, options:   NSDataBase64DecodingOptions(rawValue: 0))
            .map({ NSString(data: $0, encoding: NSUTF8StringEncoding) })

        // Convert back to a string
        print("Decoded:  \(base64Decoded!)")
        return base64Decoded as! String

    }

    @IBAction func postComment(sender: UIButton) {
        postCommentOnSendButton()
    }
    
    func postCommentOnSendButton()
    {
        if(commentTF.text != "")
        {
            activityIndicator_comment.startAnimating()
            let userDefaults = NSUserDefaults.standardUserDefaults()
            var userID = String()
            
            if(userDefaults.objectForKey("userID") != nil)
            {
                userID = (userDefaults.objectForKey("userID") as? String)!
            }
            
            print(userID)
            var email = ""
            var password = ""
            
            if(userDefaults.objectForKey("email") as? String != nil || userDefaults.objectForKey("password") as? String != nil)
            {
                email = decodeString((userDefaults.objectForKey("email") as? String)!)
                password = decodeString((userDefaults.objectForKey("password") as? String)!)
            }
            
            print(email)
            print(password)
            
            let refUser = FIRAuth.auth()
            refUser!.signInWithEmail(email, password: password, completion: { authData, error in
                if error != nil {
                    print("\(error)")
                    var alert = UIAlertController()
                    
                    if(email == "")
                    {
                        alert = UIAlertController(title: "Alert", message:"Please Login to continue" ,preferredStyle: UIAlertControllerStyle.Alert)
                    }
                    else
                    {
                        alert = UIAlertController(title: "Alert", message:error?.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                    }
                    
                    let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                    alert.addAction(action)
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.activityIndicator_comment.stopAnimating()
                }
                else
                {
                    let commentsRef = FIRDatabase.database().referenceWithPath("comments/")
                    let autoID = commentsRef.childByAutoId()
                    
                    print(autoID.key)
                    
                    let commentData = [
                        "id": autoID.key as AnyObject,
                        "context": self.commentContext as AnyObject,
                        "commenter": userID as AnyObject,
                        "comment": self.commentTF.text as! AnyObject,
                        "parent": self.observationId as AnyObject,
                        "source": "ios",
                        "created_at": FIRServerValue.timestamp(),
                        "updated_at": FIRServerValue.timestamp()
                    ]
                    autoID.setValue(commentData)
                    
                    let ref = FIRDatabase.database()
                    var parentRef = FIRDatabase.database().reference()
                    
                    if(self.isfromDesignIdeasView == true)
                    {
                        parentRef = ref.referenceWithPath("ideas/\(self.observationId)/comments")
                    }
                    else
                    {
                        parentRef = ref.referenceWithPath("observations/\(self.observationId)/comments")
                    }
                    
                    let commentidChild = parentRef.child(autoID.key)
                    commentidChild.setValue(true)
                    
                    let alert = UIAlertController(title: "Alert", message: "Comment Posted Successfully", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default)
                    {
                        UIAlertAction in
                        self.commentTF.text = ""
                        
                    }
                    alert.addAction(okAction)
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.activityIndicator_comment.stopAnimating()
                }
                
                self.getUpdatedComments()
            })
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Enter Text in the Comment Field to Post it", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func likeButtonClicked(sender: UIButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if (userDefaults.stringForKey("isSignedIn") == "true")
        {
            if(isUserLiked == true)
            {
                let alert = UIAlertController(title: "Alert", message: "You Already liked this post", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                postLiketoDesign(true)
            }

        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Sign In to like", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func dislikeButtonClicked(sender: UIButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if (userDefaults.stringForKey("isSignedIn") == "true")
        {
            if(isUserDisLiked == true)
            {
                let alert = UIAlertController(title: "Alert", message: "You Already disliked this post", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                postLiketoDesign(false)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Sign In to dislike", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }

    @IBAction func likeButtonBesidesCommentBoxClicked(sender: UIButton) {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if((userDefaults.stringForKey("isSignedIn")) == "true")
        {
            if(isObservationLiked == true)
            {
                let alert = UIAlertController(title: "Alert", message: "You Already liked this post", preferredStyle: UIAlertControllerStyle.Alert)
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                postLiketoObservation()
            }
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Please Sign In to like this post", preferredStyle: UIAlertControllerStyle.Alert)
            let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(action)
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func postLiketoDesign(islike: Bool)
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var userID = String()

        if(userDefaults.objectForKey("userID") != nil)
        {
            userID = (userDefaults.objectForKey("userID") as? String)!
        }

        var email = ""
        var password = ""

        if(userDefaults.objectForKey("email") as? String != nil || userDefaults.objectForKey("password") as? String != nil)
        {
            email = decodeString((userDefaults.objectForKey("email") as? String)!)
            password = decodeString((userDefaults.objectForKey("password") as? String)!)
        }

        print(userID)

        let refUser = FIRAuth.auth()
        refUser!.signInWithEmail(email, password: password, completion: { authData, error in
            if error != nil {
                print("\(error)")
                var alert = UIAlertController()
                
                if(email == "")
                {
                    alert = UIAlertController(title: "Alert", message:"Please Login to continue" ,preferredStyle: UIAlertControllerStyle.Alert)
                }
                else
                {
                    alert = UIAlertController(title: "Alert", message:error?.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                }
                
                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                if (userID != "")
                {
                    print("\(self.designID)/likes")
                    let ref = FIRDatabase.database().referenceWithPath("ideas/"+"\(self.designID)/likes")
                    let userChild = ref.childByAppendingPath(userID)
                    userChild.setValue(islike)
                    print(self.designID)
                    var errMsg = ""

                    if (islike == true)
                    {
                        errMsg = "Liked Successfully"
                    }
                    else
                    {
                        errMsg = "DisLiked Successfully"
                    }

                    let alert = UIAlertController(title: "Alert", message: errMsg, preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.getUpdatedlikestoDesignIdeas()
                }
                else
                {
                    let alert = UIAlertController(title: "Alert", message: "Please Sign In to like the Design", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }

    func postLiketoObservation()
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        var userID = String()

        if(userDefaults.objectForKey("userID") != nil)
        {
            userID = (userDefaults.objectForKey("userID") as? String)!
        }

        print(userID)

        var email = ""
        var password = ""

        if(userDefaults.objectForKey("email") as? String != nil || userDefaults.objectForKey("password") as? String != nil)
        {
            email = decodeString((userDefaults.objectForKey("email") as? String)!)
            password = decodeString((userDefaults.objectForKey("password") as? String)!)
        }

        let refUser = FIRAuth.auth()
        refUser!.signInWithEmail(email, password: password, completion: { authData, error in
            if error != nil {

                print("\(error)")

                var alert = UIAlertController()
                if(email == "")
                {
                    alert = UIAlertController(title: "Alert", message:"Please Login to continue" ,preferredStyle: UIAlertControllerStyle.Alert)
                }
                else
                {
                    alert = UIAlertController(title: "Alert", message:error?.localizedDescription ,preferredStyle: UIAlertControllerStyle.Alert)
                }

                let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)

            }
            else
            {
                if(userID != "" || self.observationId != "")
                {
                    let ref = FIRDatabase.database().referenceWithPath("observations/\(self.observationId)/likes") //Firebase(url:
                    let userChild = ref.childByAppendingPath(userID)
                    userChild.setValue(true)
                    print(self.observationId)

                    let alert = UIAlertController(title: "Alert", message: "Liked Successfully", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)

                    self.getLikesToObservations()
                }
                else
                {
                    let alert = UIAlertController(title: "Alert", message: "Please Sign In to like the Observation", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
}
