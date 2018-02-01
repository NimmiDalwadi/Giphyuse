//
//  FavCollectionViewCell.swift
//  Giphyuse
//
//  Created by Rajshekhar Modi on 2018-01-26.
//  Copyright © 2018 Nimmi. All rights reserved.
//

import UIKit

//  here is the protocol for creating the delegation
protocol FavCellDelegate : class {
    func favButtonTapped(_ tag: Int)
}

class FavCollectionViewCell: UICollectionViewCell {
    
    //MARK:- IBOutlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    
    //MARK:- Delegate
    weak var cellDelegate: FavCellDelegate?

    //MARK:- IBActions
    @IBAction func favTapped(_ sender: Any) {
        cellDelegate?.favButtonTapped(self.tag)
    }
    
    var favCell: Favourite? {
        didSet {
            self.bringSubview(toFront: favButton)
            favButton.setImage(UIImage(named:"Fav"), for: .normal)
            guard (favCell?.imageURL) != nil else {
                return
            }
            imgView.sd_setImage(with: URL.init(string: (favCell?.imageURL)!))

        }
    }
}
