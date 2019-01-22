//
//  HomeCardView.swift
//  Amadeus
//
//  Created by Theo Caselli on 09/06/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class HomeCardView: UICollectionViewCell
{
    @IBOutlet weak var notificationTitle: UILabel!
    @IBOutlet weak var notificationPlace: UILabel!
    @IBOutlet weak var notificationTime: UILabel!
    @IBOutlet weak var notificationDate: UILabel!

    override func awakeFromNib()
    {
        self.layer.cornerRadius = 20
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.layer.shadowRadius = 5.0
        
        self.notificationTitle.textColor = UIColor.vibearBlue
        self.notificationTime.textColor = UIColor.vibearBlue
    }
}
