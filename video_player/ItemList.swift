//
//  ItemList.swift
//  video_player
//
//  Created by kemal enver on 15/02/2016.
//  Copyright © 2016 kemal enver. All rights reserved.
//

import Foundation

class ItemList {
    
    var videos = Array<Video>()
    
    func createVideos(jsonInput: Array<AnyObject>) {
        
        videos.removeAll()
        
        for videoJson in jsonInput {
            
            let video = Video()
            video.createWithAttributes(videoJson as! Dictionary<String, AnyObject>)
            
            if video.youtubeType == .Video {
                videos.append(video)
            }
        }
        
    }
    
}