//
//  ViewController.swift
//  Instagram
//
//  Created by Erica Lee on 1/28/16.
//  Copyright © 2016 Erica Lee, Yuting Zhang. All rights reserved.
//

import UIKit
import AFNetworking

class PhotoViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate{

    @IBOutlet weak var tableView: UITableView!
    var media: [NSDictionary]?
    
    var isMoreDataLoading = false
    var loadingMoreView : InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting up the dataSource and delegate
        tableView.dataSource = self
        tableView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
        let clientId = "e05c462ebd86446ea48a5af73769b602"
        let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
        let request = NSURLRequest(URL: url!)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate:nil,
            delegateQueue:NSOperationQueue.mainQueue()
        )
        
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            NSLog("response: \(responseDictionary)")
                            self.media = responseDictionary["data"] as? [NSDictionary]
                            self.tableView.reloadData()
                    }
                }
        });
        
        task.resume()
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let media = media{
            return media.count
        }
        else{
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        //reuse any available cell
        let cell = tableView.dequeueReusableCellWithIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoViewCell
        let photo = media![indexPath.row]
        let imageDict = photo["images"] as! NSDictionary
        let image = imageDict["standard_resolution"] as! NSDictionary
        let url = NSURL(string: image["url"] as! String)
        cell.photo.setImageWithURL(url!)
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (!isMoreDataLoading){
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()

                
                isMoreDataLoading = true
                let clientId = "e05c462ebd86446ea48a5af73769b602"
                let url = NSURL(string:"https://api.instagram.com/v1/media/popular?client_id=\(clientId)")
                let request = NSURLRequest(URL: url!)
                let session = NSURLSession(
                    configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                    delegate:nil,
                    delegateQueue:NSOperationQueue.mainQueue()
                )
                
                let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
                    completionHandler: { (dataOrNil, response, error) in
                        if let data = dataOrNil {
                            if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                                data, options:[]) as? NSDictionary {
                                    self.isMoreDataLoading = false
                                    //NSLog("response: \(responseDictionary)")
                                    self.media?.appendContentsOf(responseDictionary["data"] as! [NSDictionary])
                                    self.tableView.reloadData()
                                    
                                    // Stop the loading indicator
                                    self.loadingMoreView!.stopAnimating()
                            }
                        }
                });
                
                task.resume()
            }
        }
    }
}

