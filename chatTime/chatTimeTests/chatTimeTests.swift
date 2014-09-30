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
        let testRequest = Utils.getRequest("login")!
        println("================================")
        println(testRequest.getURL())
        
        XCTAssert(testRequest.getURL() == "http://192.168.0.100:8080/tokenTest/user/userLogin?nickorphone=&password=", "wut")
        
        testRequest.setParamValue("nickorphone", value: "peach")
        testRequest.setParamValue("password", value: "123456")
        
        
        XCTAssert(testRequest.getURL() == "http://192.168.0.100:8080/tokenTest/user/userLogin?nickorphone=peach&password=123456", "wut")

    }
    
    func testMD5(){
        let source : String = "secretpasscode\n";
        XCTAssert(source.md5 == "7571af3ff2620c360917bba8201d9d94", "wut md5");
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
