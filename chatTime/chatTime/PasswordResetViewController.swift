//
//  PasswordResetViewController.swift
//  chatTime
//
//  Created by 陈静 on 14-10-3.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

class PasswordResetViewController: UIViewController, ResponseHandler {

    @IBOutlet weak var getValidationCodeButton: UIButton!
    @IBOutlet weak var nickOrPhone: UITextField!
    
    @IBOutlet weak var validationCode: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func getValidationCode(sender: AnyObject) {
        let theNickOrPhone = nickOrPhone.text

        let getValidationCodeRequest = Utils.getRequest("validateReset")!
        getValidationCodeRequest.setParamValue("nickorphone", value: theNickOrPhone)

        RequestHelper.sendRequest(getValidationCodeRequest, delegate: self)

    }

    @IBAction func doResetPassword(sender: AnyObject) {
        let theNickOrPhone = nickOrPhone.text
        let theNewPassword = Utils.md5(newPassword.text)
        let theCode        = validationCode.text
        
        let resetPasswordRequest = Utils.getRequest("resetPassword")!
        resetPasswordRequest.setParamValue("nickorphone", value: theNickOrPhone)
        resetPasswordRequest.setParamValue("code", value: theCode)
        resetPasswordRequest.setParamValue("newPassword", value: theNewPassword)
        
        RequestHelper.sendRequest(resetPasswordRequest, delegate: self)
    }
    
    func handleResponse(operation: AFHTTPRequestOperation, responseObject : AnyObject!){
        println("response")

        let url = operation.request.description
        println(url)
        //TODO
    }
    func handleFailure(operation: AFHTTPRequestOperation, responseObject : AnyObject!){
        //TODO
        println("Failure")

        let dict = responseObject as NSDictionary
        let json = JSONValue(dict)
        let status = json["status"].string!
        var alert = UIAlertController(title: "Alert", message: status, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func handleError(operation: AFHTTPRequestOperation, error: NSError!){
        println("Error")
        //TODO
    }
}
