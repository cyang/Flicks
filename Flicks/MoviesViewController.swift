//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Christopher Yang on 1/18/16.
//  Copyright © 2016 Christopher Yang. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        let refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged);
        
        tableView.insertSubview(refreshControl, atIndex: 0);

        getNowPlayingData();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count;
        } else {
            return 0;
        }
    }
    
    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell;
        
        let movie = movies![indexPath.row];
        let title = movie["title"] as! String;
        let overview = movie["overview"] as! String;
        
        let posterBaseUrl = "http://image.tmdb.org/t/p/w500";
        let posterPath = movie["poster_path"] as! String;
        let posterUrl = NSURL(string: posterBaseUrl + posterPath);

        cell.titleLabel.text = title;
        cell.overviewLabel.text = overview;
        cell.posterView.setImageWithURL(posterUrl!);
        
        return cell;
    }
    
    func getNowPlayingData(){
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
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
                            
                            self.movies = responseDictionary["results"] as? [NSDictionary];
                            
                            MBProgressHUD.hideHUDForView(self.view, animated: true)
                            
                            self.tableView.reloadData();
                    }
                }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl){
        self.tableView.reloadData();
        refreshControl.endRefreshing();
    }

}
