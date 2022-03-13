//
//  UserDefaultsSettings.swift
//  xxx
//
//  Created by Семен Безгин on 10.03.2022.
//

import SwiftUI

enum Theme {
    case dark
    case light
}

class UserDefaultsSettings: ObservableObject {
    @Published var selectedMaps: [String] = UserDefaults.standard.array(forKey: "selectedMaps") as? [String] ?? [String]() {
        didSet {
            UserDefaults.standard.set(self.selectedMaps, forKey: "selectedMaps")
        }
    }
    
//    @Published var theme: Theme = UserDefaults.standard.object(forKey: "theme") as? Theme ?? .dark  {
//        didSet {
//            UserDefaults.standard.set(self.theme, forKey: "theme")
//        }
//    }
    
    @Published var theme: Int = UserDefaults.standard.integer(forKey: "theme") {
        didSet {
            UserDefaults.standard.set(self.theme, forKey: "theme")
        }
    }
}
