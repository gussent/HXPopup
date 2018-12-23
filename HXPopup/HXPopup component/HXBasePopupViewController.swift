//
//  HXBasePopupViewController.swift
//  HXPopup
//
//  Created by Dmitry Kovalev on 23/12/2018.
//  Copyright © 2018 Dmitry Kovalev. All rights reserved.
//

import UIKit

class SwiftyTapGestureRecognizer: UITapGestureRecognizer
{
    typealias tapGestureHandler = (UITapGestureRecognizer)->Void
    var handler: tapGestureHandler
    
    init(with view: UIView, handler: @escaping tapGestureHandler)
    {
        self.handler = handler

        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(self.onTap(_:)))
        view.addGestureRecognizer(self)
    }
    
    @objc func onTap(_ recognizer: UITapGestureRecognizer)
    {
        handler(self)
    }
}

class HXBasePopupViewController: UIViewController
{
    // MARK: - Properties
    
    var viewControllerToPresentFrom: UIViewController?
    
    var popupRootView: UIView? { fatalError("Must be overrided in a subclass") }
    var backgroundView: UIView?
    
    var presenting = false
    var dismissing = false
    var dismissCompletion: (()->Void)?

    // MARK: - Settings
    
    var animatedPresentation = true
    var animatedDismissal = true
    var backgroundViewColor = UIColor(white: 0, alpha: 0.9)
    
    // MARK: - Public API
    
    func present(from viewController: UIViewController?)
    {
        viewControllerToPresentFrom = viewController
        present()
    }
    
    func present()
    {
        loadViewIfNeeded()
        
        guard popupRootView != nil, let viewController = topmostViewController() else { return }
        
        presenting = true
        
        viewController.present(self, animated: false)
        {
            [weak self] in guard let self = self else { return }

            if let bgView = self.backgroundView { self.view.sendSubviewToBack(bgView) }
            
            self.show(backgroundView: self.backgroundView, animated: self.animatedPresentation, completion:
            {
                
            })
            
            self.show(popupView: self.popupRootView, animated: self.animatedPresentation, completion:
            {
                
            })
        }
    }
    
    func dimiss()
    {
        dismissing = true
        
        self.hide(backgroundView: self.backgroundView, animated: self.animatedPresentation, completion:
        {
                
        })
        
        self.hide(popupView: popupRootView, animated: self.animatedPresentation, completion:
        {
                
        })
    }
    
    // MARK: - Presentation logic
    
    func show(backgroundView: UIView?, animated: Bool, completion: ()->())
    {
        if !animatedPresentation
        {
            backgroundView?.alpha = 1
            backgroundView?.isHidden = false
            return
        }
    }
    
    func show(popupView: UIView?, animated: Bool, completion: ()->())
    {
        if !animatedPresentation
        {
            popupView?.alpha = 1
            popupView?.isHidden = false
            presenting = false
            onPresentationCompleted()
            return
        }
        
        presenting = false
        onPresentationCompleted()
    }
    
    func onPresentationCompleted()
    {
        
    }
    
    // MARL: - Dismissal logic
    
    func hide(backgroundView: UIView?, animated: Bool, completion: ()->())
    {
        if !animatedPresentation
        {
            backgroundView?.alpha = 0
            backgroundView?.isHidden = true
            dismissing = false
            onDismissCompleted()
            return
        }
        
        dismissing = false
        onDismissCompleted()
    }
    
    func hide(popupView: UIView?, animated: Bool, completion: ()->())
    {
        if !animatedPresentation
        {
            popupView?.alpha = 0
            popupView?.isHidden = true
            return
        }
        
        dismissing = false
        onDismissCompleted()
    }
    
    func onDismissCompleted()
    {
        dismiss(animated: false, completion: dismissCompletion)
    }
    
    // MARK: - Setup
    
    var backgroundViewTapRecognizer: SwiftyTapGestureRecognizer?
    private func setupBackground()
    {
        backgroundView = UIView()
        backgroundView!.backgroundColor = backgroundViewColor
        
        backgroundView!.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(backgroundView!, at: 0)
        
        NSLayoutConstraint.activate(
        [
            backgroundView!.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView!.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView!.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        backgroundViewTapRecognizer = SwiftyTapGestureRecognizer(with: backgroundView!)
        { [weak self] (recognizer: UITapGestureRecognizer) in
            self?.dimiss()
        }
    }
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupBackground()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Utils
    
    private func topmostViewController() -> UIViewController?
    {
        if let viewController = viewControllerToPresentFrom { return viewController }
        
        var topController = UIApplication.shared.keyWindow?.rootViewController
        while let vc = topController?.presentedViewController
        {
            topController = vc
        }
        
        return topController
    }
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        customInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func customInit()
    {
        modalPresentationStyle = .overFullScreen
    }
    
    deinit
    {
        print("Deinit: \(String(describing: self))")
    }
}
