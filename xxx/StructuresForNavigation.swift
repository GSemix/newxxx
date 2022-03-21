//
//  StructuresForNavigation.swift
//  xxx
//
//  Created by Семен Безгин on 21.03.2022.
//

import SwiftUI

struct Point: Decodable, Encodable, Equatable {
    var name: String
    var housing: String
    var floor: String
    var x0: String
    var y0: String
    var x: String
    var y: String
    
    init() {
        name = ""
        housing = ""
        floor = ""
        x = ""
        y = ""
        x0 = ""
        y0 = ""
    }
    
    init(newName: String, newHousing: String, newFloor: String, newX: String, newY: String, newX0: String, newY0: String) {
        name = newName
        housing = newHousing
        floor = newFloor
        x = newX
        y = newY
        x0 = newX0
        y0 = newY0
    }
}

enum Page {
    case navigation
    case datalist
    case properties
    case news
    case maps
}

struct mapContents: Hashable {
    var name: String = String()
    var mainContent: String = String()
    var image: UIImage = UIImage()
    var text: String = String()
    var blur: Bool = false
    var way: [String] = ["", ""]
}
