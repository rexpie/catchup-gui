//
//  Constants.swift
//  chatTime
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit


public let PROTOCOL = "http://"
public let HOST = "192.168.1.4"
public let PORT = "8080"

public let WEB_ROOT = "tokenTest"
public let PARAM_SEPARATOR = "?"

public let SALT = "扯淡=chatTime=茶谈"

let requestsPath = NSBundle.mainBundle().pathForResource("Requests", ofType: "json")

let requestsConfig = NSFileManager.defaultManager().contentsAtPath(requestsPath!)

let requests = JSONValue(requestsConfig)


let messagesPath = NSBundle.mainBundle().pathForResource("Messages.cn", ofType: "json")

let messagesConfig = NSFileManager.defaultManager().contentsAtPath(messagesPath!)

let messages = JSONValue(messagesConfig)



public class Constants: NSObject {
    
    
    
}

