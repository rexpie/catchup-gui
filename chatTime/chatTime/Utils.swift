//
//  Util.swift
//  chatTime
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

public class Utils: NSObject {
    
    public class func getBaseURL() -> String{
        return PROTOCOL + HOST + ":" + PORT + "/" + WEB_ROOT + "/"
    }
    
    public class func getParamSeparator() -> String{
        return PARAM_SEPARATOR
    }
    
    public class func getParams(reqName: String) -> [Param]? {
        var params : [Param] = []
        if let paramConfigs = requests[reqName]["params"].array {
            for paramConfig in paramConfigs{
                if let name = paramConfig["name"].string {
                    let param = Param(name: name, isOptional: paramConfig["optional"].bool!)
                    params.append(param)
                }
            }
            return params
        }
        
        return nil
    }
    
    public class func getRequests( reqName: String ) -> Request?{
        
        if let reqString = requests[reqName]["req"].string{
            if let params = getParams(reqName){
                var request: Request = Request(reqString: reqString, params: params)
                return request
            }

        }
        return nil
    }
    
}
