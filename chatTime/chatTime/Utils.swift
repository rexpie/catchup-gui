//
//  Util.swift
//  chatTime
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

public var placeholderImage : UIImage?

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
            var needToken = requests[reqName]["needToken"].bool
            if (needToken == nil)
            {
                needToken = false
            }
            
            if(needToken!)
            {
                var defaults = NSUserDefaults.standardUserDefaults()
                var token : AnyObject? = defaults.objectForKey("token")
                var id : AnyObject? = defaults.objectForKey("id")
                
                if ( token == nil || id == nil)
                {
                    //missing cache, need to request for token
                    if (Utils.refreshToken())
                    {
                        // successful token refresh
                        token = defaults.objectForKey("token") as String?
                        id = defaults.objectForKey("id") as String?
                        
                        let tokenParam = Param(name: "token", value: token! as String, isOptional: false)
                        let idParam = Param(name: "id", value: id! as String, isOptional: false)
                        
                        params.append(tokenParam)
                        params.append(idParam)
                    }
                    else
                    {
                        //TODO add view controller show
                        // nope, then login again
                    }
                }
                else
                {
                    let tokenParam = Param(name: "token", value: token! as String, isOptional: false)
                    let idParam = Param(name: "id", value: String(id! as Int), isOptional: false)
                    
                    params.append(tokenParam)
                    params.append(idParam)
                    
                }
            }
            return params
        }
        
        return nil
    }
    
    public class func getRequest( reqName: String ) -> Request?{
        
        if let reqString = requests[reqName]["req"].string{
            if let params = getParams(reqName){
                var request: Request = Request(reqString: reqString, params: params)
                return request
            }

        }
        return nil
    }
    
    public class func md5(input: String) -> String {
        return (input + SALT).md5
    }
    
    public class func refreshToken() -> Bool {
        var defaults = NSUserDefaults.standardUserDefaults()
        var token = defaults.objectForKey("nickorphone") as String?
        var id = defaults.objectForKey("password") as String?
        
        if (token != nil && id != nil){
            let request: Request = getRequest("login")!
            RequestHelper.sendRequest(request, delegate: nil)
        }
        return false
    }
    
    public class func getPlaceholderImageLarge() -> UIImage{
        if (placeholderImage == nil){
            placeholderImage = UIImage(named: PLACE_HOLDER_IMAGE_NAME)!
        }
        return placeholderImage!
    }
    
}

extension String  {
    var md5: String! {
        let str = self.cStringUsingEncoding(NSUTF8StringEncoding)
        let strLen = CC_LONG(self.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.alloc(digestLen)
        
        CC_MD5(str!, strLen, result)
        
        var hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.destroy()
        
        return String(format: hash)
    }
}
