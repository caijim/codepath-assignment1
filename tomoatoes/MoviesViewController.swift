//
//  MoviesViewController.swift
//  tomoatoes
//
//  Created by Jim Cai on 4/7/15.
//  Copyright (c) 2015 com.codepath. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate{
    var movies: [NSDictionary]! = [NSDictionary]()
    var failedToLoad: Bool = false

    @IBOutlet weak var listGridSegmented: UISegmentedControl!
    @IBOutlet weak var movieCollection: UICollectionView!
    @IBOutlet weak var typeTabBar: UITabBar!
    
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.movieCollection.hidden = true
        self.networkError.hidden = true
        refreshData()
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    
        tableView.delegate = self;
        tableView.dataSource = self;
        typeTabBar.delegate = self;
        movieCollection.delegate = self;
        movieCollection.dataSource = self;
        // Do any additional setup after loading the view.
    }

    @IBAction func indexChanged(sender: UISegmentedControl) {        if sender.selectedSegmentIndex == 0{
            self.tableView.hidden = false
            self.movieCollection.hidden = true
        }
        else
        {
            self.tableView.hidden = true
            self.movieCollection.hidden = false
            
        }
    }
    
    func refreshData() {
        var key: String = "jvj8wnunfdzcmznks9tx2g4j"
        var url: NSURL
        if typeTabBar.selectedItem?.title=="DVD"{
            url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/dvds/new_releases.json?page_limit=25&apikey="+key)!
        }
        else{
            url = NSURL(string: "http://api.rottentomatoes.com/api/public/v1.0/lists/movies/in_theaters.json?page_limit=25&apikey="+key)!
        }
        var request = NSURLRequest(URL: url)
        SVProgressHUD.show()
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse!,data:  NSData!, error: NSError!) -> Void in
            if let requestError = error? {
                self.networkError.hidden = false
            }
            else{
                self.networkError.hidden = true
                self.failedToLoad = false
                var json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as NSDictionary
                self.movies = json["movies"] as [NSDictionary]
                self.tableView.reloadData()
                self.movieCollection.reloadData()
                
            }
            SVProgressHUD.dismiss()
            
        }
    }
    
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        refreshData()
    }
    
    
    func onRefresh() {
        refreshData()
        refreshControl.endRefreshing()
    }
    

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movies.count
    }

    
    func setImageWIthHighResURL(im:UIImageView, url:String){
        var range = url.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        var replaced : String? = nil;
        if let range = range {
            replaced = url.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }
        
        im.setImageWithURLRequest(NSURLRequest(URL: NSURL(string:replaced!)!), placeholderImage: nil,
            success: {(request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                UIView.transitionWithView(im, duration: 2.0, options: UIViewAnimationOptions.TransitionCrossDissolve,animations: {
                    im.setImageWithURL(NSURL(string: replaced!))
                    }, completion: nil)
            }, failure: {
                (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
        })
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.failedToLoad{
            //do nothing
        }
        else{
            var cell = movieCollection.dequeueReusableCellWithReuseIdentifier("CollectionCell", forIndexPath: indexPath) as MovieCollectionViewCell
            var movie = self.movies[indexPath.row] as NSDictionary
            var url = movie.valueForKeyPath("posters.thumbnail") as? String
            cell.movieImage.setImageWithURL(NSURL(string: url!)!)
            setImageWIthHighResURL(cell.movieImage, url:url!)
            return cell
        }
        
        // this will never get called if we fail
        var emptyCell = tableView.dequeueReusableCellWithIdentifier("CollectionCell", forIndexPath: indexPath) as UICollectionViewCell
        return emptyCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.failedToLoad{
            //do nothing
        }
        else{
            var cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as MovieCell
            var movie = self.movies[indexPath.row] as NSDictionary
            var url = movie.valueForKeyPath("posters.thumbnail") as? String
            cell.posterView.setImageWithURL(NSURL(string: url!)!)
            setImageWIthHighResURL(cell.posterView, url: url!)
            cell.titleLabel.text = movie["title"] as? String
            cell.summaryLabel.text = movie["synopsis"] as? String
            return cell
        }
        
        // this will never get called if we fail
        var emptyCell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as UITableViewCell
        return emptyCell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(160.0)
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var movieDetailController = segue.destinationViewController as MovieDetailViewController
        if sender is MovieCell{
            var cell = sender as MovieCell
            var indexPath = tableView.indexPathForCell(cell)!
            movieDetailController.movie = self.movies[indexPath.row]
        }
        else if sender is MovieCollectionViewCell{
            var cell = sender as MovieCollectionViewCell
            var indexPath = movieCollection.indexPathForCell(cell)
            movieDetailController.movie = self.movies[(indexPath?.item)!]

        }
    }
    
    
    

}
