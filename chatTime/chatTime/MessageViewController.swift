//
//  SecondViewController.swift
//  chatTime
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let storyboard = self.storyboard!
        let segue = UIStoryboardSegue(identifier: "loginSegue", source: self, destination: storyboard.instantiateViewControllerWithIdentifier("loginViewController") as UIViewController)
        performSegueWithIdentifier("loginSegue", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        println("logging in")
    }

    
}

