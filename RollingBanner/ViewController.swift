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
        
        let images = [UIImage(named: "0")!,UIImage(named: "1")!,UIImage(named: "2")!,UIImage(named: "3")!]
        
        rollingBanner.source = images
        rollingBanner.rollingBannerDelegate = self
    }
    
    
    
    @IBAction func buttonAction(_ sender: UIButton) {
        rollingBanner.isPagingEnabled = !rollingBanner.isPagingEnabled
        
        if rollingBanner.isPagingEnabled {
            sender.setTitle("自定义效果关闭", for: UIControl.State.normal)
        }else{
            sender.setTitle("自定义效果开启", for: UIControl.State.normal)
        }
    }
    
    
    
    @IBAction func decelerationRateAction(_ sender: UIButton) {

        
        if rollingBanner.decelerationRate == .fast {

            sender.setTitle("正常阻力", for: UIControl.State.normal)
            
            rollingBanner.decelerationRate = .normal
        }else{
            sender.setTitle("加大阻力", for: UIControl.State.normal)
            
            rollingBanner.decelerationRate = .fast
        }
    }
    
    func imageDidSelected(index: Int) {
        print("imageDidSelected:\(index)")
    }


}

