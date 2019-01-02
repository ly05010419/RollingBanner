//
//  RollingBanner.swift
//  RollingBanner
//
//  Created by LiYong on 2019/1/1.
//  Copyright © 2019年 Liyong. All rights reserved.
//

import UIKit

protocol RollingBannerDelegate {
    func imageDidSelected(index:Int)
}

class RollingBanner: UIScrollView ,UIScrollViewDelegate {
    
    //    视差效果p比例调节
    private let portion = 0.6
    
    private let leftView = UIView()
    private let midView = UIView()
    private let rightView = UIView()
    
    private var selectedIndex = 1
    
    private let leftImageView = UIImageView()
    private let midImageView = UIImageView()
    private let rightImageView = UIImageView()
    
    var rollingBannerDelegate:RollingBannerDelegate?
    
    private var imagesArray:NSMutableArray!
    
    var source:[UIImage]!{
        
        didSet{
            imagesArray = NSMutableArray(array: source)
            setupViews()
        }
    }
    
    
    //    初始化三个UIView 放在scrollView上
    func setupViews(){
        
        self.delegate = self
        
        let scrollWidth = self.frame.width
        let scrollHeight = self.frame.height
        
        self.contentSize = CGSize(width: scrollWidth*CGFloat(source!.count), height:scrollHeight )
        
        
        leftView.frame = CGRect(x: CGFloat(1-portion)*scrollWidth, y: 0, width: scrollWidth, height: scrollHeight)
        leftView.clipsToBounds = true
        leftView.backgroundColor = UIColor.clear
        self.addSubview(leftView)
        
        
        
        rightView.frame = CGRect(x: CGFloat(1+portion)*scrollWidth, y: 0, width: scrollWidth, height: scrollHeight)
        rightView.clipsToBounds = true
        rightView.backgroundColor = UIColor.clear
        self.addSubview(rightView)
        
        
        
        midView.frame = CGRect(x: scrollWidth, y: 0, width: scrollWidth, height: scrollHeight)
        midView.clipsToBounds = true
        midView.backgroundColor = UIColor.clear
        self.addSubview(midView)
        
        //        透视查看原理
        //        leftView.backgroundColor = UIColor.red
        //        rightView.backgroundColor = UIColor.yellow
        //        midView.backgroundColor = UIColor.blue
        //        leftView.alpha = 0.5
        //        rightView.alpha = 0.5
        //        midView.alpha = 0.5
        
        
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        
        
        setupImageView()
    }
    
    //    UIView上添加ImageView 按顺序 0 1 2
    func setupImageView(){
        
        self.leftImageView.frame = leftView.bounds
        addTapGesture(self.leftImageView)
        leftImageView.image = imagesArray[0] as? UIImage
        
        
        self.midImageView.frame = midView.bounds
        addTapGesture(self.midImageView)
        midImageView.image = imagesArray[1] as? UIImage
        
        self.rightImageView.frame = rightView.bounds
        addTapGesture(self.rightImageView)
        rightImageView.image = imagesArray[2] as? UIImage
        
        
        leftView.addSubview(leftImageView)
        rightView.addSubview(rightImageView)
        midView.addSubview(midImageView)
        
        //初始化 或者 滑动结束 图片1永远放在中间
        self.setContentOffset(CGPoint(x: self.frame.width, y: 0), animated: false)
    }
    
    // 滑动过程细节
    // 原本的ScrollView如下
    // UIView                 |---UIView0---             ---UIView2---|
    // UIImage                |-----图片0----             -----图片2----|
    // UIView                 |             ---UIView1---             |
    // UIImage                |             -----图片1---—             |
    
    
    // 视差效果，初始化配置如下
    // UIView0往右放置了100像素 UIView2初始化向右放置了100像素
    
    // UIView                 |  ---UIView0---       ---UIView2---    |
    // UIImage                |  -----图片0----       -----图片2----    |
    // UIView                 |             ---UIView1---             |
    // UIImage                |             -----图片1---—             |
    
    // 手指向右滑动，UIView0逐渐从左边出现，同时UIView0向左移动100像素回到（0，0）点，图片1也向左移动移动100像素，制造视差效果。
    
