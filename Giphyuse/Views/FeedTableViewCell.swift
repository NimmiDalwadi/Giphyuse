//
//  FeedTableViewCell.swift
//  Giphyuse
//
//  Created by Rajshekhar Modi on 2018-01-25.
//  Copyright © 2018 Nimmi. All rights reserved.
//
import Foundation
import UIKit
import SDWebImage

//  here is the protocol for creating the delegation
protocol FeedCellDelegate : class {
    func favButtonTapped(_ tag: Int, isDeleted:Bool)
}

class FeedTableViewCell: UITableViewCell {

    //MARK:- IBOutlets
    @IBOutlet weak var gifTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView! 
    
    //MARK:- Delegate
    weak var cellDelegate: FeedCellDelegate?

    //MARK:- IBActions
    @IBAction func favButtonTapped(_ sender: UIButton) {
        var flag = false
        
        if(favButton.currentImage == UIImage(named:"Fav"))
        {
            favButton.setImage(UIImage(named:"UnFav"), for: .normal)
            flag = true
        }
        else
        {
            favButton.setImage(UIImage(named:"Fav"), for: .normal)
            flag = false
        }
        cellDelegate?.favButtonTapped(self.tag, isDeleted:flag)

    }
    
    var gifCell: GifModel? {
        didSet {
            activityIndicator.startAnimating()
            if (gifCell?.title) != nil {
                gifTitle.text = gifCell?.title?.capitalizingFirstLetter()
            }
            if(gifCell?.url) != nil
            {
                imgView.sd_setImage(with: URL.init(string: (gifCell?.url)!))
                activityIndicator.stopAnimating()

            }
            if(CoreDataHandler.checkFavouriteAvailable(passid: (gifCell?.id)!))
            {
                favButton.setImage(UIImage(named:"Fav"), for: .normal)
            }
            else
            {
                favButton.setImage(UIImage(named:"UnFav"), for: .normal)
            }
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


