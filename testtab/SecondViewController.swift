//
//  SecondViewController.swift
//  testtab
//
//  Created by 夏嘉斌 on 9/10/14.
//  Copyright (c) 2014 夏嘉斌. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
                            
    @IBOutlet weak var superView: UIView!
    
    @IBOutlet weak var catImage: UIImageView!
    
    @IBOutlet weak var respondArea: UIView!
    
    var angle :CGFloat = CGFloat(0.1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        catImage.image = UIImage(named: "cat" )

        let gesture = UISwipeGestureRecognizer(target: self, action: "swipe:")
        gesture.direction = UISwipeGestureRecognizerDirection.Right
        respondArea.addGestureRecognizer(gesture)
    
    }
    
    func swipe(guesture: UIGestureRecognizer){
        self.superView.transform = CGAffineTransformMakeRotation(self.angle)
        self.angle = self.angle.advancedBy(CGFloat(0.1))
        self.superView.setNeedsDisplay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

