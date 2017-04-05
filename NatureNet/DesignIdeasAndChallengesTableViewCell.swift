//
//  DesignIdeasAndChallengesTableViewCell.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 5/17/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit

class DesignIdeasAndChallengesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var designIdeaOrChallengeImageView: UIImageView!
    
    @IBOutlet weak var designIdeaOrChallengeAvatarView: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var submitterAvatarView: UIImageView!

    @IBOutlet weak var submitterDisplayName: UILabel!
    
    @IBOutlet weak var submitterAffiliation: UILabel!
    
    @IBOutlet weak var statusImageView: UIImageView!
    
    @IBOutlet weak var likesLabel: UILabel!
    
    @IBOutlet weak var dislikesLabel: UILabel!
    
    @IBOutlet weak var commentsLabel: UILabel!
    
}
