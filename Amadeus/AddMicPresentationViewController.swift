//
//  AddMicPresentationViewController.swift
//  Amadeus
//
//  Created by Theo on 21/08/2017.
//  Copyright © 2017 Vibear Inc. All rights reserved.
//

import UIKit

class AddMicPresentationViewController: UIViewController
{
    @IBOutlet weak var presentationLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(true)

        self.view.backgroundColor = UIColor.vibearBackground

        self.colorize()

        self.localize()
    }

    func colorize()
    {
        if (NIGHTMODE == true)
        {
            self.presentationLabel.textColor = UIColor.white
        }
        else
        {
            self.presentationLabel.textColor = UIColor.black
        }
    }

    func localize()
    {
        self.title = "addmicpresentation.title".localized
        self.presentationLabel.localized("addmicpresentation.text")
        self.nextButton.localized("addmicpresentation.next")
    }

    @IBAction func cancelAdding(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
}
