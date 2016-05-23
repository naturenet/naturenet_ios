//
//  ProjectDetailCollectionViewCell.swift
//  NatureNet
//
//  Created by Abhinay Balusu on 4/22/16.
//  Copyright © 2016 NatureNet. All rights reserved.
//

import UIKit

class ProjectDetailCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var observerAvatarImageView: UIImageView!
    @IBOutlet weak var observationProjectImageView: UIImageView!
    
    
    @IBOutlet weak var observerNameLabel: UILabel!
    @IBOutlet weak var observerAffiliationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
