//
//  LoginViewController.swift
//  chatTime
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, ResponseHandler{

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
        
        // TODO: add check
        let loginRequest = Utils.getRequests("login")!
        loginRequest.setParamValue("nickorphone", value: thePhoneName)
        loginRequest.setParamValue("password", value: thePassword)
        
        RequestHelper.sendRequest(loginRequest, delegate: self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func handelResponse(operation: AFHTTPRequestOperation, responseObject : AnyObject!) {
        println("Success")
        println("\(responseObject.description)")
        
        let dict = responseObject as NSDictionary
        
        let json = JSONValue(dict)
        
        let id = json["id"].integer
        let token = json["token"].string!
        let status = json["status"].string!
        println("id: \(id)")
        println("token: \(token)")
        println("status: \(status)")
        
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(token, forKey: "token")

    }
    
    
    func handelFailure(operation: AFHTTPRequestOperation, responseObject : AnyObject!) {
        println("Failure")
        
        let dict = responseObject as NSDictionary
        let json = JSONValue(dict)
        
        let status = json["status"].string!
        println(status) 
        
    }
    
    
    func handelError(operation: AFHTTPRequestOperation, error: NSError!) {
        println("Error")
        println(error.description)

    }

    @IBAction func unwindToLoginViewController(segue: UIStoryboardSegue)
    {
    }

}