    // UIView                 |---UIView0---         ---UIView2---    |
    // UIImage                |-----图片0----         -----图片2----    |
    // UIView                 |             ---UIView1---             |
    // UIImage                |             图片1---—                  |
    
    // 总结：UIVIew1 始终不移动，在滑动中通过操纵UIVIew0，UIVIew2和图片1 制造视差效果。
    public func scrollViewDidScroll(_ scrollView: UIScrollView){
        
        // print("scrollViewDidScroll")
        
        let moveX = scrollView.contentOffset.x - self.bounds.size.width;
        
        //绝对值 等于边长 表示滑动完成了， 改变image数组的位置，重置图片即可。
        if abs(moveX) >= self.bounds.size.width{
            
            calculateSelectedIndex(moveX)
            
            // 判断滑动方向是左边 还是 右边
            if moveX < 0 {
                imagesGoRight()
            }else{
                imagesGoLeft()
            }
            //重置图片
            setupImageView();
            
            return;
        }
        
        let targetX = (moveX*CGFloat(1-portion))
        
        self.midImageView.frame.origin.x = +targetX
        
        leftView.frame.origin.x =  self.bounds.size.width*CGFloat(1-portion) + targetX
        rightView.frame.origin.x =  self.bounds.size.width*CGFloat(1+portion) + targetX
        
    }
    
    //    计算最终停止的位置
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>){
        //print("scrollViewWillEndDragging")
        
        if self.isPagingEnabled {
            return
        }
        
        var targetX:CGFloat = 0.0
        
        if velocity.x == 0 {//用户松手
            
            //计算回到哪页： 左边图片出现一半，去第0页。右边视图多于一半出现，去第2页。否则回到中间。
            let page = Int((scrollView.contentOffset.x+self.bounds.size.width/2)/self.bounds.size.width)
            targetX = CGFloat(page) * self.bounds.size.width
        }else{//用户滑动
            
            if velocity.x < 0{//右滑 去第0页
                targetX = 0.0
            }else{//左滑 去第2页
                targetX = self.bounds.size.width * CGFloat(2)
            }
        }

        let point = CGPoint (x: targetX, y: targetContentOffset.pointee.y)
        
        targetContentOffset.pointee = point
        
    }
    
    
    //    往右滑动， 最后的照片 放在第一个位置
    func imagesGoRight(){
        let s1 = imagesArray.lastObject
        imagesArray.removeObject(at: imagesArray.count-1)
        
        imagesArray.insert(s1 as Any, at: 0)
    }
    //    往左滑动 第一个照片 放在最后一个位置
    func imagesGoLeft(){
        let s1 = imagesArray.firstObject
        imagesArray.removeObject(at: 0)
        
        imagesArray.add(s1 as Any)
    }
    
//    计算中间的图片是第几张图片，响应点击事件传递selectedIndex
    func calculateSelectedIndex(_ moveX:CGFloat){
        if moveX < 0 {
            self.selectedIndex -= 1
        }else{
            self.selectedIndex += 1
        }
        
        if self.selectedIndex < 0{
            
            self.selectedIndex = imagesArray.count-1
        }else if self.selectedIndex > imagesArray.count-1{
            
            self.selectedIndex = 0
        }
        
    }
    
    func addTapGesture(_ imageView:UIImageView){
        imageView.isUserInteractionEnabled = true
        let tap  = UITapGestureRecognizer(target: self, action: #selector(tapAction(tap:)))
        imageView.addGestureRecognizer(tap)
        
    }
    
    @objc func tapAction(tap:UITapGestureRecognizer){
        
        rollingBannerDelegate?.imageDidSelected(index: selectedIndex)
    }
    
    
    
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){
        //        print("scrollViewWillBeginDecelerating")
        self.isUserInteractionEnabled = false
    }
    
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //        print("scrollViewDidEndDecelerating")
        self.isUserInteractionEnabled = true
        
    }
    
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        //            print("scrollViewWillBeginDragging")
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool){
        //        print("scrollViewDidEndDragging")
    }
    
    
    
    
}



