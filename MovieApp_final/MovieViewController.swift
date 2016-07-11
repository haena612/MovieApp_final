//
//  MovieViewController.swift
//  MovieApp_final
//
//  Created by Haena Kim on 7/8/16.
//  Copyright © 2016 Haena Kim. All rights reserved.
//

import UIKit
import AFNetworking

class MovieViewController: UIViewController, UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate{
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkError: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UITableView!
    
    
    @IBAction func indexChanged(sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex
        {
            
        case 0:
            collectionView.hidden = true
            tableView.hidden = false
            tableView.insertSubview(refreshControl, atIndex: 0)
            
        case 1:
            tableView.hidden = true
            collectionView.hidden = false
            collectionView.insertSubview(refreshControl, atIndex: 0)

        default:
            break; 
        }
    }
    
    var movies = [NSDictionary]() //array of the movies
    var baseUrl = "http://image.tmdb.org/t/p/w342"
    var endpoint: String!
    let refreshControl = UIRefreshControl()
    let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
    
    let data = ["The Legend of Tarzan", "Finding Dory", "Independence Day: Resurgence", "The Secret Life of Pets","The Conjuring 2", "Ice Age: Collision Course", "Now You See Me 2","The Purge: Election Year","Central Intelligence", "The BFG", "Smaragdgrün", "The Fundamentals of Caring", "Cell", "Ghostbusters", "Star Trek Beyond", "Zero Days", "Murder She Baked: A Deadly Recipe"]
    var filteredData:[String] = []
    var searchActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        networkError.hidden = true
        tableView.hidden = false
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        filteredData = data
        
        fetchData()
        
        let wait = UIAlertController(title: nil, message: "Loading...", preferredStyle: .Alert)
        
        wait.view.tintColor = UIColor.blueColor()
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10, 5, 50, 50)) as UIActivityIndicatorView
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating();
        
        wait.view.addSubview(activityIndicator)
        presentViewController(wait, animated: true, completion: nil)
        
        dismissViewControllerAnimated(false, completion: nil)
        
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        segmentedControl.selectedSegmentIndex = 0
    }
    
    func fetchData() {
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request, completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                    //print("response: \(responseDictionary)")
                    self.movies = responseDictionary ["results"] as! [NSDictionary]
                    self.tableView.reloadData()
                    self.collectionView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                self.networkError.hidden = false
                self.tableView.hidden = true
            }
        })
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive){
            return filteredData.count
        }
        return movies.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell = UITableViewCell()
        //cell.textLabel?.text = String(indexPath.row)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell") as! MovieCell
        
        if(searchActive){
            cell.titleLabel.text = filteredData[indexPath.row]
        } else {
         //cell.textLabel?.text = self.movies[indexPath.row]["title"] as! String
        
//        cell.titleLabel.text = filteredData[indexPath.row]
        cell.titleLabel.text = movies[indexPath.row]["title"] as! String
        cell.overviewLabel.text = movies[indexPath.row]["overview"] as! String
        let posterimageUrl = baseUrl + (movies[indexPath.row]["poster_path"] as! String)
        let imageRequest = NSURLRequest(URL: NSURL(string: posterimageUrl)!)
        
        cell.posterImage.setImageWithURLRequest(
            imageRequest,
            placeholderImage: nil,
            success: { (imageRequest, imageResponse, image) -> Void in
                
                // imageResponse will be nil if the image is cached
                if imageResponse != nil {
                    print("Image was NOT cached, fade in image")
                    cell.posterImage.alpha = 0.0
                    cell.posterImage.image = image
                    UIView.animateWithDuration(0.6, animations: { () -> Void in
                        cell.posterImage.alpha = 1.0
                    })
                } else {
                    print("Image was cached so just update the image")
                    cell.posterImage.image = image
                }
            },
            failure: { (imageRequest, imageResponse, error) -> Void in
                // do something for the failure condition
        })
        }
        return cell
            
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar){
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredData = data.filter({ (text) -> Bool in
            let tmp: NSString = text
            let range = tmp.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if(filteredData.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        filteredData = searchText.isEmpty ? data : data.filter({(dataString: String) -> Bool in return dataString.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil
        })
        
        // When there is no text, filteredData is the same as the original data
        if searchText.isEmpty {
            filteredData = data
        } else {
            // The user has entered text into the search box
            // Use the filter method to iterate over all items in the data array
            // For each item, return true if the item should be included and false if the
            // item should NOT be included
            filteredData = data.filter({(dataItem: String) -> Bool in
                // If dataItem matches the searchText, return true to include it
                if dataItem.rangeOfString(searchText, options: .CaseInsensitiveSearch) != nil {
                    return true
                } else {
                    return false
                }
            })
        }

        self.tableView.reloadData()
    }

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let nextVC = segue.destinationViewController as! DetailViewController
        let ip = tableView.indexPathForSelectedRow
        let overview = movies[ip!.row]["overview"] as! String
        let originaltitle = movies[ip!.row]["title"] as! String
        let urlString = baseUrl + (movies[ip!.row]["poster_path"] as! String)
        let releaseDate = movies[ip!.row]["release_date"] as! String
 
        nextVC.overview = overview
        nextVC.posterUrlString = urlString
        nextVC.date = "Release Data:   " + releaseDate
        nextVC.titledetail = originaltitle
    }
    
    
}

extension MovieViewController: UICollectionViewDataSource,UICollectionViewDelegate{

    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return movies.count
    }

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
    
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CollectionImageCell", forIndexPath: indexPath)as! CollectionViewCell
        
        let posterimageUrl = baseUrl + (movies[indexPath.row]["poster_path"] as! String)
        cell.collectionImage.setImageWithURL(NSURL(string: posterimageUrl)!)
            
        return cell
    }

}


//extension MovieViewController: UICollectionViewDataSource, UICollectionViewDelegate {
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        <#code#>
//    }
//    
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//}
