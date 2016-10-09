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
    
    override func viewDidLoad() {
        self.tableView.backgroundView?.backgroundColor = UIColor(red: 38/255, green: 37/255, blue: 46/255, alpha: 1.0)
    }
    
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

class HistoryCell: UITableViewCell {
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var content: UITextView!{
        didSet{
            self.content.text = ""
        }
    }
    
    func set(productImage: UIImage, content: String){
        DispatchQueue.main.async {
            self.productImage.image = productImage
            self.content.text = content
        }
    }
}
