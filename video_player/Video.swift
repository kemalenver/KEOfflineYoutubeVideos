//
//  Video.swift
//  video_player
//
//  Created by kemal enver on 15/02/2016.
//  Copyright © 2016 kemal enver. All rights reserved.
//

import Foundation
import RealmSwift

enum YoutubeType {
    
    case Video
    case Channel
    case PlayList
}

class Video: Object {
    
    dynamic var videoId: String?
    dynamic var name: String?
    dynamic var summary: String?
    dynamic var cachedImageLocation: String?
    dynamic var downloadLocation: String?
    
    dynamic var percentComplete: Double = 0.0
    
    var playLink: String?
    var thumbs: Dictionary<String, Dictionary<String, AnyObject>>?
    var youtubeType: YoutubeType?
    
    override static func primaryKey() -> String? {
        return "videoId"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["playLink", "thumbs", "youtubeType", "percentComplete"]
    }
    
    func createWithAttributes(jsonInput: Dictionary<String, AnyObject>) {
        
        if let snippet = jsonInput["snippet"] as? Dictionary<String, AnyObject> {
            
            if let title = snippet["title"] as? String,
            description = snippet["description"] as? String,
                
            thumbnails = snippet["thumbnails"] as? Dictionary<String, Dictionary<String, AnyObject>> {
                
                self.name = title
                self.summary = description
                self.thumbs = thumbnails
            }
        }
        
        if let id = jsonInput["id"] as? Dictionary<String, AnyObject> {
            
            if let kind = id["kind"] as? String {
                
                if kind == "youtube#video" {
                    self.youtubeType = .Video
                }
                else if kind == "youtube#channel" {
                    self.youtubeType = .Channel
                }
                else if kind == "youtube#playlist" {
                    self.youtubeType = .PlayList
                }
            }
            
            if let videoId = id["videoId"] as? String {
                self.videoId = videoId
            }
        }
    }
}