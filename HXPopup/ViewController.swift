//
//  ViewController.swift
//  HXPopup
//
//  Created by Dmitry Kovalev on 23/12/2018.
//  Copyright © 2018 Dmitry Kovalev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onButton(_ sender: UIButton)
    {
        let popup = PopupXibVC()
        popup.popupButtonHandler = {(popup: HXBasePopupViewController) in popup.dimiss()}
        popup.present(from: self)
    }
    
}

