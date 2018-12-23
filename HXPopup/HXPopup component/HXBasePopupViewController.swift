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
    
    var backgroundViewColor = UIColor(white: 0, alpha: 0.9) { didSet { backgroundView?.backgroundColor = backgroundViewColor } }
    var popupViewCornerRadius: CGFloat = 6.0 { didSet { popupRootView?.layer.cornerRadius = popupViewCornerRadius } }
    
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
                [weak self] in guard let self = self else { return }
                self.presenting = false
                self.onPresentationCompleted()
            })
        }
    }
    
    func dimiss()
    {
        dismissing = true
        
        self.hide(backgroundView: self.backgroundView, animated: self.animatedPresentation, completion:
        {
            [weak self] in guard let self = self else { return }
            self.dismissing = false
            self.onDismissCompleted()
        })
        
        self.hide(popupView: popupRootView, animated: self.animatedPresentation, completion:
        {
                
        })
    }
    
    // MARK: - Presentation logic
    
    func show(backgroundView: UIView?, animated: Bool, completion: @escaping ()->())
    {
        backgroundView?.alpha = 0
        backgroundView?.isHidden = false
        
        if !animatedPresentation
        {
            backgroundView?.alpha = 1
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:
        {
            backgroundView?.alpha = 1
        })
        { (finished) in
            completion()
        }
    }
    
    func show(popupView: UIView?, animated: Bool, completion: @escaping ()->())
    {
        popupView?.alpha = 0
        popupView?.isHidden = false
        
        if !animatedPresentation
        {
            popupView?.alpha = 1
            completion()
            return
        }
        
        popupView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        
        UIView.animate(withDuration: 0.4, delay: 0.1, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseIn, animations:
        {
            popupView?.transform = .identity
        })
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:
        {
            popupView?.alpha = 1
        })
        { (finished) in
            completion()
        }
    }
    
    func onPresentationCompleted()
    {
        
    }
    
    // MARL: - Dismissal logic
    
    func hide(backgroundView: UIView?, animated: Bool, completion: @escaping ()->())
    {
        if !animatedPresentation
        {
            backgroundView?.alpha = 0
            backgroundView?.isHidden = true
            completion()
            return
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:
        {
            backgroundView?.alpha = 0
        })
        { (finished) in
            backgroundView?.isHidden = true
            completion()
        }
    }
    
    func hide(popupView: UIView?, animated: Bool, completion: @escaping ()->())
    {
        if !animatedPresentation
        {
            popupView?.alpha = 0
            popupView?.isHidden = true
            return
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseIn, animations:
        {
            popupView?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations:
        {
            popupView?.alpha = 0
        })
        { (finished) in
            popupView?.isHidden = true
            completion()
        }
    }
    
    func onDismissCompleted()
    {
        dismiss(animated: false, completion: dismissCompletion)
    }
    
    // MARK: - Setup
    
    var backgroundViewTapRecognizer: SwiftyTapGestureRecognizer?
    func setupBackground()
    {
        backgroundView = UIView()
        backgroundView!.backgroundColor = backgroundViewColor
        backgroundView?.alpha = 0
        backgroundView?.isHidden = true
        
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
    
    func setupPopupView()
    {
        popupRootView?.alpha = 0
        popupRootView?.isHidden = true
        popupRootView?.layer.cornerRadius = popupViewCornerRadius
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        view.backgroundColor = .clear
        setupBackground()
        setupPopupView()
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
    
    required init?(coder aDecoder: NSCoder)
    {
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
