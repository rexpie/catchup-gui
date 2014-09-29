//
//  LoginViewController.swift
//  chatTime
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var phoneName: UITextField!
    
    @IBOutlet weak var password: UITextField!

    
    @IBAction func unwindLoginView(sender: AnyObject) {
        performSegueWithIdentifier("unwindFromLogin", sender: self)
    }
    
    @IBAction func register(sender: AnyObject) {
        performSegueWithIdentifier("registerSegue", sender: self)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        let thePhoneName = phoneName.text
        let thePassword = password.text
        
        let loginRequest = Utils.getRequests("login")!
        loginRequest.setParamValue("nickorphone", value: thePhoneName)
        loginRequest.setParamValue("password", value: thePassword)
        
        let url : NSURL = loginRequest.getURL()!
        let urlRequest : NSURLRequest = NSURLRequest(URL: url)
        
        
        let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: urlRequest)
        operation.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments)
        
        operation.setCompletionBlockWithSuccess(
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                println("Success")
                println("JSON: " + "\(responseObject)")
            },
            failure:{ (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                println("Failure")
                println(error.description)
        })
        
        operation.start()
        
//        println(thePhoneName)
//        println(thePassword)
        
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue)
    {
    }

}
