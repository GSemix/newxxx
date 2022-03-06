//
//  mainMgimoApp.swift
//  mainMgimo
//
//  Created by Семен Безгин on 05.01.2022.
//

import SwiftUI

@main
struct testMgumoApp: App {
    @StateObject var viewRouter = ViewRouter()
    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView(viewRouter: viewRouter)
            }
            .edgesIgnoringSafeArea(.bottom)
            
        }
    }
}
