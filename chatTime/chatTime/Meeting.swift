//
//  Meeting.swift
//  chatTime
//
//  Created by 陈静 on 14-10-6.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit

class Meeting {
    var meetingId: NSNumber?
    var image: UIImage = UIImage(named: "item1")! // TODO use default image
    var description: String?
    var distance: Double?
    var name: String?
    var shopName: String?
    var job: String?
    var company: String?
    var ownerGender: String?
    var building: String?
    var genderConstraint: String?
    var age: Int?
    var ownerID: NSNumber?
    var ownerPhotoID: NSNumber?
    var pageNum: Int?
    var index: Int?
    
    init(data: JSONValue){
        description = data["description"].string
        distance = data["distance"].double
        name = data["name"].string
        shopName = data["shopName"].string
        job = data["job"].string
        company = data["company"].string
        ownerGender = data["ownerGender"].string
        building = data["building"].string
        genderConstraint = data["genderConstraint"].string
        age = data["age"].integer
        ownerID = data["ownerID"].number
        ownerPhotoID = data["ownerPhotoID"].number
        meetingId = data["meetingId"].number
        pageNum = data["pageNum"].number
        index = data["index"].number
        
    }
}
