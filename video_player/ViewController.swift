//
//  ViewController.swift
//  video_player
//
//  Created by kemal enver on 15/02/2016.
//  Copyright © 2016 kemal enver. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import AVKit
import AVFoundation
import AFNetworking

protocol DownloadableVideo: class {
    
    func cellDownloadPressedWithVideo(video: Video)
}


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, DownloadableVideo {

    var sessionManager = AFHTTPSessionManager()
    let itemList = ItemList()
    
    let API_KEY = "xxxxx"
    
    @IBOutlet weak var tableView: UITableView! {
        
        didSet {
        
            tableView.delegate = self
            tableView.dataSource = self
            
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 160
            
            self.tableView.tableFooterView = UIView()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar! {
        
        didSet {
            
            searchBar.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = NSLocalizedString("Vids", comment: "Main Title")
        self.navigationController?.navigationBar.barTintColor = UIColor(colorLiteralRed: 0.9, green: 0, blue: 0, alpha: 0.6)
        self.navigationController?.navigationBar.barStyle = .Black
        
        let titleDict = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let selectedPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRowAtIndexPath(selectedPath, animated: true)
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        
        return UIStatusBarStyle.LightContent
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let videoItem = self.itemList.videos[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("video_cell", forIndexPath: indexPath) as! VideoCell
        cell.titleLabel.text = videoItem.name
        cell.descriptionLabel?.text = videoItem.summary
        cell.durationLabel.text = videoItem.duration
        
        cell.downloadProgressView.progress = Float(videoItem.percentComplete)
        
        cell.delegate = self
        cell.video = videoItem
        
        if let defaultThumbUrl = videoItem.thumbs?["high"]?["url"] {
            
            if let thumbUrl = NSURL(string: defaultThumbUrl as! String ) {
                cell.videoImageView?.setImageWithURL(thumbUrl)
            }
        }
        

        cell.downloadButton.enabled = videoItem.downloadLocation == nil

        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.itemList.videos.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let videoItem = self.itemList.videos[indexPath.row]
        
        let videoURL = NSURL(string: "https://www.youtube.com/watch?v=\(videoItem.videoId!)")
        
        HCYoutubeParser.h264videosWithYoutubeURL(videoURL, completeBlock: { (videoDictionary, error) -> Void in
            
            guard let youtubeLink = videoDictionary["small"] else { return }
            
            guard let youtubeVideoUrl = NSURL(string: youtubeLink as! String)  else { return }
            
            let player = AVPlayer(URL: youtubeVideoUrl)
            
            let playerController = AVPlayerViewController()
            
            playerController.player = player
            
            
            self.presentViewController(playerController, animated: true, completion: {
                
                player.play()
            })
            
        })
        
    }

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
        
        if let query = searchBar.text {
            self.performSearchWithQuery(query)
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
    
    func performSearchWithQuery(query: String) {
        
        let paramaters = ["q" : query, "part" : "snippet", "key" : API_KEY, "maxResults" : 50]
        
        self.sessionManager.GET("https://www.googleapis.com/youtube/v3/search", parameters: paramaters, progress: nil, success: { (sessionTask, responseObject) -> Void in
            
            if let resp = responseObject as? Dictionary<String, AnyObject> {
                
                let videoList = resp["items"] as! Array<AnyObject>
                
                self.itemList.createVideos(videoList)
                
                let strings = self.itemList.videos.flatMap({ (video) -> String? in
                    
                    return video.videoId
                })
                
                let videoIds = strings.joinWithSeparator(",")
                
                print(videoIds)
                
                let dataParamaters = ["part" : "contentDetails", "key" : self.API_KEY, "id" : videoIds]
                
                self.sessionManager.GET("https://www.googleapis.com/youtube/v3/videos", parameters: dataParamaters, progress: nil, success: { (sessionTask, responseObject) -> Void in
                    
                    if let resp = responseObject as? Dictionary<String, AnyObject> {
                        
                        let videoList = resp["items"] as! Array<AnyObject>
                        
                        for video in videoList {
                            
                            if let videoId = video["id"] as? String,
                                contentDetails = video["contentDetails"] {
                                    
                                    let duration = contentDetails!["duration"] as? String
                                    
                                    for video in self.itemList.videos {
                                        
                                        if video.videoId == videoId {
                                            
                                            video.duration = duration
                                        }
                                    }
                            }
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                    
                    }) { (sessionTask, error) -> Void in
                        
                        print(error)
                }
                
            }
            
            }) { (sessionTask, error) -> Void in
                
                print(error)
        }
    }
    
    func downloadVideo(video: Video) {
        
        let youtubeLink = "https://www.youtube.com/watch?v=\(video.videoId!)"
        
        guard let youtubeVideoUrl = NSURL(string: youtubeLink) else { return }
        
        HCYoutubeParser.h264videosWithYoutubeURL(youtubeVideoUrl, completeBlock: { (videoDictionary, error) -> Void in
            
            guard let youtubeLink = videoDictionary["small"] else { return }
            
            guard let parsedUrl = NSURL(string: youtubeLink as! String)  else { return }
            
            self.startDownloadWithUrl(parsedUrl, video: video)
        })
        
        
    }
    
    func startDownloadWithUrl(videoUrl: NSURL, video: Video) {
        
        let request = NSURLRequest(URL: videoUrl)
        
        let downloadTask = self.sessionManager.downloadTaskWithRequest(request, progress: { (progress) -> Void in
            
            print("Download made progress: \(progress.fractionCompleted)")
            
            dispatch_async(dispatch_get_main_queue(),{
                
                video.percentComplete = progress.fractionCompleted
                
                self.tableView.reloadData()
                
            })
            
            }, destination: { (url, response) -> NSURL in
                // return destination url
                
                print("URL \(url) RESPONSE: \(response)" )
                let documentDirectoryURL =  try! NSFileManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
                
                return documentDirectoryURL.URLByAppendingPathComponent("\(video.videoId!).mp4")
                
            }) { (response, url, error) -> Void in
                
                if let unwrappedError = error {
                    
                    print(unwrappedError)
                }
                else {
                    
                    guard let unwrappedUrl = url else { return }
                    video.downloadLocation = unwrappedUrl.absoluteString
                    
                    let realm = try! Realm()

                    try! realm.write {
                        realm.add(video)
                    }
                    
                    print(unwrappedUrl)
                }
        
        }
        
        downloadTask.resume()
    }

    func cellDownloadPressedWithVideo(video: Video) {
        
        self.downloadVideo(video)
    }
    
    @IBAction func gotoDownloadedViewController() {
        
        if let downloadedViewController = self.storyboard?.instantiateViewControllerWithIdentifier("downloaded_view_controller") as? DownloadedVideosViewController {
            
            self.navigationController?.pushViewController(downloadedViewController, animated: true)
        }
    }
}

