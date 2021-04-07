//
//  PersonCell.swift
//  HWS Project 10
//
//  Created by Mohammed Qureshi on 2020/09/09.
//  Copyright © 2020 Experiment1. All rights reserved.
//

import UIKit
//Swift removed the Manual Key to open other files in the IB. So to get this to come up in the IB cmd + shift + O then type in file then hold option and press enter.
class PersonCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var name: UILabel!
}
