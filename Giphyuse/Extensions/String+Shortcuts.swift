//
//  String+Shortcuts.swift
//  Giphyuse
//
//  Created by Rajshekhar Modi on 2018-01-29.
//  Copyright © 2018 Nimmi. All rights reserved.
//

import Foundation
import Swift // or Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
