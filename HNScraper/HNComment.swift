//
//  HNComment.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation
class BaseComment {
    var replies: [BaseComment]! = []
    var level: Int! = 0
    weak var replyTo: BaseComment?
    
    convenience init() {
        self.init(level: 0, replyTo: nil)
    }
    init(level: Int, replyTo: BaseComment?) {
        self.level = level
        self.replyTo = replyTo
    }
    func addReply(_ reply: BaseComment) {
        self.replies.append(reply)
    }
    
}

class HNComment: BaseComment {
    convenience init() {
        self.init(level: 0, replyTo: nil)
    }
    override init(level: Int, replyTo: BaseComment?) {
        super.init(level: level, replyTo: replyTo)
    }
    enum HNCommentType {
        case defaultType
        case askHN
        case jobs
    }
    
    
    var type: HNCommentType! = .defaultType
    var text: String! = ""
    var id: String! = ""
    var username: String! = "anonymous"
    var parentId: Int! = -1
    var created: String! = ""
    var replyUrl: String! = ""
    var links: [String]! = []
    var upvoteUrl: String! = ""
    var downvoteUrl: String! = ""
    
    
    convenience init?(fromHtml html: String, withParsingConfig parseConfig: [String : Any], levelOffset: Int = 0) {
        self.init()
        var commentDict: [String : Any]? = parseConfig["Comment"] != nil ? parseConfig["Comment"] as? [String: Any] : nil
        if commentDict == nil {
            return nil
        }
        
        let scanner = Scanner(string: html)
        var upvoteString: NSString? = ""
        let downvoteString: NSString? = ""
        var level: NSString? = ""
        var cDict: [String : Any] = [:]
        
        
        // Get Comment Level
        scanner.scanBetweenString(stringA: (commentDict!["Level"] as! [String: String])["S"]!, stringB: (commentDict!["Level"] as! [String: String])["E"]!, into: &level)
        if (level != nil) {
            self.level = Int(level!.intValue) / 40 + levelOffset // TODO: add this constant in the parseConfig
        } else {
            self.level = levelOffset
        }
        
        
        
        
        
        // If Logged In - Grab Voting Strings
        if (html.contains((commentDict!["Upvote"] as! [String: String])["R"]!)) {
            // Scan Upvote String
            scanner.scanBetweenString(stringA: (commentDict!["Upvote"] as! [String: String])["S"]!, stringB: (commentDict!["Upvote"] as! [String: String])["E"]!, into:&upvoteString)
            if (upvoteString != nil) {
                self.upvoteUrl = upvoteString!.replacingOccurrences(of: "&amp;", with: "&")
            }
            // Check for downvote String
            if (html.contains((commentDict!["Downvote"] as! [String: String])["R"]!)) {
                scanner.scanBetweenString(stringA: (commentDict!["Downvote"] as! [String: String])["S"]!, stringB: (commentDict!["Downvote"] as! [String: String])["E"]!, into:&upvoteString)
                if (downvoteString != nil) {
                    self.downvoteUrl = downvoteString!.replacingOccurrences(of: "&amp;", with: "&")
                }
            }
        }
        scanner.scanLocation = 0
        
        let regs = commentDict!["REG"] as! [[String : Any]]
        for dict in regs {
            var new: NSString? = ""
            let isTrash = dict["I"] as! String == "TRASH"
            scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
            if (!isTrash && (new?.length)! > 0) {
                cDict[dict["I"] as! String] = new
            }
        }
        
        self.id = cDict["CommentId"] as? String ?? ""
        self.text = cDict["Text"] as? String ?? ""
        self.username = cDict["Username"] as? String ?? ""
        self.created = cDict["Time"] as? String ?? ""
        self.replyUrl = cDict["ReplyUrl"] as? String ?? ""
        
        
        
    }
    
