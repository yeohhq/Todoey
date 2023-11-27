//
//  Item.swift
//  Todoey
//
//  Created by Yeoh Hui Qing on 27/11/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

class Item: Codable {
    var title: String = ""
    var done: Bool = false
    
    init(title: String, done: Bool) {
        self.title = title
        self.done = done
    }
    
    init(_ title: String, _ done: Bool) {
        self.title = title
        self.done = done
    }
    
    init(_ title: String) {
        self.title = title
    }
}
