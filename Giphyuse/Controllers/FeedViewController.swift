//
//  FeedViewController.swift
//  Giphyuse
//
//  Created by Rajshekhar Modi on 2018-01-25.
//  Copyright © 2018 Nimmi. All rights reserved.
//
import Foundation
import UIKit
import Alamofire

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    //MARK:- IBOutlets
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tblView: UITableView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var reachability: NetworkReachabilityManager!  // Use of NetworkReachability class to check for the network connection while loading
    var trendingGifs = [GifModel]()             // Array to display all Trending GIFs
    var searchGifs = [GifModel]()               // Array to display all Searched GIFs
    var searchString: String!                   // User entered query as string
    var isShowSearch : Bool = false             // To show GIFs whether search or trending
    var currentOffsetTrending = 0             // To keep track of the current offset for Trending GIFs for infinite scrolling
    var previousOffsetTrending = -1           // To keep track of the previous offset for Trending GIFs for infinite scrolling
    
    //MARK:- View
    // Check whether the screen has been loaded with a proper internet connection
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Load when internet connection is available or throw error
        reachability = NetworkReachabilityManager()
        reachability.startListening()
        reachability.listener = { status -> Void in
            switch status {
            case .notReachable:
                let alert = self.alertControllerWithMessage("Please make sure you are connected to the internet and try again.")
                self.present(alert, animated: true, completion: nil)
                break
            case .reachable(.ethernetOrWiFi), .reachable(.wwan):
                self.loadTrending()
                break
            default: break
            }
        }
        
        // ActivityIndicator for tableFooterView for infinite scrolling
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tblView.bounds.width, height: CGFloat(44))
        tblView.tableFooterView?.isHidden = false
        tblView.tableFooterView = spinner
        
        // Initialize the Transparent overlayView but hide it till search bar is touched
        self.view.bringSubview(toFront: overlayView)
        overlayView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        if !reachability.isReachable {
            let alert = alertControllerWithMessage("Please make sure you are connected to the internet and try again.")
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        // When the User touches unfavourite(s) on the second tab and then set the global variable
        // to clear the star (favourites) from the first tab when it appears
        if appDelegate.isFavDeleted {
            self.checkVisibleCell()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Method to unfill(remove) the favourite star based on the global variable's value set from the second tab
    func checkVisibleCell()  {
        tblView?.visibleCells.forEach { cell in
            if let cell = cell as? FeedTableViewCell {
                
                if(CoreDataHandler.checkFavouriteAvailable(passid: (cell.gifCell?.id)!))
                {
                    cell.favButton.setImage(UIImage(named:"Fav"), for: .normal)
                }
                else
                {
                    cell.favButton.setImage(UIImage(named:"UnFav"), for: .normal)
                }
            }
        }
        //Again set the global variable to false after unfavouriting GIFs
        appDelegate.isFavDeleted = false
    }
    
    //MARK:- Trending
    // Loading of all the Trending GIFs when there's no search string
    func loadTrending() {
        //initial call with offset 0
        WebAPIRequest.sharedInstance.callTrending(GlobalConstants.resultsLimit, offset: 0, completionHandler: {(newgifs,total, error) -> Void in
            self.trendingGifs = newgifs!
            self.previousOffsetTrending = self.currentOffsetTrending
            self.currentOffsetTrending = self.currentOffsetTrending + (newgifs?.count)!
            self.tblView.reloadData()
        })
    }
    
    //Loading next set of GIFs for the infinite scrolling for trending GIFs
    func loadMoreTrending()  {
        
        //Subsequent call to load trending GIFs based on the currentOffsetTrending
        WebAPIRequest.sharedInstance.callTrending(GlobalConstants.resultsLimit, offset: self.currentOffsetTrending, completionHandler: {(gifs,total, error) -> Void in
            
            if let gifs = gifs {
                var newgifs = gifs
                
                // The JSON received has duplicates, so remove those based on id
                for newgif in newgifs {
                    if self.trendingGifs.contains(where: { $0.id == newgif.id }) {
                        if let i = newgifs.index(where: { $0.id == newgif.id }) {
                            newgifs.remove(at: i)
                        }
                    }
                }
            
                self.previousOffsetTrending = self.currentOffsetTrending
                self.currentOffsetTrending = self.currentOffsetTrending + newgifs.count
                self.trendingGifs.append(contentsOf: newgifs)
                
                self.tblView.performBatchUpdates({
                    var indexPaths = [IndexPath]()
                    for i in self.previousOffsetTrending ..< self.currentOffsetTrending {
                        let indexPath = IndexPath.init(item: i, section: 0)
                        indexPaths.append(indexPath)
                    }
                    
                    self.tblView.beginUpdates()
                    self.tblView.insertRows(at: indexPaths, with: .none) // Dynamically insert rows for loading more trending GIFs data
                    self.tblView.endUpdates()
                    
                }, completion: {done -> Void in})
                
            }
        })
    }
    
    //MARK:- searching
    
    func loadSearch()  {
        //check internet connection first and proceed with searching or throw an error
        if(reachability.isReachable)
        {
            WebAPIRequest.sharedInstance.callSearch(searchStr: searchString, completionHandler: { (newgifs, totel, error) in
                self.isShowSearch = true
                self.searchGifs = newgifs!
                self.tblView.reloadData()
                if(self.searchGifs.count > 0)
                {
                    self.scrollToFirstRow()
                }
            })
        }
        else
        {
            let alert = alertControllerWithMessage("Please make sure you are connected to the internet and try again.")
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    //MARK:- UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // Show searched results if isShowSearch is true
        if(isShowSearch) {
            if(searchGifs.count > 0)
            {
                return 1
            }
            // There are no GIFs returned based on the query string so display No results found message
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            label.center = CGPoint(x: GlobalConstants.screenWidth, y: GlobalConstants.screenHeight)
            label.textAlignment = .center
            label.text = "No Results Found"
            tblView.tableFooterView?.isHidden = true
            self.tblView.backgroundView = label
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(isShowSearch) {
            return searchGifs.count
        }
        else {
            return trendingGifs.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCellIdentifier", for: indexPath) as? FeedTableViewCell  else {
            fatalError("The dequeued cell is not an instance of FeedCell.")
        }
        cell.selectionStyle = .none
        if(isShowSearch) {
            cell.gifCell = searchGifs[indexPath.item]
            tblView.tableFooterView?.isHidden = true
        }
        else {
            cell.gifCell = trendingGifs[indexPath.item]
            // When last row show add more Tranding data
            if indexPath.row == self.trendingGifs.count - 1 && reachability.isReachable {
                tblView.tableFooterView?.isHidden = false
                delayWithSeconds(1) {
                     self.loadMoreTrending()
                }
            }

        }
        cell.cellDelegate = self
        cell.tag = indexPath.row
        return cell
    }
   
    //MARK:- UISearchBar Delegate
    // When User clicks on the Search button on the keyboard, load the search results
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            searchString = searchBar.text
            self.loadSearch() //Load search data
        }
        else
        {
            isShowSearch = false
            self.tblView.reloadData()
        }
        overlayView.isHidden = true
        activityIndicator.stopAnimating()
        searchBar.resignFirstResponder()
    }
    
    // Hide the Cancel button when user clicks on Cancel
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        isShowSearch = false
        overlayView.isHidden = true
        searchBar.showsCancelButton = false
        activityIndicator.stopAnimating()
        searchBar.resignFirstResponder()
        self.tblView.reloadData()

    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        overlayView.isHidden = false
        activityIndicator.isHidden = true
        searchBar.showsCancelButton = true
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if (searchBar.text?.count)! > 1 {

            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        }
        else
        {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()

        }
    }
    
    
    //MARK:- AlertController
    
    func alertControllerWithMessage(_ message: String) -> UIAlertController {
        
        let alertController = UIAlertController.init(title: "Giphyuse", message: message, preferredStyle: .alert)
        let confirm = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(confirm)
        return alertController
        
    }
    
    //MARK:- DelayFunction
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    // Called once the search results have been displayed and page scrolls back to first row
    func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tblView.scrollToRow(at: indexPath, at: .top, animated: false)
    }
}

// MARK:- add FeedCellDelegate to our class
extension FeedViewController : FeedCellDelegate {
    
    func favButtonTapped(_ tag: Int, isDeleted:Bool) {
        
        let givegif: GifModel? = trendingGifs[tag]
       
        if(isDeleted == true)
        {
            self.showToast(message: "Removed from Favourites")
            
            if(CoreDataHandler.deleteObject(passid: (givegif?.id)!)) //delete favourite
            {
                print("Delete :",givegif?.id ?? String())
            }
        }
        else
        {
            self.showToast(message: "Added to Favourites")

            let pass : Bool = CoreDataHandler.saveObject(id: (givegif?.id)!, imageurl: (givegif?.url)!)
            if(pass == true)
            {
                print("Save :",givegif?.id ?? String())
            }
        }
    }
}

extension FeedViewController {
    
    func showToast(message : String) {
        let fontAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)]
        let width : CGFloat  = message.size(withAttributes: fontAttributes).width + 20
    
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - (width/2), y: self.view.frame.size.height-60, width: width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.textColor = .yellow
        toastLabel.font = UIFont.boldSystemFont(ofSize: 15)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 2.0, delay: 0.0, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

