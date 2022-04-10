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
    @State var Nav = PointRouting(nameOfFileVertex: "Data/Vertex", nameOfFileEdges: "Data/Edges")
    
    var body: some Scene {
        WindowGroup {
            VStack {
                ContentView(Nav: Nav, viewRouter: viewRouter)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
