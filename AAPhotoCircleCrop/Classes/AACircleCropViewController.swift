//
//  AACircleCropViewController.swift
//
//  Created by Keke Arif on 29/02/2016.
//  Modified by Andrea Antonioni on 14/01/2017
//  Copyright © 2017 Andrea Antonioni. All rights reserved.
//

import UIKit

@objc public protocol AACircleCropViewControllerDelegate {
    
    func circleCropDidCropImage(_ image: UIImage)
    @objc optional func circleCropDidCancel()
}

open class AACircleCropViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - Open properties
    /// Set the delegate to get the cropped image
    open var delegate: AACircleCropViewControllerDelegate?
    /// Image to crop
    open var image: UIImage!
    /// Set the size to get the cropped image resized. The
    /// default size is the circleDiameter
    open var imageSize: CGSize?
    /// Titles of the buttons. You can use them for localization
    open var selectTitle: String = "Select"
    open var rotateTitle: String = "Rotate"
    open var cancelTitle: String = "Cancel"
    /// Status bar style
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private properties
    fileprivate var selectButton: UIButton!
    fileprivate var rotateButton: UIButton!
    fileprivate var cancelButton: UIButton!
    fileprivate var imageView: UIImageView!
    fileprivate var scrollView: AACircleCropScrollView!
    fileprivate var cutterView: AACircleCropCutterView!
    private var circleDiameter: CGFloat {
        // Offeset for leading and trailing
        let circleOffset: CGFloat = 40
        return UIScreen.main.bounds.width - circleOffset * 2
    }
    
    //- - -
    // MARK: - View Management
    //- - -
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        
        // Setup imageView
        imageView = UIImageView()
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: image.size)
        
        // Setup scrollView
        scrollView = AACircleCropScrollView(frame: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter))
        scrollView.backgroundColor = .black
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.contentSize = image.size
        
        let scaleWidth = scrollView.frame.size.width / scrollView.contentSize.width
        scrollView.minimumZoomScale = scaleWidth
        if imageView.frame.size.width < scrollView.frame.size.width {
            print("We have the case where the frame is too small")
            scrollView.maximumZoomScale = scaleWidth * 2
        } else {
            scrollView.maximumZoomScale = 1.0
        }
        scrollView.zoomScale = scaleWidth
        
        // Center vertically
        scrollView.contentOffset = CGPoint(x: 0, y: (scrollView.contentSize.height - scrollView.frame.size.height)/2)
        
        scrollView.center = view.center
        view.addSubview(scrollView)
        
        setupCutterView()
        setupButtons()
    }
    
    override open func dismiss(animated: Bool, completion: (() -> Void)?) {
        if isModal {
            super.dismiss(animated: animated, completion: completion)
        } else {
            _ = navigationController?.popViewController(animated: animated)
        }
    }

    //- - -
    // MARK: - Helper methods
    //- - -
    
    fileprivate func setupCutterView() {
        cutterView = AACircleCropCutterView()
        cutterView.circleDiameter = circleDiameter
        
        view.addSubview(cutterView)
        
        cutterView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: cutterView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0))
    }
    
    fileprivate func setupButtons() {
        
        selectButton = UIButton()
        rotateButton = UIButton()
        cancelButton = UIButton()
        
        // Styles
        selectButton.setTitle(selectTitle, for: .normal)
        selectButton.setTitleColor(.white, for: .normal)
        selectButton.titleLabel?.font = cancelButton.titleLabel?.font.withSize(17)
        selectButton.addTarget(self, action: #selector(selectAction), for: .touchUpInside)
        
        rotateButton.setTitle(rotateTitle, for: .normal)
        rotateButton.setTitleColor(.white, for: .normal)
        rotateButton.titleLabel?.font = cancelButton.titleLabel?.font.withSize(17)
        rotateButton.addTarget(self, action: #selector(rotateAction), for: .touchUpInside)
        
        cancelButton.setTitle(cancelTitle, for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.titleLabel?.font = cancelButton.titleLabel?.font.withSize(17)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        // Adding buttons to the superview
        cutterView.addSubview(selectButton)
        cutterView.addSubview(rotateButton)
        cutterView.addSubview(cancelButton)
        
        // cancelButton constraints
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cutterView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .leading, relatedBy: .equal, toItem: cutterView, attribute: .leadingMargin, multiplier: 1, constant: 20))
        cutterView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: .bottomMargin, relatedBy: .equal, toItem: cutterView, attribute: .bottomMargin, multiplier: 1, constant: -32))
        
        // rotateButton consrtraints
        rotateButton.translatesAutoresizingMaskIntoConstraints = false
		cutterView.addConstraint(NSLayoutConstraint(item: rotateButton, attribute: .centerY, relatedBy: .equal, toItem: cancelButton, attribute: .centerY, multiplier: 1, constant: 0))
		cutterView.addConstraint(NSLayoutConstraint(item: rotateButton, attribute: .centerX, relatedBy: .equal, toItem: cutterView, attribute: .centerX, multiplier: 1, constant: 0))
        
        // selectButton consrtraints
        selectButton.translatesAutoresizingMaskIntoConstraints = false
        cutterView.addConstraint(NSLayoutConstraint(item: selectButton, attribute: .trailing, relatedBy: .equal, toItem: cutterView, attribute: .trailingMargin, multiplier: 1, constant: -20))
        cutterView.addConstraint(NSLayoutConstraint(item: selectButton, attribute: .bottomMargin, relatedBy: .equal, toItem: cutterView, attribute: .bottomMargin, multiplier: 1, constant: -32))
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    //- - -
    // MARK: - Actions
    //- - -
    
    func selectAction() {
        
        let newSize = CGSize(width: imageView.image!.size.width * scrollView.zoomScale, 
                             height: imageView.image!.size.height * scrollView.zoomScale)
        
        let offset = scrollView.contentOffset
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: circleDiameter, height: circleDiameter), false, 0)
        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: circleDiameter, height: circleDiameter))
        circlePath.addClip()
        var sharpRect = CGRect(x: -offset.x, y: -offset.y, width: newSize.width, height: newSize.height)
        sharpRect = sharpRect.integral
        
        imageView.image!.draw(in: sharpRect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let imageData = UIImagePNGRepresentation(finalImage!), var pngImage = UIImage(data: imageData) {
            
            if let imageSize = imageSize {
                pngImage = pngImage.resizeImage(newWidth: imageSize.width)
            }
            delegate?.circleCropDidCropImage(pngImage)
            
        } else {
            delegate?.circleCropDidCancel?()
        }
        self.dismiss(animated: true, completion: nil) 
    }
    
    func rotateAction() {
        imageView.image = imageView.image!.rotatedBy(degrees: 90)
		imageView.frame = CGRect(x: 0, y: 0, width: imageView.frame.size.height, height: imageView.frame.size.width)
		scrollView.contentSize = imageView.frame.size
    }
    
    func cancelAction() {
        delegate?.circleCropDidCancel?()
        self.dismiss(animated: true, completion: nil)
    }
}
