//
//  PlayeViewrController.swift
//  video_player
//
//  Created by kemal enver on 15/02/2016.
//  Copyright © 2016 kemal enver. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import UIKit


class PlayerViewController: UIViewController {
    
    var youtubeLinkString: String?
    var localVideoUrl: NSURL?
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.createPlayer()
    }
    
    func createPlayer() {
        
        if let unwrappedLink = self.youtubeLinkString,
            videoURL = NSURL(string: unwrappedLink) {
                
                HCYoutubeParser.h264videosWithYoutubeURL(videoURL, completeBlock: { (videoDictionary, error) -> Void in
                    
                    guard let youtubeLink = videoDictionary["small"] else { return }
                    
                    guard let youtubeVideoUrl = NSURL(string: youtubeLink as! String)  else { return }
                    
                    let player = AVPlayer(URL: youtubeVideoUrl)
                    
                    let playerController = AVPlayerViewController()
                    
                    playerController.player = player
                    
                    self.addChildViewController(playerController)
                    
                    playerController.view.frame = self.view.bounds
                    
                    self.view.addSubview(playerController.view)
                    
                    playerController.didMoveToParentViewController(self)
                    
                    player.play()
                })
        }
        
        
        if let unwrappedLink = self.localVideoUrl {
            
            let player = AVPlayer(URL: unwrappedLink)
            
            let playerController = AVPlayerViewController()
            
            playerController.player = player
            
            self.addChildViewController(playerController)
            
            playerController.view.frame = self.view.bounds
            
            self.view.addSubview(playerController.view)
            
//            playerController.view.layer.borderColor = UIColor.greenColor().CGColor
//            playerController.view.layer.borderWidth = 2
            
            playerController.didMoveToParentViewController(self)
            
            player.play()
            
        }
    }
}
