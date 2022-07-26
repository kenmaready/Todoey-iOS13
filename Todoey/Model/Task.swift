//
//  Task.swift
//  Todoey
//
//  Created by Ken Maready on 7/25/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    @objc dynamic var desc: String = ""
    @objc dynamic var completed: Bool = false
    @objc dynamic var createdAt: Date = Date()
    dynamic var category = LinkingObjects(fromType: Category.self, property: "tasks")
}
