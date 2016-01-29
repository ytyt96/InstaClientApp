//
//  PhotoViewCell.swift
//  Instagram
//
//  Created by Erica Lee on 1/28/16.
//  Copyright © 2016 Erica Lee. All rights reserved.
//

import UIKit

class PhotoViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
