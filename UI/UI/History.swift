//
//  History.swift
//  UI
//
//  Created by MaoMaos on 10/8/16.
//  Copyright © 2016 MaoMaos. All rights reserved.
//

import Foundation
import UIKit

class History: UIViewController{
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.title = "History"
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Album", style: .plain, target: self, action: #selector(self.Album(_:)))
    }
    
    func Album(_ sender: AnyObject) {
        print("Album has been pushed")
    }
   
    
    @IBAction func Scan(_ sender: UIButton) {
        print("sender state is -> \(sender.state)")
        let nextVC = UIStoryboard(name: "Main" , bundle: nil).instantiateViewController(withIdentifier: "scanningVC")
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

