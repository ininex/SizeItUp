//
//  scanningVC.swift
//  UI
//
//  Created by MaoMaos on 10/8/16.
//  Copyright © 2016 MaoMaos. All rights reserved.
//

import Foundation
import UIKit
import iCarousel
import Firebase

class scanningVC: UIViewController, iCarouselDelegate, iCarouselDataSource, cameraFrameProcessorDelegate{
    
    @IBOutlet weak var cameraView: UIImageView!
    
    @IBOutlet var resultsView: UIView!
    
    var mainCarousel: iCarousel!
    
    var shouldUseSingleFrameProcessing = false
    
    var singleImageToProceed: UIImage!
    
    var shouldAnimateCarousel = true
    
    var initialDataBlocker = true
    
    var loader: Loader!
    
    var bestFit: String? {
        didSet{
            if self.initialDataBlocker == false{
                DispatchQueue.main.async {
                    if self.shouldAnimateCarousel == true {
                        self.mainCarousel.center.y += 100.0
                        self.mainCarousel.isHidden = false
                    }
                    self.mainCarousel.reloadData()
                    if self.shouldAnimateCarousel == true {
                        UIView.animate(withDuration: 0.2, animations: {
                            self.mainCarousel.center.y -= 100.0
                            self.mainLabel.center.y = self.cameraView.frame.maxY - 5.0
                            }, completion: { (_) in
                                self.loader.stop()
                                self.mainLabel.text = "The following products best fit your need:"
                                self.shouldAnimateCarousel = false
                        })
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(self.animateFocus(notification:)), name: NSNotification.Name(rawValue: "UIImageFeatureMatchingKeypointsUpdated"), object: nil)
    }
    
    func animateFocus(notification: NSNotification){
        guard notification.name._rawValue != "UIImageFeatureMatchingKeypointsWaiting" && self.shouldAnimateCarousel == true else{
            return
        }
        DispatchQueue.main.async {
            self.cameraView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.3, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.curveLinear, animations: {
                self.cameraView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (_) in
                self.shouldAnimateCarousel = false
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var otherFits: [String]?
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = "Scanning"
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Fit", style: .plain, target: self, action: #selector(self.Album(_:)))
        self.loader =  Loader.init(targetView: self.resultsView)
        self.loader.start()
        let deadlineTime = DispatchTime.now() + .seconds(3)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.initialDataBlocker = false
        }
    }
    
    override func viewDidLoad() {
        //Prototyping data uploading code
//        let ref = FIRDatabase.database().reference()
//        let dict_1: [String: AnyObject] = [
//            "ProductName":"Red Bull" as AnyObject,
//            "Width":5.08 as AnyObject,
//            "Length":5.08 as AnyObject,
//            "Height":13.4 as AnyObject,
//        ]
//        let dict_2: [String: AnyObject] = [
//            "ProductName":"Tropicana Oriange Juice" as AnyObject,
//            "Width":4.88 as AnyObject,
//            "Length":4.88 as AnyObject,
//            "Height":18.82 as AnyObject,
//            ]
//        let dict_3: [String: AnyObject] = [
//            "ProductName":"Monster" as AnyObject,
//            "Width":6.88 as AnyObject,
//            "Length":6.88 as AnyObject,
//            "Height":16.22 as AnyObject,
//            ]
//        ref.child("productList").childByAutoId().setValue(dict_1) { (_, _) in
//            ref.child("productList").childByAutoId().setValue(dict_2) { (_, _) in
//                ref.child("productList").childByAutoId().setValue(dict_3) { (_, _) in
//                    
//                }
//            }
//        }
        self.cameraView.frame.size.width = self.view.frame.width
        self.cameraView.frame.size.height = (460/667)*self.view.frame.height
        let cameraVC = cameraFrameProcessor(singleFrameMode: self.shouldUseSingleFrameProcessing)
        cameraVC.singleFrame = self.singleImageToProceed
        cameraVC.delegate = self
        self.addChildViewController(cameraVC)
        cameraVC.view.frame = self.cameraView.frame
        self.view.addSubview(cameraVC.view)
        self.view.bringSubview(toFront: cameraView)
        cameraVC.didMove(toParentViewController: self)
        
        self.resultsView.frame.origin.y = self.cameraView.frame.maxY
        self.resultsView.frame.size.height = self.view.frame.maxY - self.cameraView.frame.maxY
        self.resultsView.frame.size.width = self.view.frame.width
        
        self.mainCarousel = iCarousel(frame: self.resultsView.frame)
        mainCarousel.type = .linear
        mainCarousel.delegate = self
        mainCarousel.dataSource = self
        mainCarousel.isHidden = true
        self.view.addSubview(mainCarousel)
        
        self.mainLabel = UILabel(frame: CGRect(x: self.resultsView.frame.origin.x + 20.0, y: self.resultsView.frame.origin.y + 30.0, width: self.resultsView.frame.width - 40.0, height: 44.0))
        mainLabel.numberOfLines = 0
        mainLabel.text = "Thinking..."
        mainLabel.textColor = UIColor.white
        mainLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        mainLabel.textAlignment = .center
        self.view.addSubview(mainLabel)
    }
    
    var mainLabel: UILabel!
    
    func Album(_ sender: AnyObject) {
        print("Album has been pushed")
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        guard self.bestFit != nil else {
            return 0
        }
        return 3
        
    }
    
    var productsAndImages: [String: UIImage] = [
        "Monster":UIImage(named: "reference_product")!,
        "Tropicana Oriange Juice":UIImage(named: "juice")!,
        "Red Bull":UIImage(named: "red_bull")!
    ]
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: UIImageView
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            /*var keypoints = [
             "Monster": 0,
             "Tropicana Oriange Juice": 0,
             "Red Bull": 0
             ]*/
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:80, height:80))
            itemView.backgroundColor = UIColor(red: 38/255, green: 37/255, blue: 46/255, alpha: 1.0)
            itemView.layer.cornerRadius = 10.0
            itemView.layer.borderColor = UIColor.white.cgColor
            itemView.layer.borderWidth = 4.0
            itemView.layer.masksToBounds = true
            itemView.contentMode = .scaleAspectFit
            if index == 0 {
                itemView.image = self.productsAndImages[self.bestFit!]
            }else{
                itemView.image = self.productsAndImages[(self.otherFits?[index - 1])!]
            }
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view as! UIImageView;
        }
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        
        if option == .spacing {
            return 1.2
        }
        
        return value
    }
    
    func frameProcessorDidFinishRankingMatchingProducts(bestFit: String, otherKeys: [String]) {
        print("bestFit: \(bestFit), otherKeys: \(otherKeys)")
        self.otherFits = otherKeys
        self.bestFit = bestFit
    }
}

