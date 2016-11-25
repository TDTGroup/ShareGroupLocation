//
//  GroupViewCell.swift
//  ShareGroupLocation
//
//  Created by Truong Vo Duy Thuc on 11/25/16.
//  Copyright © 2016 Duy Huynh Thanh. All rights reserved.
//

import UIKit

class GroupViewCell: UITableViewCell {

    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
