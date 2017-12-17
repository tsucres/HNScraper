//
//  HNLoginTest.swift
//  HNScraper
//
//  Created by Stéphane Sercu on 25/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import XCTest
@testable import HNScraper

//
//
class HNLoginTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        cleanCookies()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        cleanCookies()
        
    }
    func cleanCookies() {
        let cookieStore = HTTPCookieStorage.shared
        for cookie in cookieStore.cookies ?? [] {
            cookieStore.deleteCookie(cookie)
        }
        HNLogin.shared.logout()
    }
    
    func testGoodLogin() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let exp = expectation(description: "Correct login with abdurhtl")
        HNLogin.shared.login(username: "abdurhtl", psw: "!Bullshit?Psw$", completion: {(user, cookie, error) -> Void in
            XCTAssertNotNil(cookie)
            XCTAssertEqual(user?.username, "abdurhtl")
            exp.fulfill()
        })
        let exp2 = expectation(description: "Correct login with testHNScrapper")
        HNLogin.shared.login(username: "testHNScrapper", psw: "&$!?èé%`ç\"'-some_thing", completion: {(user, cookie, error) -> Void in
            XCTAssertNotNil(cookie)
            XCTAssertEqual(user?.username, "testHNScrapper")
            exp2.fulfill()
        })
        
        wait(for: [exp, exp2], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testBadPasswordLogin() {
        let exp = expectation(description: "not logged in")
        HNLogin.shared.login(username: "who?", psw: "random", completion: {(user, cookie, error) -> Void in
            XCTAssertNil(user)
            XCTAssertNil(cookie)
            XCTAssertEqual(error, HNLogin.HNLoginError.badCredentials)
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    
    func testIsLoggedIn() {
        let exp = expectation(description: "isLoggedIn() returns true")
        XCTAssertFalse(HNLogin.shared.isLoggedIn())
        HNLogin.shared.login(username: "abdurhtl", psw: "!Bullshit?Psw$", completion: {(user, cookie, error) -> Void in
            XCTAssertTrue(HNLogin.shared.isLoggedIn())
            exp.fulfill()
            
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
        
    }
    
}
