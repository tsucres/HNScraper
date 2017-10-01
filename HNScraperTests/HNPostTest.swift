//
//  HNPostTest.swift
//  HNScraperTests
//
//  Created by Stéphane Sercu on 29/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import XCTest
@testable import HNScraper

class HNPostTest: XCTestCase {
    
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
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testDefaultPostParsing() {
        // TODO: This tests nothing about upvoteURL, points,
        let exp = expectation(description: "All important field of HNPost are correctly parsed")
        HNScraper.shared.getPost(ById: "15364896", buildHierarchy: false) { (post, comments, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(post)
            XCTAssertEqual(post?.title, "Cloudflare Workers: Run JavaScript Service Workers at the Edge")
            XCTAssertEqual(post?.username, "thomseddon")
            XCTAssertEqual(post?.urlDomain, "blog.cloudflare.com")
            XCTAssertGreaterThan(post!.points, 0)
            XCTAssertGreaterThan(post!.commentCount, 0)
            XCTAssertEqual(post?.commentCount, comments.count)
            XCTAssertEqual(post?.type, .defaultType)
            XCTAssertEqual(post?.url, URL(string:"https://blog.cloudflare.com/introducing-cloudflare-workers/"))
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testAskPostParsing() {
        let exp = expectation(description: "All important field of HNPost are correctly parsed")
        HNScraper.shared.getPost(ById: "15361048", buildHierarchy: false) { (post, comments, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(post)
            XCTAssertEqual(post?.title, "Ask HN: Library recommendations for a Client / Server project (all Java)")
            XCTAssertEqual(post?.username, "HockeyPlayer")
            XCTAssertEqual(post?.urlDomain, "news.ycombinator.com")
            XCTAssertGreaterThan(post!.points, 0)
            XCTAssertGreaterThan(post!.commentCount, 0)
            XCTAssertEqual(post?.commentCount, comments.count - 1) // The first comment is the Ask
            XCTAssertEqual(post?.type, .askHN)
            XCTAssertEqual(post?.url, URL(string:"https://news.ycombinator.com/item?id=15361048"))
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testJobPostParsing() {
        
    }
    
    func testShowPostParsing() {
        
    }
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
