//
//  DesignIdeasAndChallengesViewController.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 4/19/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit

class DesignIdeasAndChallengesViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!

    @IBAction func disignIdeasButtonClicked(sender: UIButton) {
        let newDIandDCVC = NewDesignIdeasAndChallengesViewController()
        let navVC = UINavigationController()
        newDIandDCVC.isDesignIdea = true
        navVC.viewControllers = [newDIandDCVC]
        self.presentViewController(navVC, animated: true, completion: nil)
    }
    
    @IBAction func designChallengesButtonClicked(sender: UIButton) {
        let newDIandDCVC = NewDesignIdeasAndChallengesViewController()
        let navVC = UINavigationController()
        newDIandDCVC.isDesignIdea = false
        navVC.viewControllers = [newDIandDCVC]
        self.presentViewController(navVC, animated: true, completion: nil)
    }
}
