//
//  MemberCollectionViewCell.swift
//  ShareGroupLocation
//
//  Created by Duy Huynh Thanh on 11/22/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class MemberCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 30
    }
}
