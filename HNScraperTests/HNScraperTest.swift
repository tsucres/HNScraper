//
//  HNScraperTest.swift
//  HNScraperTests
//
//  Created by Stéphane Sercu on 25/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import XCTest
@testable import HNScraper

class HNScraperLoginNeededTest: XCTestCase {
    override func setUp() {
        super.setUp()
        let exp = expectation(description: "Successfull login")
        login(completion: {(success) -> Void in
            XCTAssertTrue(success, "HNLogin is probably broken")
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    

    func login(completion: @escaping ((Bool) -> Void)) {
        if !HNLogin.shared.isLoggedIn() {
            let username = HNScraperTest.validCredential["username"]!
            let password = HNScraperTest.validCredential["password"]!
            HNLogin.shared.login(username: username, psw: password, completion: {(user, cookie, error) -> Void in
                completion(error == nil)
            })
        } else {
            completion(true)
        }
    }
    
    func getFirstPost(completion: @escaping ((HNPost?) -> Void)) {
        HNScraper.shared.getPostsList(page: .news, completion: {(posts, linkForMore, error) -> Void in
            XCTAssertGreaterThan(posts.count, 0, "The getPostLists method is probably broken. Or hackernews is down...")
            completion(posts[0])
        })
    }
    func getPost(id: String, completion: @escaping ((HNPost?) -> Void)) {
        HNScraper.shared.getPost(ById: id) { (post, comments, error) in
            XCTAssertNotNil(post, "The getPostbyId method is probably broken. Or hackernews is down...")
            completion(post)
        }
    }
    
    // Try to upvote the first post of the home page
    func testUpvotePost() {
        let exp = expectation(description: "get no error")
        getFirstPost() { (post) in
            HNScraper.shared.upvote(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error)
                exp.fulfill()
            })
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    // Try to upvote the first post of the home page after it upvotes it.
    func testUpvoteUpvotedPost() {
        let exp = expectation(description: "get no error")
        getFirstPost(completion: {(post) -> Void in
            HNScraper.shared.upvote(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error, "If this fails, it probably means that the upvotePost method is broken.")
                HNScraper.shared.upvote(Post: post!, completion: {(error) -> Void in
                    XCTAssertNil(error)
                    exp.fulfill()
                })
                
            })
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    func testUpvoteBadPostId() {
        let post = HNPost()
        post.id = "where?"
        post.upvoteAdditionURL = "somewhereFarFarAway"
        let exp = expectation(description: "get a invalidUrl error")
        HNScraper.shared.upvote(Post: post, completion: {(error) -> Void in
            XCTAssertEqual(error, .invalidURL)
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    func testFavoritePost() {
        let exp = expectation(description: "get no error")
        getFirstPost(completion: {(post) -> Void in
            HNScraper.shared.favorite(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error)
                exp.fulfill()
            })
        })
        wait(for: [exp], timeout: 2*HNScraperTest.defaultTimeOut)
    }
    func testUnFavoriteFavoritedPost() {
        let exp = expectation(description: "get no error")
        getFirstPost(completion: {(post) -> Void in
            HNScraper.shared.favorite(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error, "If this fails, it probably means that the favoritePost method is broken.")
                HNScraper.shared.unfavorite(Post: post!, completion: {(error) -> Void in
                    XCTAssertNil(error)
                    exp.fulfill()
                })
                
            })
        })
        wait(for: [exp], timeout: 3*HNScraperTest.defaultTimeOut)
    }
    func testUnFavoriteNonFavoritedPost() {
        let exp = expectation(description: "get no error")
        getPost(id: "15364646") { (post) in
            HNScraper.shared.unfavorite(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error)
                exp.fulfill()
            })
        }
        wait(for: [exp], timeout: 2*HNScraperTest.defaultTimeOut)
    }
    func testUnVoteVotedPost() {
        let exp = expectation(description: "get no error")
        getPost(id: "15350139") { (post) in
            HNScraper.shared.upvote(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error, "If this fails, it probably means that the upvotePost method is broken.")
                HNScraper.shared.unvote(Post: post!, completion: {(error) -> Void in
                    XCTAssertNil(error)
                    exp.fulfill()
                })
                
            })
        }
        wait(for: [exp], timeout: 200*HNScraperTest.defaultTimeOut)
    }
    func testUnvoteNonVotedPost() {
        let exp = expectation(description: "get no error")
        getPost(id: "15350139") { (post) in
            HNScraper.shared.unvote(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error)
                exp.fulfill()
            })
        }
        wait(for: [exp], timeout: 2*HNScraperTest.defaultTimeOut)
    }
    
    func testUpvoteComment() {
        let exp = expectation(description: "Get no error")
        getFirstPost() { (post) in // Will fail if the top post has no comments...
            HNScraper.shared.getComments(ForPost: post!) { (post, comments, error) in
                XCTAssertNil(error, "getComments methdod probably broken")
                XCTAssertGreaterThan(comments.count, 0)
                HNScraper.shared.upvote(Comment: comments[0], completion: { (error) in
                    XCTAssertNil(error)
                    HNScraper.shared.getComments(ForPost: post) { (post, comments, error) in
                        XCTAssertNil(error)
                        XCTAssertGreaterThan(comments.count, 0)
                        XCTAssertTrue(comments[0].upvoted)
                        exp.fulfill()
                    }
                    
                    
                })
            }
        }
        
        wait(for: [exp], timeout: 2*HNScraperTest.defaultTimeOut)
    }
    
    // TODO
    /// tests that the favorited attribute is correctly filled when parsing a post from the home page.
    /*func testFavoritedAttribute() {
        let exp = expectation(description: "the retrieved post has favorited=true")
        getFirstPost(completion: {(post) -> Void in
            HNScraper.shared.favorite(Post: post!, completion: {(error) -> Void in
                XCTAssertNil(error)
                self.getFirstPost(completion: { (post) in
                    XCTAssertNotNil(post?.favorited)
                    XCTAssertTrue((post?.favorited)!)
                    exp.fulfill()
                })
                
            })
        })
        wait(for: [exp], timeout: 2*HNScraperTest.defaultTimeOut)
    }*/
    
    func testHasLoggedInUserVotedOnPost() {
        
    }
    
    // Same test as in HNScraperTest, but at some point, there was a parsing error when the user was logged in, so I added this test here.
    func testGetUser() {
        let exp = expectation(description: "get a entirely filled HNUser instance")
        HNScraper.shared.getUserFrom(Username: HNScraperTest.validFilledUsername, completion: { (user, error) in
            XCTAssertEqual(user?.username, HNScraperTest.validFilledUsername)
            XCTAssertEqual(String(describing: user!.age!).prefix(7), "2010-08")
            XCTAssertNotEqual(user?.karma, 0)
            XCTAssertNotNil(user?.aboutInfo)
            XCTAssertNotEqual(user!.aboutInfo!, "")
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
}
class HNScraperTest: XCTestCase {
    static let defaultTimeOut: TimeInterval = 10
    static let validFilledUsername = "kposehn" // Chose him randomly
    static let invalidUsername = "ToBeOrNotToBeSureThatNoOneHasThatUsername" // *Resisting to the urge to create a new account with that username just to mess with these tests.*
    static let validCredential = ["username": "abdurhtl", "password": "!Bullshit?Psw$"]
    
    static let validPostId = "15331016"
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    
    func testGetUserByWrongUsername() {
        let exp = expectation(description: "Returns noSuchUser error")
        HNScraper.shared.getUserFrom(Username: HNScraperTest.invalidUsername, completion: {(user, error) -> Void in
            
            XCTAssertNil(user)
            XCTAssertEqual(error, HNScraper.HNScraperError.noSuchUser)
            exp.fulfill()
            
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetHomePage() {
        let exp = expectation(description: "get 30 items")
        HNScraper.shared.getPostsList(page: .news, completion: {(posts, linkForMore, error) -> Void in
            XCTAssertEqual(posts.count, 30)
            XCTAssertNotNil(linkForMore)
            XCTAssertNil(error)
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetAskHN() { // TODO: test askHN comment parsing
        let exp = expectation(description: "get 30 items")
        HNScraper.shared.getComments(ByPostId: "15465252") { (post, comments, error) in
            XCTAssertNil(error)
            XCTAssertEqual(comments.count, 1)
            XCTAssertGreaterThan(comments[0].text.count, 0)
            XCTAssertGreaterThan(comments[0].username.count, 0)
            XCTAssertGreaterThan((comments[0].replies[0] as! HNComment).text.count, 0)
            XCTAssertGreaterThan((comments[0].replies[0] as! HNComment).username.count, 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 100*HNScraperTest.defaultTimeOut)
    }

    func testGet90ItemsFromHomePage() {
        let exp = expectation(description: "get 90 items")
        HNScraper.shared.getPostsList(page: .news) { (posts, linkForMore, error) in
            XCTAssertEqual(posts.count, 30, "the getPostsList method is probably broken")
            XCTAssertNotNil(linkForMore, "the getPostsList method is probably broken")
            XCTAssertNil(error, "the getPostsList method is probably broken")
            HNScraper.shared.getMoreItems(linkForMore: linkForMore!, completionHandler: { (posts, linkForMore, error) in
                XCTAssertEqual(posts.count, 30)
                XCTAssertNotNil(linkForMore)
                XCTAssertNil(error)
                HNScraper.shared.getMoreItems(linkForMore: linkForMore!, completionHandler: { (posts, linkForMore, error) in
                    XCTAssertEqual(posts.count, 30)
                    XCTAssertNotNil(linkForMore)
                    XCTAssertNil(error)
                    exp.fulfill()
                })
            })
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetSubmissionOfNonExistingUser() {
        let exp = expectation(description: "get noSuchUser error")
        HNScraper.shared.getSubmissions(ForUserWithUsername: HNScraperTest.invalidUsername, completion: {(posts, linkForMore, error) -> Void in
            XCTAssertEqual(posts.count, 0)
            XCTAssertNil(linkForMore)
            XCTAssertEqual(error, HNScraper.HNScraperError.noSuchUser)
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetSubmissions() {
        let exp = expectation(description: "get some items")
        HNScraper.shared.getSubmissions(ForUserWithUsername: HNScraperTest.validFilledUsername, completion: {(posts, linkForMore, error) -> Void in
            XCTAssertEqual(posts.count, 30)
            XCTAssertNotNil(linkForMore)
            XCTAssertNil(error)
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    func testGetEmptySubmissionList() {
        
        let exp = expectation(description: "get 0 items")
        HNScraper.shared.getSubmissions(ForUserWithUsername: HNScraperTest.validCredential["username"]!, completion: {(posts, linkForMore, error) -> Void in
            XCTAssertEqual(posts.count, 0)
            XCTAssertNil(linkForMore)
            XCTAssertNil(error)
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetUser() {
        let exp = expectation(description: "get a entirely filled HNUser instance")
        HNLogin.shared.logout()
        HNScraper.shared.getUserFrom(Username: HNScraperTest.validFilledUsername, completion: { (user, error) in
            XCTAssertEqual(user?.username, HNScraperTest.validFilledUsername)
            XCTAssertEqual(String(String(describing: user!.age!).prefix(7)), "2010-08")
            XCTAssertNotEqual(user?.karma, 0)
            XCTAssertNotNil(user?.aboutInfo)
            XCTAssertNotEqual(user!.aboutInfo!, "")
            exp.fulfill()
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testUpvoteWithoutLogin() {
        let exp = expectation(description: "get notLoggedIn error")
        HNScraper.shared.getPostsList(page: .news, completion: {(posts, linkForMore, error) -> Void in
            if posts.count == 0 {
                XCTFail("The getPostLists method is probably broken. Or the hackernews is down...")
                exp.fulfill()
            }
            let postToUpvote = posts[0] // first post of the home page
            HNScraper.shared.upvote(Post: postToUpvote, completion: {(error) -> Void in
                XCTAssertEqual(error, .notLoggedIn)
                exp.fulfill()
            })
        })
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    
    func testGetCommentForValidPostId() {
        let exp = expectation(description: "Get some comments")
        HNScraper.shared.getComments(ByPostId: HNScraperTest.validPostId) { (post, comments, error) in
            XCTAssertNil(error)
            XCTAssertGreaterThan(comments.count, 0)
            XCTAssertGreaterThan(comments[0].text.count, 0)
            XCTAssertGreaterThan(comments[0].username.count, 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetCommentsForBadPostId() {
        let exp = expectation(description: "Get noSuchPost error")
        HNScraper.shared.getComments(ByPostId: "whatpostId") { (post, comments, error) in
            XCTAssertEqual(error, .noSuchPost)
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetCommentsForUser() {
        let exp = expectation(description: "Get some comments with parentId filled")
        HNScraper.shared.getComments(ForUserWithUsername: "yoda_sl") { (comments, linkForMore, error) in
            XCTAssertNil(error)
            XCTAssertGreaterThan(comments.count, 0)
            XCTAssertNotNil(linkForMore)
            XCTAssertNotEqual(comments[0].parentId, "")
            XCTAssertGreaterThan(comments[0].text.count, 0)
            XCTAssertGreaterThan(comments[0].username.count, 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
    
    func testGetMoreComments() {
        let exp = expectation(description: "Get some comments with parentId filled")
        HNScraper.shared.getComments(ForUserWithUsername: "yoda_sl") { (comments, linkForMore, error) in
            XCTAssertNil(error)
            XCTAssertGreaterThan(comments.count, 0)
            XCTAssertNotNil(linkForMore)
            HNScraper.shared.getMoreComments(linkForMore: linkForMore!, completionHandler: { (comments, linkForMore, error) in
                XCTAssertNil(error)
                XCTAssertGreaterThan(comments.count, 0)
                XCTAssertNotNil(linkForMore)
                exp.fulfill()
            })
            
        }
        wait(for: [exp], timeout: HNScraperTest.defaultTimeOut)
    }
}
