//
//  WebAPIRequest.swift
//  GiphyWorks
//
//  Created by Rajshekhar Modi on 2018-01-25.
//  Copyright © 2018 Nimmi. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WebAPIRequest {
    
    static let sharedInstance = WebAPIRequest()
    var alamofireManager: Alamofire.SessionManager!
    
    init() {
        let configuration = URLSessionConfiguration.default
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    func callTrending(_ limit: Int, offset: Int, completionHandler:@escaping (_ gifs: [GifModel]?, _ total: Int?, _ error: String?) -> Void) {
    
        alamofireManager.request(GlobalConstants.baseURL + "v1/gifs/trending", method: .get, parameters: ["api_key" : GlobalConstants.giphyAPIKey, "limit" : "\(limit)", "offset" : "\(offset)"], encoding: URLEncoding.default).responseJSON(completionHandler: { response  in

            switch response.result {
            case .success(let result):
                
                let resultJSON = JSON.init(result)
                var total: Int?
                
                if let pagination = resultJSON["pagination"].dictionary {
                    if let totalcount = pagination["total_count"]?.int {
                        total = totalcount
                    }
                }
                if let gifdata = resultJSON["data"].array {
                    
                    var gifs = [GifModel]()
                    
                    for gifJSON in gifdata {
                        let gif = GifModel.init(data: gifJSON)
                        gifs.append(gif)
                    }
                    completionHandler(gifs,total, nil)
                    
                } else {
                    completionHandler(nil,nil, "Something is wrong")
                }
                
            case .failure(let error):
                completionHandler(nil,nil,error.localizedDescription)
            }
            
        })
 
    }
    
    func callSearch(searchStr: String, completionHandler:@escaping (_ gifs: [GifModel]?, _ total: Int?, _ error: String?) -> Void) {
        
        alamofireManager.request(GlobalConstants.baseURL + "v1/gifs/search", method: .get, parameters: ["api_key" : GlobalConstants.giphyAPIKey, "limit" : "\(0)", "offset" : "\(GlobalConstants.resultsLimit)", "rating": GlobalConstants.searchRatingType, "q" : searchStr], encoding: URLEncoding.default, headers: nil).responseJSON(completionHandler: { response in
            
            switch response.result {
            case .success(let result):
                
                let resultJSON = JSON.init(result)
                var total: Int?
                
                if let pagination = resultJSON["pagination"].dictionary {
                    if let totalcount = pagination["total_count"]?.int {
                        total = totalcount
                    }
                }
                if let gifdata = resultJSON["data"].array {
                    
                    var gifs = [GifModel]()
                    
                    for gifJSON in gifdata {
                        let gif = GifModel.init(data: gifJSON)
                        gifs.append(gif)
                    }
                    
                    completionHandler(gifs, total, nil)
                } else {
                    
                    completionHandler(nil, nil, "Something is wrong")
                    
                }
            case .failure(let error):
                completionHandler(nil, nil, error.localizedDescription)
            }
            
        })
    }
    
}





