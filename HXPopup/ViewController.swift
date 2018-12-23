//
//  ViewController.swift
//  HXPopup
//
//  Created by Dmitry Kovalev on 23/12/2018.
//  Copyright © 2018 Dmitry Kovalev. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var popupCounterLabel: UILabel!
    
    var popupCounter: Int = 0 { didSet { popupCounterLabel.text = "\(popupCounter)" } }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    @IBAction func onButton(_ sender: UIButton)
    {
        let popup = PopupXibVC()
        popup.popupButtonHandler = { (popup: HXBasePopupViewController) in popup.dimiss() }
        popup.dismissCompletion = { [weak self] in self?.popupCounter += 1 }
        popup.popupViewCornerRadius = 12
        popup.backgroundViewColor = UIColor(white: 0, alpha: 0.6)
        popup.present(from: self)
    }
    
}

