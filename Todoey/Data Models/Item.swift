//
//  Data.swift
//  Todoey
//
//  Created by Yeoh Hui Qing on 28/11/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    // "dynamic" keyword tells runtime to use dynamic dispatch instead of static dispatch, which comes from Objective-c
    @objc dynamic var title: String = ""
    @objc dynamic var done: Bool = false
    @objc dynamic var dateCreated: Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items") // inverse relationship to the parent Category
}