    static func parseAskHNComment(html: String, withParsingConfig parseConfig: [String : Any]) -> HNComment? {
        var cDict: [String : Any] = [:]
        var commentDict: [String : Any]? = parseConfig["Comment"] != nil ? parseConfig["Comment"] as? [String: Any] : nil
        if commentDict == nil {
            return nil
        }
        
        let scanner = Scanner(string: html)
        var upvoteUrl: NSString? = ""
        
        
        if html.contains((commentDict!["Upvote"] as! [String: String])["R"]!) {
            scanner.scanBetweenString(stringA: (commentDict!["Upvote"] as! [String: String])["S"]!, stringB: (commentDict!["Upvote"] as! [String: String])["E"]!, into: &upvoteUrl)
            if (upvoteUrl != nil) {
                upvoteUrl = upvoteUrl!.replacingOccurrences(of: "&amp;", with: "&") as NSString
            }
        }
        let asks = commentDict!["ASK"] as! [[String : Any]]
        for dict in asks {
            var new: NSString? = ""
            let isTrash = dict["I"] as! String == "TRASH"
            scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
            if (!isTrash && (new?.length)! > 0) {
                cDict[dict["I"] as! String] = new
            }
        }
        
        let newComment = HNComment()
        newComment.level = 0
        newComment.username = cDict["Username"] as? String ?? ""
        newComment.created = cDict["Time"] as? String ?? ""
        newComment.text = cDict["Text"] as? String ?? ""
        //newComment.links = ...
        newComment.type = .askHN
        newComment.upvoteUrl = String(describing: upvoteUrl) as String //(upvoteUrl?.length)! > 0 ? upvoteUrl : "";
        newComment.id = cDict["CommentId"] as? String ?? ""
        return newComment
    }
    static func parseJobComment(html: String, withParsingConfig parseConfig: [String : Any]) -> HNComment? {
        var commentDict: [String : Any]? = parseConfig["Comment"] != nil ? parseConfig["Comment"] as? [String: Any] : nil
        if commentDict == nil {
            return nil
        }
        
        let scanner = Scanner(string: html)
        var cDict: [String : Any] = [:]
        
        let jobs = commentDict!["JOBS"] as! [[String : Any]]
        for dict in jobs {
            var new: NSString? = ""
            let isTrash = dict["I"] as! String == "TRASH"
            scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
            if (!isTrash && (new?.length)! > 0) {
                cDict[dict["I"] as! String] = new
            }
        }
        
        let newComment = HNComment()
        newComment.level = 0
        newComment.text = cDict["Text"] as? String ?? ""
        //newComment.links = ...
        newComment.type = .jobs
        
        return newComment
    }
    
