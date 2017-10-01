//
//  RessourceFetcherTest.swift
//  HNScraperTests
//
//  Created by Stéphane Sercu on 29/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import XCTest
@testable import HNScraper
class RessourceFetcherTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetJson() {
        let exp = expectation(description: "No error & valid parsed data")
        RessourceFetcher.shared.getJson(url: "https://httpbin.org/headers") { (json, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(json)
            XCTAssertNotNil(json!["headers"] as? [String: String])
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    func testPostRequest() {
        let exp = expectation(description: "Get the post data back as response in json format")
        let bodyData = "attr1=val1&attr2=val2".data(using: .utf8)
        let cookie = HTTPCookie(properties: [.value:"value", .name:"name", .domain:"httpbin.org", .path:"."])
        
        RessourceFetcher.shared.post(urlString: "https://httpbin.org/post", data: bodyData!, cookies: [cookie!]) { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(data)
            let json:[String: Any]? = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            XCTAssertNotNil(json ?? nil)
            XCTAssertEqual((json!["form"] as! [String: String])["attr1"], "val1")
            XCTAssertEqual((json!["form"] as! [String: String])["attr2"], "val2")
            XCTAssertEqual(((json!["headers"] as! [String:String])["Cookie"]), "name=value")
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
        
    }
    
    func testGetRequest() {
        let expWithoutCookie = expectation(description: "Get the post data back as response in json format")
        let expWithCookie = expectation(description: "Get the post data back as response in json format (containing a cookies field)")
        let cookie = HTTPCookie(properties: [.value:"value", .name:"name", .domain:"httpbin.org", .path:"."])
        RessourceFetcher.shared.get(urlString: "https://httpbin.org/cookies", cookies: [cookie!]) { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(data)
            let json:[String: Any]? = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            XCTAssertNotNil(json ?? nil)
            XCTAssertEqual(json!["cookies"] as! [String:String], ["name":"value"])
            expWithCookie.fulfill()
        }
        RessourceFetcher.shared.get(urlString: "https://httpbin.org/cookies") { (data, response, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(response)
            XCTAssertNotNil(data)
            let json:[String: Any]? = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! [String: Any]
            XCTAssertNotNil(json ?? nil)
            expWithoutCookie.fulfill()
        }
       wait(for: [expWithoutCookie, expWithCookie], timeout: HNScraperTest.defaultTimeOut)
        
    }
    
    func testBadGetRequest() {
        let exp = expectation(description: "Get a invalidURL error")
        RessourceFetcher.shared.get(urlString: "where?") { (data, response, error) in
            XCTAssertEqual(error, .invalidURL)
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
        
    }
    
    
    
}
