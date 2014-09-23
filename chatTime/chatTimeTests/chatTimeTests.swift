//
//  chatTimeTests.swift
//  chatTimeTests
//
//  Created by 陈静 on 14-9-21.
//  Copyright (c) 2014年 Team chatTime. All rights reserved.
//

import UIKit
import XCTest
import chatTime

class chatTimeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testURL(){
        let testRequest = Utils.getRequests("login")!
        println("================================")
        println(testRequest.getURL())
        
        XCTAssert(testRequest.getURL() == "http://192.168.0.100:8080/tokenTest/user/userLogin?nickorphone=&password=", "wut")
        
        testRequest.setParamValue("nickorphone", value: "peach")
        testRequest.setParamValue("password", value: "123456")
        
        
        XCTAssert(testRequest.getURL() == "http://192.168.0.100:8080/tokenTest/user/userLogin?nickorphone=peach&password=123456", "wut")

    }
    
}
