//
//  FirstOpeningViewController.swift
//  Amadeus
//
//  Created by Theo Caselli on 07/05/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class FirstOpeningViewController: UIViewController
{
    @IBOutlet weak var vibearIcon: UIImageView!
    @IBOutlet weak var configureBoxLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.localize()
    }
    
    private func localize()
    {
        self.configureBoxLabel.localized("firstopening.welcome")
        self.nextButton.localized("firstopening.button")
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        UIView.animate(withDuration: 1.5, animations:
        {
            self.vibearIcon.center.y = self.view.frame.height / 4
        }, completion:
            { _ in
                UIView.animate(withDuration: 1, animations:
                {
                        self.configureBoxLabel.alpha = 1
                        self.nextButton.alpha = 1
                }, completion: nil)
        })
    }
}
