//
//  RequestHandler.swift
//  chatTime
//
//  Created by 陈静 on 14-9-30.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

protocol ResponseHandler{
    func handelResponse(operation: AFHTTPRequestOperation, responseObject : AnyObject!)
    func handelFailure(operation: AFHTTPRequestOperation, responseObject : AnyObject!)
    func handelError(operation: AFHTTPRequestOperation, error: NSError!)
}


class RequestHelper{

     class func sendRequest(request: Request, delegate :ResponseHandler? ){
        let url : NSURL = request.getURL()!
        let urlRequest : NSURLRequest = NSURLRequest(URL: url)
        println(url.description)
        
        let operation: AFHTTPRequestOperation = AFHTTPRequestOperation(request: urlRequest)
        operation.responseSerializer = AFJSONResponseSerializer(readingOptions: NSJSONReadingOptions.AllowFragments)
        
        operation.setCompletionBlockWithSuccess(
            { (operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
                let dict = responseObject as NSDictionary
                let json = JSONValue(dict)
                let status = json["status"].string!
                println(status)
                if ( delegate != nil)
                {
                    if (status == "OK")
                    {
                        delegate!.handelResponse(operation, responseObject: responseObject)
                    }
                    else
                    {
                        delegate!.handelFailure(operation, responseObject: responseObject)
                    }
                }
            },
            failure:{ (operation: AFHTTPRequestOperation!, error:NSError!) -> Void in
                if ( delegate != nil)
                {
                    delegate!.handelError(operation, error: error)
                }
        })
        
        operation.start()

    }
}