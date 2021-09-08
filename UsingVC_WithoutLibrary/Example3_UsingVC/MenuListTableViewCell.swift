//
//  MenuListTableViewCell.swift
//  Example3_UsingVC
//
//  Created by Mallikarjun on 14/07/20.
//  Copyright © 2020 Mallikarjun. All rights reserved.
//

import UIKit

class MenuListTableViewCell: UITableViewCell {

    @IBOutlet weak var menuLabel: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
