//
//  GifModel.swift
//  GiphyWorks
//
//  Created by Rajshekhar Modi on 2018-01-25.
//  Copyright © 2018 Nimmi. All rights reserved.
//

import Foundation
import SwiftyJSON

class GifModel {
    
    var url: String?
    var id: String?
    var title: String?
    
    convenience init(data: JSON) {
        self.init()
        
        if let gifId = data["id"].string {
            id = gifId
        }
        if let gifTitle = data["title"].string {
            title = gifTitle
        }
        if let gifURL = data["images"][GlobalConstants.gifModelImageType]["url"].string {
            url = gifURL
        }
    }
}

