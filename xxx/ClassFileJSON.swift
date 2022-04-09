//
//  FileClass.swift
//  xxx
//
//  Created by Семен Безгин on 05.04.2022.
//

import SwiftUI

class FileJSON {
    private var nameOfFile: String
    private var bundleFileURL: URL?
    
    init(bundleFileName: String) {
        self.nameOfFile = bundleFileName
        self.bundleFileURL = URL(fileURLWithPath: Bundle.main.path(forResource: bundleFileName , ofType: "json")!)
    }
    
    public func getContentJSON() -> Any? {
        var object: Any? = nil
        
        if bundleFileURL != nil {
            let contentsJSON = NSData(contentsOf: bundleFileURL!)! as Data
            
            do {
                object = try JSONSerialization.jsonObject(with: contentsJSON, options: .allowFragments)
            } catch {
                print("Error in function -> FileJSON.getContentJSON")
            }
        }
        
        return object
    }
}
