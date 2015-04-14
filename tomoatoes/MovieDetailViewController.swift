//
//  MovieDetailViewController.swift
//  tomoatoes
//
//  Created by Jim Cai on 4/8/15.
//  Copyright (c) 2015 com.codepath. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    var movie: NSDictionary!
    @IBOutlet weak var movieImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollStuff: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var synopsisLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollStuff.alpha = 0.7
        titleLabel.text = movie["title"] as? String
        synopsisLabel.text = movie["synopsis"] as? String
        synopsisLabel.sizeToFit()   
        var url = movie.valueForKeyPath("posters.original") as? String
        movieImage.setImageWithURL(NSURL(string: url!)!)
        var range = url?.rangeOfString(".*cloudfront.net/", options: .RegularExpressionSearch)
        if let range = range {
            url = url?.stringByReplacingCharactersInRange(range, withString: "https://content6.flixster.com/")
        }        
        self.movieImage.setImageWithURLRequest(NSURLRequest(URL: NSURL(string:url!)!), placeholderImage: nil,
            success: {(request:NSURLRequest!,response:NSHTTPURLResponse!, image:UIImage!) -> Void in
                UIView.transitionWithView(self.movieImage, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve,animations: {
                    self.movieImage.setImageWithURL(NSURL(string: url!))
                    }, completion: nil)
            }, failure: {
                (request:NSURLRequest!,response:NSHTTPURLResponse!, error:NSError!) -> Void in
        })


        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        synopsisLabel.sizeToFit()
        
        
        var totalHeight = CGRectUnion(titleLabel.frame, synopsisLabel.frame).height + scrollStuff.frame.origin.y + 48        
        var scrollStuffContentFrame = scrollStuff.frame
        var scrollViewContentFrame = scrollStuff.frame
        scrollViewContentFrame.size.height = totalHeight
        scrollStuff.frame = scrollViewContentFrame
        scrollView.contentSize = scrollViewContentFrame.size
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
