//
//  DownloadedVideosViewController.swift
//  video_player
//
//  Created by kemal enver on 17/02/2016.
//  Copyright © 2016 kemal enver. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import AVKit
import AVFoundation

class DownloadedVideosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var realm = try! Realm()
    
    var videos: Results<Video> {
        get {
            return realm.objects(Video)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
            
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 160
            
            self.tableView.tableFooterView = UIView()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.title = "Downloaded"
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let selectedPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let videoItem = self.videos[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("downloaded_video_cell", forIndexPath: indexPath)
        cell.textLabel?.text = videoItem.name
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.videos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let videoItem = self.videos[indexPath.row]

        let player = AVPlayer(URL: NSURL(string: videoItem.downloadLocation!)!)
        
        let playerController = AVPlayerViewController()
        
        playerController.player = player
        
        self.presentViewController(playerController, animated: true, completion: {
            
            player.play()
        })
        
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "Delete"
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let videoItem = self.videos[indexPath.row]
        
        if let downloadedVideoLocation = NSURL(string: videoItem.downloadLocation!) {
        
            if (try? NSFileManager.defaultManager().removeItemAtURL(downloadedVideoLocation)) == nil {
                print("Deletion from file system failed")
            }
        }
        
        try! self.realm.write { () -> Void in
            
            self.realm.delete(videoItem)
        }
        
        self.tableView.reloadData()
    }
}