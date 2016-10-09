//
//  History.swift
//  UI
//
//  Created by MaoMaos on 10/8/16.
//  Copyright © 2016 MaoMaos. All rights reserved.
//

import Foundation
import UIKit

class History: UITableViewController{
    
    
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
    
}

