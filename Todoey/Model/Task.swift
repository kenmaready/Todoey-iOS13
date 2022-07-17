//
//  Task.swift
//  Todoey
//
//  Created by Ken Maready on 7/16/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

struct Task: Codable {
    var desc: String?
    var completed: Bool = false
}
