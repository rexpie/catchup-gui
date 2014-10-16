//
//  Request.swift
//  chatTime
//
//  Created by 陈静 on 14-9-23.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

public class Request {
    public var baseURL:String = Utils.getBaseURL()
    public var reqString:String!
    public var params:[Param]!
    
    public func getURLString() -> String{
        
        var url = baseURL + reqString + PARAM_SEPARATOR
        
        var paramString : [String] = []
        
        for param in params
        {
            if ( param.isOptional && (param.value == nil || param.value == ""))
            {
                continue
            }
            paramString.append(param.toString())
        }
        
        url += join("&", paramString)
        
        return url
    }
    
    public func getURL() -> NSURL?
    {
        let url = NSURL(string: getURLString())
        return url
    }
    
    public func getURLRequest() -> NSURLRequest{
        return NSURLRequest(URL: getURL()!)
    }
    
    public init(reqString: String!, params: [Param]!){
        self.reqString = reqString
        self.params = params
    }
    
    public func setParamValue(name: String, value: String){
        for param in params{
            if (param.name != nil && param.name == name){
                param.value = value
                break
            }
        }
    }
}


public class Param {
    var name: String!
    var value: String!
    var isOptional: Bool = false
    
    public init (name: String, value: String, isOptional: Bool){
        self.name = name
        self.isOptional = isOptional
        self.value = value
    }
    
    public init (name: String, isOptional: Bool){
        self.name = name
        self.isOptional = isOptional
    }
    
    public func toString() -> String{
        if (self.value != nil) {
            return self.name + "=" + self.value
        } else {
            if (self.isOptional == false && (self.value == nil || self.value == "")){
                //
                println("ERROR, empty non-optional param: \(self.name)")
            }
            return self.name + "="
        }
    }
    
}