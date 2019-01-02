//
//  ViewController.swift
//  RollingBanner
//
//  Created by LiYong on 2019/1/1.
//  Copyright © 2019年 Liyong. All rights reserved.
//

import UIKit

class ViewController: UIViewController, RollingBannerDelegate{
   
    @IBOutlet weak var rollingBanner: RollingBanner!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let images = [UIImage(named: "0")!,UIImage(named: "1")!,UIImage(named: "2")!]
        
        rollingBanner.source = images
        rollingBanner.rollingBannerDelegate = self

    }
    
    
    func imageDidSelected(index: Int) {
        print("imageDidSelected:\(index)")
    }


}

