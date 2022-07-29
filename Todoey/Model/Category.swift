//
//  Category.swift
//  Todoey
//
//  Created by Ken Maready on 7/25/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colorCode: String?
    let tasks = List<Task>()
}
