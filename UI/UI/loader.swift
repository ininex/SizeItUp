//
//  loader.swift
//  SizeItUp
//
//  Created by GUANJIU ZHANG on 10/9/16.
//

import UIKit

class Loader {
    static var sharedInstance = Loader()
    convenience init(targetView view: UIView?) {
        self.init(targetView: view, withSize: CGSize(width: 100.0, height: 100.0))
    }
    
    init(targetView view: UIView?, withSize size: CGSize) {
        if view != nil {
            self.targetView = view!
        }
        
        self.loadingIndicatorImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.loadingIndicatorImageView.image = UIImage(named: "Loading")
        self.loadingIndicatorImageView.contentMode = .scaleAspectFit
        self.loadingIndicatorImageView.center = (self.targetView.superview?.convert(self.targetView.center, to: self.targetView)) ?? targetView.center
    }
    
    func start() {
        self.targetView.addSubview(self.loadingIndicatorImageView)
        var rotationAnimation: CABasicAnimation
        rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = -M_PI * 16.0
        rotationAnimation.duration = 5.0
        rotationAnimation.repeatDuration = 0.0
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.loadingIndicatorImageView.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }
    
    func stop() {
        self.loadingIndicatorImageView.removeFromSuperview()
    }
    
    var indicatorSize: CGSize {
        get {
            return loadingIndicatorImageView.frame.size
        }
        set {
            loadingIndicatorImageView.frame.size = newValue
            loadingIndicatorImageView.center = (self.targetView.superview?.convert(self.targetView.center, to: self.targetView)) ?? targetView.center
        }
    }
    
    private var loadingIndicatorImageView: UIImageView!
    
    convenience init() {
        self.init(targetView: nil)
    }
    
    private lazy var targetView: UIView = {
        return UIApplication.shared.keyWindow!
    }()
    
}
