//
//  ViewController.swift
//  UI
//
//  Created by M on 10/1/16.
//  Copyright © 2016 MaoMaos. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
 
    @IBOutlet weak var mainNav: UINavigationBar!

    @IBOutlet weak var instructionView: UIImageView!
    
    @IBOutlet weak var buttonView: UIView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Scanner"
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "History", style: .plain, target: self, action: #selector(self.History(_:)))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Album", style: .plain, target: self, action: #selector(self.Album(_:)))
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 53/255, green: 51/255, blue: 62/255, alpha: 1.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.mainNav.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 64.0)
        self.instructionView.frame.origin.y = self.mainNav.frame.maxY
        self.instructionView.frame.size.height = (480/667)*self.view.frame.height
        self.instructionView.frame.size.width = self.view.frame.width
        self.buttonView.frame.origin.y = self.instructionView.frame.maxY
        self.buttonView.frame.size.height = self.view.frame.maxY - self.instructionView.frame.maxY
        self.buttonView.frame.size.width = self.view.frame.width
        self.view.addSubview(scanEffectView)
        self.view.addSubview(scanLabel)
        self.mainNav.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
    }

    
    @IBOutlet weak var imageScanned: UIImageView!
    
    lazy var scanEffectView: UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: self.view.frame.midX - 25.0, y: self.buttonView.frame.midY - 35.0, width: 50.0, height: 50.0)
        button.setImage(UIImage(named: "scan icon"), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action:#selector(self.Scan(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var scanLabel: UILabel = {
       let label = UILabel(frame: CGRect(x: 20.0, y: self.scanEffectView.frame.maxY, width: self.view.frame.width - 40.0, height: self.view.frame.maxY - self.scanEffectView.frame.maxY))
        label.text = "Scan"
        label.textAlignment = .center
        label.textColor = .white
        return label
    }()
    
    @IBAction func Scan(_ sender: UIButton) {
        print("sender state is -> \(sender.state)")
        let nextVC = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "scanningVC")
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.dismiss(animated: true, completion: nil);
    }
    
    @IBAction func Album(_ sender: AnyObject) {
        print("Album has been pushed")
    }
    
    @IBAction func History(_ sender: AnyObject) {
        print("History has been pushed")
        let nextVC2 = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "History")
        self.navigationController?.pushViewController(nextVC2, animated: true)
    }
    
}
    



