//
//  Favourite+CoreDataProperties.swift
//  
//
//  Created by Rajshekhar Modi on 2018-01-26.
//
//

import Foundation
import CoreData


extension Favourite {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Favourite> {
        return NSFetchRequest<Favourite>(entityName: "Favourite")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageURL: String?

}
