//
//  ListDataViewController.swift
//  CustomCamera
//
//  Created by Ihwan ID on 30/05/20.
//  Copyright © 2020 Sufiandy Elmy. All rights reserved.
//

import UIKit

class ListDataViewController: UIViewController {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let data = CoreDataManager.shared.fetchWastes() else { return }
        name.text = data.last?.name
        image.image = UIImage(data: data.last!.image!)
    }
    
    
    
}
