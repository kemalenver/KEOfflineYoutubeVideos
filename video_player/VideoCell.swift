
//
//  VideoCell.swift
//  video_player
//
//  Created by kemal enver on 15/02/2016.
//  Copyright © 2016 kemal enver. All rights reserved.
//

import Foundation

class VideoCell: UITableViewCell {
    
    weak var delegate: DownloadableVideo?
    weak var video: Video?
    
    @IBOutlet weak var downloadButton: UIButton!
    
    @IBOutlet weak var videoImageView: UIImageView! {
        
        didSet {
            
            videoImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var downloadProgressView: UIProgressView! {
        
        didSet {
            
            downloadProgressView.progress = 1
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBAction func downloadPressed() {
        
        if let delegate = self.delegate,
            video = self.video {
                
                delegate.cellDownloadPressedWithVideo(video)
        }
    }
    
}