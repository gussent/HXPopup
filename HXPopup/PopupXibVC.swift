//
//  PopupXibVC.swift
//  HXPopup
//
//  Created by Dmitry Kovalev on 23/12/2018.
//  Copyright © 2018 Dmitry Kovalev. All rights reserved.
//

import UIKit

class PopupXibVC: HXBasePopupViewController
{
    var popupButtonHandler: ((HXBasePopupViewController)->Void)?
    
    @IBOutlet var rootView: UIView!
    
    override var popupRootView: UIView? { return rootView }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func onButton(_ sender: UIButton)
    {
        if let handler = popupButtonHandler { handler(self) }
    }
}
