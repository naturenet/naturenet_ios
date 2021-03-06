//
//  HomeViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 5/21/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var signInButton_home: UIButton!
    @IBOutlet weak var joinNatureNetButton: UIButton!

    @IBOutlet weak var alreadyAMemberLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        if self.revealViewController() != nil {
            self.view.addGestureRecognizer(revealViewController().panGestureRecognizer())
            self.revealViewController().rearViewRevealWidth = 290
            
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "menu.png"), style: .Plain, target: self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)))
            
            navigationItem.leftBarButtonItem = barButtonItem
            
        }
        
        self.navigationItem.title="NatureNet"
        
        self.navigationController!.navigationBar.barTintColor = UIColor(red: 48.0/255.0, green: 204.0/255.0, blue: 114.0/255.0, alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        
        signInButton_home.hidden = false
        alreadyAMemberLabel.hidden = false
        joinNatureNetButton.hidden = false
        
        hideShowJoinButton()
        
    }
    
    func hideShowJoinButton()
    {
        let userDefaults = NSUserDefaults.standardUserDefaults()

        if((userDefaults.stringForKey("isSignedIn")) != "true")
        {
            joinNatureNetButton.hidden = false
            
        }
        else
        {
            joinNatureNetButton.hidden = true
            signInButton_home.hidden = true
            alreadyAMemberLabel.hidden = true
        }
    }
    
    @IBAction func joinNatureNet(sender: UIButton) {
        let signInSignUpVC=SignInSignUpViewController()
        let signInSignUpNavVC = UINavigationController()
        signInSignUpVC.isFromHomeVC = true
        signInSignUpVC.pageTitle="Join NatureNet"
        signInSignUpNavVC.viewControllers = [signInSignUpVC]
        self.presentViewController(signInSignUpNavVC, animated: true, completion: nil)
    }
    
    
    @IBAction func signInButtonHomeClicked(sender: AnyObject) {
        let signInSignUpVC=SignInSignUpViewController()
        let signInSignUpNavVC = UINavigationController()
        signInSignUpVC.pageTitle="Sign In"
        signInSignUpVC.isFromHomeVC = true
        signInSignUpNavVC.viewControllers = [signInSignUpVC]
        self.presentViewController(signInSignUpNavVC, animated: true, completion: nil)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        hideShowJoinButton()
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if((userDefaults.stringForKey("isSignedIn")) == "true")
        {
            let mapVC = MapViewController()
            let newFrontViewController = UINavigationController(rootViewController: mapVC)
            self.revealViewController().revealToggleAnimated(true)
            self.revealViewController().setFrontViewController(newFrontViewController, animated: false)
        }
    }
}