    private var htmlPosts: String?
    private var parseConfig: [String : Any]?
    private func parseDownloadedComments(forPost: HNPost, completion: (([HNComment], HNPost)->Void)) {
        if self.htmlPosts == nil || self.parseConfig == nil {
            return // Has to wait until the two ressources are loaded
        }
        
        
        
        // Set Up
        var comments: [HNComment] = []
        var upvoteUrl: NSString? = ""
        let post = forPost
        var commentDict: [String : Any]? = (parseConfig != nil && parseConfig!["Comment"] != nil) ? parseConfig!["Comment"] as? [String: Any] : nil
        
        if (commentDict == nil) {
            completion([], post)
            return
        }
        var htmlComponents = commentDict!["CS"] != nil ? htmlPosts!.components(separatedBy: commentDict!["CS"] as! String) : nil
        if (htmlComponents == nil) {
            completion([], post)
            return
        }
        
        
        if commentDict!["Reply"] != nil && (commentDict!["Reply"] as! [String: Any])["R"] != nil && htmlPosts!.contains((commentDict!["Reply"] as! [String: Any])["R"]! as! String) {
            var cDict: [String: Any] = [:]
            let scanner = Scanner(string: htmlPosts!)
            
            let parts = (commentDict!["Reply"] as! [String: Any])["Parts"] as! [[String : Any]]
            for part in parts {
                var new: NSString? = ""
                let isTrash = part["I"] as! String == "TRASH"
                scanner.scanBetweenString(stringA: part["S"] as! String, stringB: part["E"] as! String, into: &new)
                if (!isTrash && (new?.length)! > 0) {
                    cDict[part["I"] as! String] = new
                }
                
            }
            post.replyAction = cDict["action"] as? String ?? ""
            post.replyParent = cDict["parent"] as? String ?? ""
            post.replyHmac = cDict["hmac"] as? String ?? ""
            post.replyText = cDict["replyText"] as? String ?? ""
            post.replyGoto = cDict["goto"] as? String ?? ""
            
            
        }
        
        if post.type == .askHN {
            let scanner = Scanner(string: htmlComponents![0])
            var cDict: [String : Any] = [:]
            
            if htmlComponents![0].contains((commentDict!["Upvote"] as! [String: String])["R"]!) {
                scanner.scanBetweenString(stringA: (commentDict!["Upvote"] as! [String: String])["S"]!, stringB: (commentDict!["Upvote"] as! [String: String])["E"]!, into: &upvoteUrl)
                if (upvoteUrl != nil) {
                    upvoteUrl = upvoteUrl!.replacingOccurrences(of: "&amp;", with: "&") as NSString
                }
            }
            let asks = commentDict!["ASK"] as! [[String : Any]]
            for dict in asks {
                var new: NSString? = ""
                let isTrash = dict["I"] as! String == "TRASH"
                scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
                if (!isTrash && (new?.length)! > 0) {
                    cDict[dict["I"] as! String] = new
                }
            }
            
            let newComment = HNComment()
            newComment.level = 0
            newComment.username = cDict["Username"] as? String ?? ""
            newComment.created = cDict["Time"] as? String ?? ""
            newComment.text = cDict["Text"] as? String ?? ""
            //newComment.links = ...
            newComment.type = .askHN
            newComment.upvoteUrl = String(describing: upvoteUrl) as String //(upvoteUrl?.length)! > 0 ? upvoteUrl : "";
            newComment.id = cDict["CommentId"] as? String ?? ""
            comments.append(newComment)
            
        }
        
        if post.type == .jobs {
            let scanner = Scanner(string: htmlComponents![0])
            var cDict: [String : Any] = [:]
            
            let jobs = commentDict!["JOBS"] as! [[String : Any]]
            for dict in jobs {
                var new: NSString? = ""
                let isTrash = dict["I"] as! String == "TRASH"
                scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
                if (!isTrash && (new?.length)! > 0) {
                    cDict[dict["I"] as! String] = new
                }
            }
            
            let newComment = HNComment()
            newComment.level = 0
            newComment.text = cDict["Text"] as? String ?? ""
            //newComment.links = ...
            newComment.type = .jobs
            comments.append(newComment)
            
        }
        
        // 1st object is garbage.
        htmlComponents?.remove(at: 0)
        for htmlComponent in htmlComponents! {
            let scanner = Scanner(string: htmlComponent)
            let newComment = HNComment()
            var upvoteString: NSString? = ""
            let downvoteString: NSString? = ""
            var level: NSString? = ""
            var cDict: [String : Any] = [:]
            
            // Get Comment Level
            scanner.scanBetweenString(stringA: (commentDict!["Level"] as! [String: String])["S"]!, stringB: (commentDict!["Level"] as! [String: String])["E"]!, into: &level)
            if (level != nil) {
                newComment.level = Int(level!.intValue) / 40 // TODO: add this constant in the parseConfig
            }
            
            
            // If Logged In - Grab Voting Strings
            if (htmlComponent.contains((commentDict!["Upvote"] as! [String: String])["R"]!)) {
                // Scan Upvote String
                scanner.scanBetweenString(stringA: (commentDict!["Upvote"] as! [String: String])["S"]!, stringB: (commentDict!["Upvote"] as! [String: String])["E"]!, into:&upvoteString)
                if (upvoteString != nil) {
                    newComment.upvoteUrl = upvoteString!.replacingOccurrences(of: "&amp;", with: "&")
                }
                // Check for downvote String
                if (htmlComponent.contains((commentDict!["Downvote"] as! [String: String])["R"]!)) {
                    scanner.scanBetweenString(stringA: (commentDict!["Downvote"] as! [String: String])["S"]!, stringB: (commentDict!["Downvote"] as! [String: String])["E"]!, into:&upvoteString)
                    if (downvoteString != nil) {
                        newComment.downvoteUrl = downvoteString!.replacingOccurrences(of: "&amp;", with: "&")
                    }
                }
            }
            scanner.scanLocation = 0
            
            let regs = commentDict!["REG"] as! [[String : Any]]
            for dict in regs {
                var new: NSString? = ""
                let isTrash = dict["I"] as! String == "TRASH"
                scanner.scanBetweenString(stringA: dict["S"] as! String, stringB: dict["E"] as! String, into: &new)
                if (!isTrash && (new?.length)! > 0) {
                    cDict[dict["I"] as! String] = new
                }
            }
            
            newComment.id = cDict["CommentId"] as? String ?? ""
            newComment.text = cDict["Text"] as? String ?? ""
            newComment.username = cDict["Username"] as? String ?? ""
            newComment.created = cDict["Time"] as? String ?? ""
            newComment.replyUrl = cDict["ReplyUrl"] as? String ?? ""
            
            
            //newComment.links = ...
            
            comments.append(newComment)
            
            
        }
        
        completion(comments, post)
        
        
        
    }
    
    
    /*func getComments(forPost: HNPost, completion: @escaping (([HNComment], HNPost) -> Void)) {
     if self.parseConfig == nil {
     HNParseConfig.getDictionnary(completion: {(config) -> Void in
     self.parseConfig = config
     self.parseDownloadedComments(forPost: forPost, completion: completion)
     })
     }
     let url = "https://news.ycombinator.com/item?id=\(forPost.id)"
     downloadCommentPageHTML(url: url, completion: {(html) -> Void in
     self.htmlPosts = html
     self.parseDownloadedComments(forPost: forPost, completion: completion)
     })
     }*/
    
    func downloadCommentPageHTML(url: String, completion: @escaping ((String) -> Void)) {
        RessourceFetcher.shared.fetchData(urlString: url, completion: {(data, error) -> Void in
            
            completion(String(data: data!, encoding: String.Encoding.utf8)!)
            
        })
    }
}
