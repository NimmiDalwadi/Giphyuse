//
//  FavViewController.swift
//  Giphyuse
//
//  Created by Rajshekhar Modi on 2018-01-25.
//  Copyright © 2018 Nimmi. All rights reserved.
//

import UIKit
import  CoreData

class FavViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    //MARK:- IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noFavLabel: UILabel!
    //@IBOutlet weak var layout: UICollectionViewFlowLayout!
    
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var favArray = [Favourite]()                //Array to display all Favourites GIFs
    
    //MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Favourites"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reloadCollectionView()
    }

    //MARK:- reloadCollection
    
    func reloadCollectionView(){
        CoreDataHandler.fetchObject{ (newarray, error) in
            self.favArray = newarray!

            if(self.favArray.count > 0)
            {
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
                self.noFavLabel.isHidden = true
            }
            else
            {
                self.collectionView.isHidden = true
                self.noFavLabel.isHidden = false

            }
        }
    }
    
    //MARK:- UICollectionView
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavCellIdentifier", for: indexPath) as! FavCollectionViewCell
        cell.favCell = favArray[indexPath.item]
        cell.cellDelegate = self
        cell.tag = indexPath.row
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK:- add FavCellDelegate to our class
extension FavViewController:FavCellDelegate
{
    func favButtonTapped(_ tag: Int) {
        let fav: Favourite? = favArray[tag]
        
        self.showToast(message: "Removed from Favourites")

        //Delete from favourite
        if(CoreDataHandler.deleteObject(passid: (fav?.id)!))
        {
            print("Delete :",fav?.id ?? String())
            appDelegate.isFavDeleted = true
        }
        self.reloadCollectionView()
    }
}

extension FavViewController {
    
    func showToast(message : String) {
        let fontAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)]
        let width : CGFloat  = message.size(withAttributes: fontAttributes).width + 20
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - (width/2), y: self.view.frame.size.height-60, width: width, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.8)
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
