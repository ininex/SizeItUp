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
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = "Scanning"
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Fit", style: .plain, target: self, action: #selector(self.Album(_:)))
    }
    
    override func viewDidLoad() {
        let ref = FIRDatabase.database().reference()
        let dict_1: [String: AnyObject] = [
            "ProductName":"Red Bull" as AnyObject,
            "Width":5.08 as AnyObject,
            "Length":5.08 as AnyObject,
            "Height":13.4 as AnyObject,
        ]
        let dict_2: [String: AnyObject] = [
            "ProductName":"Tropicana Oriange Juice" as AnyObject,
            "Width":4.88 as AnyObject,
            "Length":4.88 as AnyObject,
            "Height":18.82 as AnyObject,
            ]
        let dict_3: [String: AnyObject] = [
            "ProductName":"Monster" as AnyObject,
            "Width":6.88 as AnyObject,
            "Length":6.88 as AnyObject,
            "Height":16.22 as AnyObject,
            ]
        self.cameraView.frame.size.width = self.view.frame.width
        self.cameraView.frame.size.height = (460/667)*self.view.frame.height
        let cameraVC = cameraFrameProcessor(nibName: nil, bundle: nil)
        cameraVC.delegate = self
        self.addChildViewController(cameraVC)
        cameraVC.view.frame = self.cameraView.frame
        self.view.addSubview(cameraVC.view)
        cameraVC.didMove(toParentViewController: self)
        
        self.resultsView.frame.origin.y = self.cameraView.frame.maxY
        self.resultsView.frame.size.height = self.view.frame.maxY - self.cameraView.frame.maxY
        self.resultsView.frame.size.width = self.view.frame.width
        
        let carousel = iCarousel(frame: self.resultsView.frame)
        carousel.type = .linear
        carousel.delegate = self
        carousel.dataSource = self
        self.view.addSubview(carousel)
    }
    
    func Album(_ sender: AnyObject) {
        print("Album has been pushed")
    }

    func numberOfItems(in carousel: iCarousel) -> Int {
        return 3
        
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var label: UILabel
        var itemView: UIImageView
        
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            //this `if (view == nil) {...}` statement because the view will be
            //recycled and used with other index values later
            itemView = UIImageView(frame:CGRect(x:0, y:0, width:80, height:80))
            itemView.backgroundColor = UIColor.green
            itemView.contentMode = .center
            label = UILabel(frame:itemView.bounds)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .center
            label.font = label.font.withSize(50)
            label.tag = 1
            itemView.addSubview(label)
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view as! UIImageView;
            label = itemView.viewWithTag(1) as! UILabel!
        }
        
        //set item label
        //remember to always set any properties of your carousel item
        //views outside of the `if (view == nil) {...}` check otherwise
        //you'll get weird issues with carousel item content appearing
        //in the wrong place in the carousel
        label.text = "TEST"
        
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
    }
}

