//
//  CircleImage.swift
//  Meidu
//
//  Created by William Huang on 9/7/17.
//  Copyright © 2017 William Huang. All rights reserved.
//

import UIKit

class CircleImage: UIImageView {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.width / 2
        self.clipsToBounds = true
    }

}
