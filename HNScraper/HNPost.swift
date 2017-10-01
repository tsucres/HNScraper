//
//  HNPost.swift
//  HackerNews2
//
//  Created by Stéphane Sercu on 8/09/17.
//  Copyright © 2017 Stéphane Sercu. All rights reserved.
//

import Foundation


/// Model used by the HN Scraper to store avery data about a post.
class HNPost {
    enum PostType {
        case defaultType
        case askHN
        case jobs
        
        init?(index: Int) {
            switch index {
            case 0: self = .defaultType
            case 1: self = .askHN
            case 2: self = .jobs
            default: return nil
            }
        }
    }
    
    var type: PostType = .defaultType
    var username: String = ""
    var url: URL?// = URL(string: "")!
    var urlDomain: String {
        get {
            if url == nil {
                return ""
            }
            var dom: String? = self.url!.host
            if dom != nil && dom!.hasPrefix("www.") {
                dom = String(dom!.characters.dropFirst(4))
            }
            return dom ?? ""
        }
    }
    var title: String = ""
    var points: Int = 0
    var commentCount: Int = 0
    var id: String = ""
    var time: String = ""
    
    var upvoted: Bool = false
    var upvoteAdditionURL: String?
    
    var favorited: Bool = false
    var bookmarked: Bool = false
    var readOn: Date?
    
    var replyAction: String?
    var replyParent: String?
    var replyGoto: String?
    var replyHmac: String?
    var replyText: String?
    
    
    init() {}
    
    /**
     * Build the model by parsing the html of a post item on the HN website.
     * - parameters:
     *      - html: the html code to parse
     *      - parseConfig: the parameters from the json file containing all the needed parsing informations.
     */
    convenience init?(fromHtml html: String, withParsingConfig parseConfig: [String : Any]) {
        self.init()
        
        var postsConfig: [String : Any]? = (parseConfig["Post"] != nil) ? parseConfig["Post"] as? [String : Any] : nil
        if postsConfig == nil {
            return nil
        }
        
        if html.contains("<td class=\"title\"> [dead] <a") {
            return nil
        }
        
        
        // Set Up for Scanning
        var postDict: [String : Any] = [:]
        let scanner: Scanner = Scanner(string: html)
        var upvoteString: NSString? = ""
        
        
        // Scan for Upvotes
        if (html.contains((postsConfig!["Vote"] as! [String: String])["R"]!)) {
            scanner.scanBetweenString(stringA: (postsConfig!["Vote"] as! [String: String])["S"]!, stringB: (postsConfig!["Vote"] as! [String: String])["E"]!, into: &upvoteString)
            self.upvoteAdditionURL = upvoteString! as String;
        }
        
        // Scan from JSON Configuration
        let parts = postsConfig!["Parts"] as! [[String : Any]]
        for part in parts {
            var new: NSString? = ""
            let isTrash = part["I"] as! String  == "TRASH"
            
            scanner.scanBetweenString(stringA: part["S"] as! String, stringB: part["E"] as! String, into: &new)
            if (!isTrash && (new?.length)! > 0) {
                postDict[part["I"] as! String] = new
            }
        }
        
        
        // Set Values
        self.url = postDict["UrlString"] != nil ? URL(string: postDict["UrlString"] as! String) : nil
        self.title = postDict["Title"] as? String ?? ""
        self.points = Int(((postDict["Points"] as? String ?? "").components(separatedBy: " ")[0])) ?? 0
        self.username = postDict["Username"] as? String ?? ""
        self.id = postDict["PostId"] as? String ?? ""
        self.time = postDict["Time"] as? String ?? ""
        if self.id != "" && html.contains("un_"+self.id) {
            self.upvoted = true
        }
        
        
        if (postDict["Comments"] != nil && postDict["Comments"] as! String == "discuss") {
            self.commentCount = 0;
        }
        else if (postDict["Comments"] != nil) {
            let cScan: Scanner = Scanner(string: postDict["Comments"] as! String)
            var cCount: NSString? = ""
            cScan.scanUpTo(" ", into: &cCount)
            self.commentCount = Int((cCount?.intValue)!)
        }
        
        // Check if Jobs Post
        if (self.id.characters.count == 0 && self.points == 0 && self.username.characters.count == 0) {
            self.type = .jobs
            if self.url != nil && !self.url!.absoluteString.contains("http") {
                self.id = self.url!.absoluteString.replacingOccurrences(of: "item?id=", with: "")
            }
        }
        else {
            // Check if AskHN
            if self.url != nil && !self.url!.absoluteString.contains("http") && self.id.length > 0 {
                self.type = .askHN
                self.url = URL(string: "https://news.ycombinator.com/" + self.url!.absoluteString)!
            }
            else {
                self.type = .defaultType
            }
        }
    }
}

